#!/usr/bin/env python3
"""Reachable advice peer for #375's shipped-path evidence (ADR-0002 Testability).

Speaks the CTR-advice-stream wire (chunked NDJSON: E1 advice_update lines, then
one E2 {"reason": ...}). It is a scripted stand-in for the advice backend so the
release scene graph (no PlaytestSeams, so AdviceStreamTransport is the only
advice path) can be driven against something reachable. No Stockfish, no UCI.

Modes:
  normal  best move e2e4 / -20 for White, e7e5 / 35 for Black; ends by cap
  fail    500 + {"reason": "error"} for every request (EX.error / S3 path)

Every request is appended to --log as one JSON line.
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
        with open(self.log_path, "a", encoding="utf-8") as handle:
            handle.write(
                json.dumps(
                    {
                        "at": round(time.monotonic(), 3),
                        "mode": self.mode,
                        "authorized": body.get("api_key") == self.key,
                        "request": body,
                    }
                )
                + "\n"
            )
        if body.get("api_key") != self.key or self.mode == "fail":
            self._error(500)
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
        white_to_move = (fields[1] if len(fields) > 1 else "w") == "w"
        if white_to_move:
            script = [(0.00, 18, "e2e4", 4), (0.20, 41, "e2e4", 6), (0.40, 63, "e2e4", 8)]
        else:
            script = [(0.00, -20, "e7e5", 4), (0.20, -35, "e7e5", 6)]
        self.send_response(200)
        self.send_header("Content-Type", "application/x-ndjson")
        self.send_header("Transfer-Encoding", "chunked")
        self.send_header("Connection", "close")
        self.end_headers()
        started = time.monotonic()
        for delay, eval_cp, uci, depth in script:
            wait = delay - (time.monotonic() - started)
            if wait > 0:
                time.sleep(wait)
            line = json.dumps({"best_move_uci": uci, "eval_cp": eval_cp, "depth": depth}) + "\n"
            try:
                self._chunk(line.encode())
            except (BrokenPipeError, ConnectionResetError):
                return
        wait = 0.60 - (time.monotonic() - started)
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
