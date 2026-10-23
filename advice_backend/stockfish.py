"""Stockfish UCI integration (CMP-advice-backend C2, R1, R7; ADR-0011).

Stockfish is a separate operator-installed program invoked here as a local
child process. Nothing in this module is reachable over the network: the UCI
pipe is the backend's own stdin/stdout link to that child (B2).
"""

from __future__ import annotations

import select
import subprocess
import threading
import time
from dataclasses import dataclass
from typing import Callable, TextIO

from .protocol import AdviceUpdate

# Stockfish reports a score from the side to move; the wire is White's view.
_BLACK = "b"
# How long a poll waits for the next engine line before re-checking cancel/cap.
_POLL_S = 0.005
# How long O2 waits for the engine to acknowledge with `bestmove`.
_STOP_DRAIN_S = 0.5

UpdateSink = Callable[[AdviceUpdate], None]


@dataclass(frozen=True)
class EngineScore:
    """One parsed ``info`` line that carries a score and a principal variation."""

    eval_cp: int
    best_move_uci: str
    depth: int
    mate_in: int | None = None


def _white_sign(fen: str) -> int:
    fields = fen.split()
    side = fields[1] if len(fields) > 1 else "w"
    return -1 if side == _BLACK else 1


def parse_info_line(line: str, fen: str) -> EngineScore | None:
    """Turn one UCI ``info`` line into a White-view score, or None when it has none."""
    tokens = line.split()
    if not tokens or tokens[0] != "info" or "score" not in tokens or "pv" not in tokens:
        return None
    depth = 0
    eval_cp = 0
    mate_in: int | None = None
    best_move_uci = ""
    index = 0
    while index < len(tokens):
        token = tokens[index]
        following = tokens[index + 1] if index + 1 < len(tokens) else ""
        if token == "depth" and following.isdigit():
            depth = int(following)
            index += 2
        elif token == "score" and following in ("cp", "mate"):
            amount = tokens[index + 2] if index + 2 < len(tokens) else ""
            if amount.lstrip("-").isdigit():
                signed = int(amount) * _white_sign(fen)
                if following == "cp":
                    eval_cp = signed
                else:
                    mate_in = signed
            index += 3
        elif token == "pv":
            best_move_uci = following
            index += 2
        else:
            index += 1
    if not best_move_uci:
        return None
    return EngineScore(eval_cp=eval_cp, best_move_uci=best_move_uci, depth=depth, mate_in=mate_in)


def parse_bestmove(line: str) -> str | None:
    tokens = line.split()
    if len(tokens) >= 2 and tokens[0] == "bestmove":
        return tokens[1]
    return None


class StockfishSearch:
    """One capped search inside a Stockfish child process.

    ``stop()`` may be called from another thread: it ends the search promptly
    and returns once the engine has acknowledged, so no tick starts after it.
    """

    def __init__(self, command: list[str], fen: str, cap_ms: int) -> None:
        self._command = command
        self._fen = fen
        self._cap_ms = cap_ms
        self._stop_requested = threading.Event()
        self._lock = threading.Lock()
        self._process: subprocess.Popen[str] | None = None
        self._stdout: TextIO | None = None
        self._exited = False

    def run(self, on_update: UpdateSink) -> None:
        """Search until the cap or ``stop``; call ``on_update`` per improving tick."""
        started = time.monotonic()
        process = subprocess.Popen(  # nosec B603 - operator-configured Stockfish path
            self._command,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True,
            bufsize=1,
        )
        with self._lock:
            self._process = process
            self._stdout = process.stdout
        try:
            self._send(process, "uci")
            self._send(process, f"position fen {self._fen}")
            self._send(process, f"go movetime {self._cap_ms}")
            self._consume(on_update, started)
        finally:
            self._shut_down(process)

    def stop(self) -> None:
        """End the search now (client cancel); a no-op before ``run`` starts."""
        self._stop_requested.set()
        with self._lock:
            process = self._process
            stdout = self._stdout
            exited = self._exited
        if process is None or exited:
            return
        self._send(process, "stop")
        _drain(stdout, _STOP_DRAIN_S)

    def _consume(self, on_update: UpdateSink, started: float) -> None:
        deadline = started + self._cap_ms / 1000
        stdout = self._stdout
        if stdout is None:
            return
        while True:
            # The cap holds even if the engine ignores `go movetime` (CTR G2).
            if self._stop_requested.is_set() or time.monotonic() >= deadline:
                return
            line = _read_line(stdout, deadline)
            if line is None:
                continue
            score = parse_info_line(line, self._fen)
            if score is not None:
                on_update(
                    AdviceUpdate(
                        best_move_uci=score.best_move_uci,
                        eval_cp=score.eval_cp,
                        mate_in=score.mate_in,
                        depth=score.depth,
                        time_ms=int((time.monotonic() - started) * 1000),
                    )
                )
            if parse_bestmove(line) is not None:
                return

    def _shut_down(self, process: subprocess.Popen[str]) -> None:
        self._send(process, "quit")
        try:
            process.wait(timeout=1)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
        with self._lock:
            self._process = None
            self._stdout = None
            self._exited = True
        if process.stdin is not None:
            process.stdin.close()

    @staticmethod
    def _send(process: subprocess.Popen[str], line: str) -> None:
        if process.stdin is None:
            return
        try:
            process.stdin.write(line + "\n")
            process.stdin.flush()
        except (BrokenPipeError, OSError, ValueError):
            pass


def _read_line(stdout: TextIO, deadline: float) -> str | None:
    """One line from the engine, or None when the poll window ended first."""
    wait = max(0.0, min(_POLL_S, deadline - time.monotonic()))
    ready, _, _ = select.select([stdout], [], [], wait)
    if not ready:
        return None
    line = stdout.readline()
    return line or None


def _drain(stdout: TextIO | None, seconds: float) -> None:
    """Read until the engine's ``bestmove`` or ``seconds`` elapse, discarding output."""
    if stdout is None:
        return
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        line = _read_line(stdout, deadline)
        if line is not None and parse_bestmove(line) is not None:
            return


def resolve_engine_command(configured: str | None) -> list[str]:
    """Command that starts Stockfish: the configured path, else ``stockfish`` on PATH."""
    return [configured or "stockfish"]
