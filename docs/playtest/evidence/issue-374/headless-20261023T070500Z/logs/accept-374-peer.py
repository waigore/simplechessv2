#!/usr/bin/env python3
"""Simulated advice peer for #374 acceptance (ADR-0002 Testability).

Speaks the CTR-advice-stream wire (chunked NDJSON: one advice_update per line,
then one {"reason": ...}). Scripted stand-in for the backend; ships no
Stockfish and no UCI.

Modes:
  normal  updates for the side to move; a distinctive stale marker (999 / a2a4)
          600 ms into a White-side stream; end by cap at 900 ms
  stall   accept the request and never answer
  reject  401 + {"reason": "error"} immediately (wrong key)

Every request is appended to --log as one JSON line (api_key, fen, time_ms).
"""

from __future__ import annotations

import argparse
import json
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class _Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    mode = "normal"
    key = "accept-key"
    log_path = ""

    def log_message(self, *args: object) -> None:  # noqa: A002 - http.server API
        return

    def do_POST(self) -> None:  # noqa: N802 - http.server API
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length)
        try:
            body = json.loads(raw or b"{}")
        except ValueError:
            body = {"unparseable": raw.decode("utf-8", "replace")}
        authorized = body.get("api_key") == self.key
        with open(self.log_path, "a", encoding="utf-8") as handle:
            handle.write(
                json.dumps(
                    {
                        "at": round(time.monotonic(), 3),
                        "path": self.path,
                        "mode": self.mode,
                        "authorized": authorized,
                        "request": body,
                    }
                )
                + "\n"
            )
        if not authorized:
            self._error(401)
            return
        if self.mode == "reject":
            self._error(500)
            return
        if self.mode == "stall":
            time.sleep(6.0)
            return
        self._stream(body)

    def _error(self, status: int) -> None:
        payload = (json.dumps({"reason": "error"}) + "\n").encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(payload)
        self.wfile.flush()

    def _chunk(self, payload: bytes) -> None:
        self.wfile.write(b"%x\r\n" % len(payload) + payload + b"\r\n")
        self.wfile.flush()

    def _stream(self, body: dict) -> None:
        fields = str(body.get("fen", "")).split(" ")
        side = fields[1] if len(fields) > 1 else "w"
        if side == "w":
            script = [(0.0, 18, "e2e4"), (0.12, 27, "e2e4"), (0.24, 35, "e2e4"),
                      (0.60, 999, "a2a4"), (0.75, 999, "a2a4")]
            cap_at = 0.90
        else:
            script = [(0.0, -20, "e7e5"), (0.12, -12, "e7e5"), (0.30, -8, "e7e5")]
            cap_at = 0.40
        self.send_response(200)
        self.send_header("Content-Type", "application/x-ndjson")
        self.send_header("Transfer-Encoding", "chunked")
        self.send_header("Connection", "close")
        self.end_headers()
        started = time.monotonic()
        for delay, eval_cp, uci in script:
            wait = delay - (time.monotonic() - started)
            if wait > 0:
                time.sleep(wait)
            line = json.dumps({"best_move_uci": uci, "eval_cp": eval_cp, "depth": 4}) + "\n"
            try:
                self._chunk(line.encode())
            except (BrokenPipeError, ConnectionResetError):
                return
        wait = cap_at - (time.monotonic() - started)
        if wait > 0:
            time.sleep(wait)
        try:
            self._chunk((json.dumps({"reason": "cap"}) + "\n").encode())
            self._chunk(b"")
        except (BrokenPipeError, ConnectionResetError):
            return


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--mode", default="normal")
    parser.add_argument("--key", default="accept-key")
    parser.add_argument("--log", required=True)
    args = parser.parse_args()
    _Handler.mode = args.mode
    _Handler.key = args.key
    _Handler.log_path = args.log
    server = ThreadingHTTPServer(("127.0.0.1", args.port), _Handler)
    server.daemon_threads = True
    print(f"peer {args.mode} listening on {args.port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
