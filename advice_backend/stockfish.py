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
# Search time held back from the cap so E2 reaches the client by the cap:
# the cap covers the whole stream, not just the engine's thinking.
_END_RESERVE_S = 0.03
# A courtesy pause for the engine to exit on `quit` after E2 is written;
# one still alive at the deadline is killed.
_SHUTDOWN_S = 0.001

UpdateSink = Callable[[AdviceUpdate], None]


@dataclass(frozen=True)
class EngineScore:
    """One parsed ``info`` line that carries a score and a principal variation."""

    eval_cp: int
    best_move_uci: str
    depth: int | None = None
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
    depth: int | None = None
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

    ``run`` returns by the cap even when the engine is slow or ignores
    ``go movetime`` (CTR-advice-stream G2). ``request_stop`` may be called from
    another thread: it ends the search promptly and drops every later tick.
    ``close`` reaps the child; call it once the stream's end message is safe.
    """

    def __init__(self, command: list[str], fen: str, cap_ms: int) -> None:
        self._command = command
        self._fen = fen
        self._cap_ms = cap_ms
        self._stop_requested = threading.Event()
        self._lock = threading.Lock()
        self._search_ended = False
        self._reached_deadline = False
        self._process: subprocess.Popen[str] | None = None
        self._stdout: TextIO | None = None
        self._exited = False

    def run(self, on_update: UpdateSink) -> None:
        """Search until the cap or ``stop``; call ``on_update`` per improving tick.

        The engine is left stopped but running when this returns;
        ``close()`` reaps it.
        """
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
            # The cap counts from the search request, not from process spawn:
            # a slow spawn must not push E2 past CFG.ADVICE_TIME_MS (G2).
            started = time.monotonic()
            self._send(process, f"go movetime {self._cap_ms}")
            self._consume(on_update, started)
        except BaseException:
            self.close()
            raise

    def close(self) -> None:
        """Reap the engine. Call after the stream's E2 is safe to write."""
        with self._lock:
            process = self._process
            self._exited = True
            self._stdout = None
        if process is None:
            return
        # The search is over, so `quit` is answered without another search.
        # E2 has already been written: never wait on the child longer than a
        # courtesy pause, then kill it so no stray process lingers.
        if not self._stop_requested.is_set():
            self._send(process, "stop")
        self._send(process, "quit")
        try:
            process.wait(timeout=_SHUTDOWN_S)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
        with self._lock:
            self._process = None
        if process.stdin is not None:
            process.stdin.close()
        if process.stdout is not None:
            process.stdout.close()

    def request_stop(self) -> None:
        """End the search now (client cancel); sends one UCI ``stop``."""
        self._stop_requested.set()
        self._send_stop()

    @property
    def stop_requested(self) -> bool:
        return self._stop_requested.is_set()

    def _send_stop(self) -> None:
        with self._lock:
            process = self._process
            exited = self._exited
        if process is not None and not exited:
            self._send(process, "stop")

    def _consume(self, on_update: UpdateSink, started: float) -> None:
        deadline = started + max(0.0, self._cap_ms / 1000 - _END_RESERVE_S)
        try:
            self._read_until(deadline, on_update, started)
        finally:
            # End the search at the cap as well as on a cancel: a real engine
            # stops thinking before it answers `quit` at shutdown.
            self._end_search()

    def _end_search(self) -> None:
        """Stop the engine's search; a cancel and the cap may both reach here."""
        with self._lock:
            if self._search_ended:
                return
            self._search_ended = True
        self._stop_requested.set()
        self._send_stop()

    def reached_deadline(self) -> bool:
        """True when the search ran to its cap rather than ending early."""
        return self._reached_deadline

    def _read_until(self, deadline: float, on_update: UpdateSink, started: float) -> None:
        with self._lock:
            stdout = self._stdout
        if stdout is None:
            return
        while True:
            # The cap holds even if the engine ignores `go movetime` (CTR G2).
            # There is nothing left to hear once the cap has passed.
            if self._stop_requested.is_set():
                return
            line = self._read_line(stdout, deadline)
            if line is None:
                if time.monotonic() >= deadline:
                    self._reached_deadline = True
                    return
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

    @staticmethod
    def _read_line(stdout: TextIO, deadline: float) -> str | None:
        """One line from the engine, or None when the poll window ended first."""
        wait = max(0.0, min(_POLL_S, deadline - time.monotonic()))
        try:
            ready, _, _ = select.select([stdout], [], [], wait)
        except (OSError, ValueError):
            return None
        if not ready:
            return None
        try:
            # The engine is ready to be read, so this returns without blocking
            # past the cap: `select` already saw the line.
            return stdout.readline() or None
        except (OSError, ValueError):
            return None

    @staticmethod
    def _send(process: subprocess.Popen[str], line: str) -> None:
        if process.stdin is None:
            return
        try:
            process.stdin.write(line + "\n")
            process.stdin.flush()
        except (BrokenPipeError, OSError, ValueError):
            pass


def resolve_engine_command(configured: str | None) -> list[str]:
    """Command that starts Stockfish: the configured path, else ``stockfish`` on PATH."""
    return [configured or "stockfish"]
