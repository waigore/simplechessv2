"""Advice backend server: the sole UCI peer of Stockfish (CMP-advice-backend).

One endpoint speaks CTR-advice-stream: a POST starts a search (O1); the
response is chunked ``application/x-ndjson``, one E1 update per chunk, closed
by one E2 end message. A client that vanishes mid-stream is O2.
"""

from __future__ import annotations

import hmac
import json
import logging
import socket
import threading
import time
from dataclasses import dataclass, field
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Callable

from .protocol import (
    DEFAULT_ADVICE_TIME_MS,
    END_CANCEL,
    END_CAP,
    END_ERROR,
    AdviceRequest,
    AdviceUpdate,
    end_message,
    parse_request,
)
from .stockfish import StockfishSearch, UpdateSink, resolve_engine_command

LOGGER = logging.getLogger("advice_backend")

ADVICE_PATH = "/advice"
_NDJSON = "application/x-ndjson"

SearchFactory = Callable[[AdviceRequest, int], StockfishSearch]


def chunk_size(length: int) -> bytes:
    """One HTTP/1.1 chunk-length line; the end of the stream needs ``0``."""
    return f"{length:x}\r\n".encode("ascii")


class SearchSession:
    """One in-flight search, cancellable from the request thread."""

    def __init__(self, search: StockfishSearch) -> None:
        self._search = search
        self._lock = threading.Lock()
        self._sink: UpdateSink | None = None
        self.cancelled = False

    def run(self, on_update: UpdateSink) -> None:
        self._sink = on_update
        self._search.run(self._forward)

    def cancel(self) -> None:
        """O2: stop the search; a second call is a no-op."""
        with self._lock:
            if self.cancelled:
                return
            self.cancelled = True
        self._search.stop()

    def _forward(self, update: AdviceUpdate) -> None:
        """Hand a tick on unless a cancel has already been accepted (I3)."""
        sink = self._sink
        if sink is not None and not self.cancelled:
            sink(update)


class AdviceService:
    """Authorizes a request, then runs its search to the cap or a client cancel."""

    def __init__(
        self,
        api_key: str,
        cap_ms: int = DEFAULT_ADVICE_TIME_MS,
        engine_path: str | None = None,
        search_factory: SearchFactory | None = None,
    ) -> None:
        self._api_key = api_key
        self._cap_ms = cap_ms
        self._engine_path = engine_path
        self._search_factory = search_factory or self._stockfish_search
    @property
    def cap_ms(self) -> int:
        return self._cap_ms

    def authorizes(self, request: AdviceRequest) -> bool:
        """CTR-advice-stream G4: only the configured key opens a search."""
        return hmac.compare_digest(request.api_key, self._api_key)

    def start(self, request: AdviceRequest) -> SearchSession:
        """Open a search (O1) capped at the client's ``time_ms`` or ``CFG.ADVICE_TIME_MS``."""
        cap_ms = min(request.time_ms, self._cap_ms)
        return SearchSession(self._search_factory(request, cap_ms))

    def _stockfish_search(self, request: AdviceRequest, cap_ms: int) -> StockfishSearch:
        return StockfishSearch(resolve_engine_command(self._engine_path), request.fen, cap_ms)


@dataclass
class _RequestState:
    """What the handler needs to log one request from start to end."""

    request: AdviceRequest
    started: float = field(default_factory=time.monotonic)
    disconnected: bool = False


class AdviceHandler(BaseHTTPRequestHandler):
    """HTTP binding for one advice stream; decisions live in ``AdviceService``."""

    service: AdviceService

    protocol_version = "HTTP/1.1"

    def do_POST(self) -> None:  # noqa: N802 - http.server API
        if self.path != ADVICE_PATH:
            self.send_error(HTTPStatus.NOT_FOUND)
            return
        request = self._read_request()
        if request is None:
            return
        if not self.service.authorizes(request):
            LOGGER.warning("advice_error reason=unauthorized")
            self._send_json(HTTPStatus.UNAUTHORIZED, end_message(END_ERROR))
            return
        self._stream(request)

    def log_message(self, format: str, *args: object) -> None:  # noqa: A002 - http.server API
        LOGGER.debug("%s - %s", self.address_string(), format % args)

    def client_gone(self) -> bool:
        """True once the client has closed its end of the stream (O2 on the wire).

        Writes to a half-closed socket keep succeeding into the kernel buffer,
        so the probe reads the socket: after the request body the backend
        never expects another byte, and a closed peer reads as end of stream.
        """
        try:
            return self.connection.recv(1, socket.MSG_PEEK | socket.MSG_DONTWAIT) == b""
        except BlockingIOError:
            return False
        except OSError:
            return True

    def _read_request(self) -> AdviceRequest | None:
        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length) if length > 0 else b""
        try:
            return parse_request(json.loads(raw.decode("utf-8") or "null"))
        except (UnicodeDecodeError, ValueError) as failure:
            LOGGER.warning("advice_error reason=bad_request detail=%s", failure)
            self._send_json(HTTPStatus.BAD_REQUEST, end_message(END_ERROR))
            return None

    def _stream(self, request: AdviceRequest) -> None:
        state = _RequestState(request)
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", _NDJSON)
        self.send_header("Transfer-Encoding", "chunked")
        self.send_header("Connection", "close")
        self.end_headers()
        session = self.service.start(request)

        def write(update: AdviceUpdate) -> None:
            if state.disconnected:
                return
            if self.client_gone():
                state.disconnected = True
                session.cancel()
                return
            try:
                self._write_chunk(update.to_wire())
            except OSError:
                state.disconnected = True
                session.cancel()

        LOGGER.info("advice_start fen=%s", request.fen)
        reason = END_ERROR
        try:
            session.run(write)
            reason = END_CANCEL if session.cancelled else END_CAP
        except (OSError, ValueError) as failure:
            LOGGER.error(
                "advice_error reason=engine fen=%s detail=%s elapsed_ms=%d",
                request.fen,
                failure,
                _elapsed_ms(state.started),
            )
        self._close_stream(state, reason)

    def _close_stream(self, state: _RequestState, reason: str) -> None:
        if not state.disconnected:
            try:
                self._write_chunk(end_message(reason))
                self._end_chunks()
            except OSError:
                state.disconnected = True
        LOGGER.info(
            "advice_end reason=%s elapsed_ms=%d disconnected=%s",
            reason,
            _elapsed_ms(state.started),
            state.disconnected,
        )
        self.close_connection = True

    def _write_chunk(self, message: dict[str, object]) -> None:
        framed = json.dumps(message, separators=(",", ":")).encode("utf-8") + b"\n"
        self.wfile.write(chunk_size(len(framed)) + framed + b"\r\n")
        self.wfile.flush()

    def _end_chunks(self) -> None:
        self.wfile.write(chunk_size(0) + b"\r\n\r\n")
        self.wfile.flush()

    def _send_json(self, status: HTTPStatus, message: dict[str, str]) -> None:
        body = json.dumps(message, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)
        self.close_connection = True


def _elapsed_ms(started: float) -> int:
    return int((time.monotonic() - started) * 1000)


def make_server(service: AdviceService, host: str, port: int) -> ThreadingHTTPServer:
    """Build the HTTP server bound to whatever listen address the process was given."""
    handler = type("BoundAdviceHandler", (AdviceHandler,), {"service": service})
    return ThreadingHTTPServer((host, port), handler)
