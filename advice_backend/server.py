"""Advice backend server: the sole UCI peer of Stockfish (CMP-advice-backend).

One endpoint speaks CTR-advice-stream: a POST starts a search (O1); the
response is chunked ``application/x-ndjson``, one E1 update per chunk, closed
by one E2 end message. A client that vanishes mid-stream is O2.

The rules that decide a request (auth, cap, cancel) live in ``AdviceService``
and ``SearchSession`` here; the HTTP chunk framing lives in ``AdviceHandler``.
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
from typing import TYPE_CHECKING, Callable

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

if TYPE_CHECKING:
    from .catalog import CatalogService

# CTR-puzzle-catalog-read O1: the deal route on this server's host (ADR-0013).
CATALOG_PATH = "/catalog/deal"

LOGGER = logging.getLogger("advice_backend")

ADVICE_PATH = "/advice"
_NDJSON = "application/x-ndjson"
# How often a stream proves the client is still listening: it is also the
# grace period before a vanished client stops the search.
_GONE_CHECK_S = 0.1

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
        self._cancelled = False
        self._failed = False

    @property
    def cancelled(self) -> bool:
        """True once O2 was asked for, from this session or another thread."""
        return self._cancelled or self._search.stop_requested

    @property
    def failed(self) -> bool:
        """True when the search ended because the engine failed (E2 reason)."""
        with self._lock:
            return self._failed

    @property
    def reached_deadline(self) -> bool:
        """True when the search ran to its cap instead of ending early (E2 reason)."""
        return self._search.reached_deadline()

    def run(self, on_update: UpdateSink) -> None:
        self._sink = on_update
        try:
            self._search.run(self._forward)
        except (OSError, ValueError):
            # The engine is gone: the stream still owes its client an E2.
            with self._lock:
                self._failed = True

    def cancel(self) -> None:
        """O2: stop the search; a second call is a no-op."""
        with self._lock:
            if self._cancelled:
                return
            self._cancelled = True
        self._search.request_stop()

    def close(self) -> None:
        """Reap the engine once the stream has ended."""
        self._search.close()

    def _forward(self, update: AdviceUpdate) -> None:
        """Hand a tick on unless a cancel has already been accepted (I3)."""
        sink = self._sink
        if sink is not None and not self.cancelled:
            sink(update)


class AdviceService:
    """Authorizes a request, then runs its search to ``CFG.ADVICE_TIME_MS`` or a cancel.

    The configured cap is the maximum engine think time (F-move-advice R7,
    ``CMP-advice-backend`` R3, ``CTR-advice-stream`` G2). The request's
    ``time_ms`` is the client's cap; it may shorten the search but never
    lengthen it beyond the configured value.
    """

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

    def search_cap_ms(self, request: AdviceRequest) -> int:
        """The search stop: ``min(request.time_ms, CFG.ADVICE_TIME_MS)``, clamped at 0."""
        return max(0, min(request.time_ms, self._cap_ms))

    def start(self, request: AdviceRequest) -> SearchSession:
        """Open a search (O1) that stops by ``search_cap_ms`` (G2)."""
        return SearchSession(self._search_factory(request, self.search_cap_ms(request)))

    def _stockfish_search(self, request: AdviceRequest, cap_ms: int) -> StockfishSearch:
        return StockfishSearch(resolve_engine_command(self._engine_path), request.fen, cap_ms)


@dataclass
class _RequestState:
    """What the handler needs to log one request from start to end."""

    request: AdviceRequest
    started: float = field(default_factory=time.monotonic)
    disconnected: bool = False


class AdviceHandler(BaseHTTPRequestHandler):
    """HTTP binding for one advice stream: read, frame, and write one stream.

    The same handler answers the catalog deal route (ADR-0013): ``catalog`` is
    set on the bound handler when a snapshot is configured.
    """

    service: AdviceService
    catalog: CatalogService | None = None

    protocol_version = "HTTP/1.1"

    def do_POST(self) -> None:  # noqa: N802 - http.server API
        if self.path == CATALOG_PATH:
            self._deal()
            return
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

    def _deal(self) -> None:
        """CTR-puzzle-catalog-read O1: one record, or no record (O2, FAIL.T14).

        The route exists whether or not a snapshot is configured: an unset
        catalog is a failed read for that deal, not a missing endpoint.
        """
        from .catalog import parse_deal_request

        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length) if length > 0 else b""
        try:
            request = parse_deal_request(json.loads(raw.decode("utf-8") or "null"))
        except (UnicodeDecodeError, ValueError) as failure:
            LOGGER.warning("catalog_error reason=bad_request detail=%s", failure)
            self._send_json(HTTPStatus.BAD_REQUEST, {})
            return
        catalog = self.catalog
        if catalog is None:
            # No snapshot configured: every deal is a failed read, same as a wrong key.
            LOGGER.warning("catalog_error reason=disabled")
            self._send_json(HTTPStatus.SERVICE_UNAVAILABLE, {})
            return
        record = catalog.deal(request)
        if record is None:
            # Wrong key, rapid-fire refusal, or an empty snapshot: no record.
            status = HTTPStatus.UNAUTHORIZED if not catalog.authorizes(request) else HTTPStatus.SERVICE_UNAVAILABLE
            self._send_json(status, {})
            return
        self._send_json(HTTPStatus.OK, record)

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
        cap_ms = self.service.search_cap_ms(request)
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", _NDJSON)
        self.send_header("Transfer-Encoding", "chunked")
        self.send_header("Connection", "close")
        self.end_headers()
        session = self.service.start(request)
        last_check = time.monotonic()

        def write(update: AdviceUpdate) -> None:
            nonlocal last_check
            if state.disconnected:
                return
            # Proving the client is still there costs a syscall; once per tick
            # interval is enough, and it must not eat the cap (CTR-advice-stream G2).
            if time.monotonic() - last_check >= _GONE_CHECK_S:
                last_check = time.monotonic()
                if self.client_gone():
                    state.disconnected = True
                    session.cancel()
                    return
            try:
                self._write_chunk(update.to_wire())
            except OSError:
                state.disconnected = True
                session.cancel()

        LOGGER.info("advice_start fen=%s cap_ms=%d", request.fen, cap_ms)
        session.run(write)
        reason = self._end_reason(session)
        if session.failed:
            LOGGER.error(
                "advice_error reason=engine fen=%s detail=%s elapsed_ms=%d",
                request.fen,
                "the engine stopped without a bestmove",
                _elapsed_ms(state.started),
            )
        self._close_stream(state, reason)
        try:
            session.close()
        except OSError as failure:
            # E2 is already on the wire; a child that will not die is noise here.
            LOGGER.warning("advice_error reason=engine_shutdown detail=%s", failure)

    @staticmethod
    def _end_reason(session: SearchSession) -> str:
        """The E2 reason for a finished search.

        The engine failed, ran to the cap, or stopped early for one of two
        reasons: O2. A cancel on the cap's own tick is indistinguishable from
        the cap, and the cap is the honest label for it.
        """
        if session.failed:
            return END_ERROR
        if session.reached_deadline or not session.cancelled:
            return END_CAP
        return END_CANCEL

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

    def _send_json(self, status: HTTPStatus, message: dict[str, object]) -> None:
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


class _AdviceServer(ThreadingHTTPServer):
    """Every stream answers `Connection: close`; handler threads never block shutdown."""

    daemon_threads = True
    # How long ``shutdown()`` waits to notice the serve loop ended. The
    # default 0.5 s would delay every stop of the server for nothing.
    poll_interval = 0.05


def make_server(
    service: AdviceService,
    host: str,
    port: int,
    catalog: CatalogService | None = None,
) -> ThreadingHTTPServer:
    """Build the HTTP server bound to whatever listen address the process was given.

    ``catalog`` publishes the deal route on the same host (ADR-0013); without
    it the server answers advice only.
    """
    handler = type(
        "BoundAdviceHandler",
        (AdviceHandler,),
        {"service": service, "catalog": catalog},
    )
    return _AdviceServer((host, port), handler)
