"""Tests for the advice backend: wire shapes, the cap, cancel, and auth."""

from __future__ import annotations

import json
import logging
import socket
import sys
import tempfile
import threading
import time
import unittest
from http.client import HTTPConnection
from pathlib import Path
from typing import Callable

from advice_backend.protocol import AdviceRequest, AdviceUpdate, parse_request
from advice_backend.server import ADVICE_PATH, AdviceHandler, AdviceService, make_server
from advice_backend.stockfish import StockfishSearch, parse_bestmove, parse_info_line

START_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
KEY = "test-key"
NDJSON = "application/x-ndjson"

# Stands in for Stockfish: same UCI stdout shape, ticks until its own cap or
# `stop`, bestmove, and reads commands while it searches like the real engine.
_FAKE_ENGINE = """\
import select, sys, time
searching = False
limit = 0.0
started = 0.0
depth = 0
while True:
    if searching:
        if depth == 0:
            started = time.monotonic()
        if time.monotonic() - started >= limit:
            print("bestmove e2e4", flush=True)
            searching = False
            continue
        depth += 1
        print(f"info depth {depth} score cp {12 * depth} pv e2e4 e7e5", flush=True)
        ready, _, _ = select.select([sys.stdin], [], [], 0.008)
        if not ready:
            continue
        line = sys.stdin.readline()
    else:
        line = sys.stdin.readline()
    if not line:
        break
    line = line.strip()
    if line.startswith("go movetime"):
        limit = float(line.split()[2]) / 1000
        depth = 0
        searching = True
    elif line == "stop":
        if searching:
            print("bestmove e2e4", flush=True)
        searching = False
    elif line == "quit":
        break
"""

# Stands in for an engine that never answers `stop` and never finishes early.
_ENDLESS_ENGINE = """\
import sys, time, itertools
depth = itertools.count(1)
for line in sys.stdin:
    if line.startswith("go movetime"):
        while True:
            print(f"info depth {next(depth)} score cp 5 pv e2e4", flush=True)
            time.sleep(0.01)
"""


def _engine_command(directory: Path) -> list[str]:
    path = directory / "fake_stockfish.py"
    path.write_text(_FAKE_ENGINE)
    return [sys.executable, str(path)]


def _endless_command(directory: Path) -> list[str]:
    path = directory / "endless_stockfish.py"
    path.write_text(_ENDLESS_ENGINE)
    return [sys.executable, str(path)]


def _search(command: list[str], request: AdviceRequest, cap_ms: int) -> StockfishSearch:
    return StockfishSearch(command, request.fen, cap_ms)


class ProtocolTests(unittest.TestCase):
    def test_request_requires_the_three_wire_fields(self) -> None:
        with self.assertRaises(ValueError):
            parse_request({"fen": START_FEN, "api_key": KEY})
        with self.assertRaises(ValueError):
            parse_request({"fen": START_FEN, "time_ms": "2000", "api_key": KEY})
        request = parse_request({"fen": START_FEN, "time_ms": 2000, "api_key": KEY})
        self.assertEqual(request.fen, START_FEN)
        self.assertEqual(request.time_ms, 2000)

    def test_update_carries_white_centipawns_and_optional_fields(self) -> None:
        message = AdviceUpdate(best_move_uci="e2e4", eval_cp=31, depth=12, time_ms=40).to_wire()
        self.assertEqual(message["eval_cp"], 31)
        self.assertEqual(message["depth"], 12)
        self.assertNotIn("mate_in", message)


class EngineParsingTests(unittest.TestCase):
    def test_white_to_move_keeps_the_engine_score(self) -> None:
        score = parse_info_line("info depth 10 score cp 40 pv e2e4 e7e5", START_FEN)
        assert score is not None
        self.assertEqual(score.eval_cp, 40)
        self.assertEqual(score.best_move_uci, "e2e4")
        self.assertEqual(score.depth, 10)

    def test_black_to_move_flips_to_white_view(self) -> None:
        black = START_FEN.replace(" w ", " b ")
        score = parse_info_line("info depth 8 score cp 40 pv e7e5", black)
        assert score is not None
        self.assertEqual(score.eval_cp, -40)
        self.assertIsNone(score.mate_in)
        mate = parse_info_line("info depth 8 score mate 3 pv e7e5", black)
        assert mate is not None
        self.assertEqual(mate.mate_in, -3)

    def test_lines_without_a_principal_variation_are_ignored(self) -> None:
        self.assertIsNone(parse_info_line("info depth 1 currmove e2e4", START_FEN))
        self.assertEqual(parse_bestmove("bestmove e2e4 ponder e7e5"), "e2e4")

    def test_depth_is_omitted_when_the_engine_sent_none(self) -> None:
        score = parse_info_line("info score cp 9 pv e2e4", START_FEN)
        assert score is not None
        self.assertIsNone(score.depth)
        self.assertNotIn("depth", AdviceUpdate(best_move_uci="e2e4", eval_cp=9, depth=score.depth).to_wire())

    def test_the_cap_holds_even_when_the_engine_never_stops(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            search = StockfishSearch(_endless_command(Path(directory)), START_FEN, 200)
            started = time.monotonic()
            ticks: list[AdviceUpdate] = []
            try:
                search.run(ticks.append)
            finally:
                search.close()
            self.assertLess(time.monotonic() - started, 1.0)
            self.assertTrue(ticks)


class CapPolicyTests(unittest.TestCase):
    """CFG.ADVICE_TIME_MS is the maximum think time (F-move-advice R7, CTR G2)."""

    def service(self, cap_ms: int) -> AdviceService:
        return AdviceService(api_key=KEY, cap_ms=cap_ms)

    def request(self, time_ms: int) -> AdviceRequest:
        return AdviceRequest(fen=START_FEN, time_ms=time_ms, api_key=KEY)

    def test_the_configured_cap_decides_when_the_client_asks_for_more(self) -> None:
        self.assertEqual(self.service(cap_ms=2000).search_cap_ms(self.request(5000)), 2000)
        self.assertEqual(self.service(cap_ms=5000).search_cap_ms(self.request(100000)), 5000)

    def test_a_shorter_client_cap_shortens_the_search(self) -> None:
        self.assertEqual(self.service(cap_ms=2000).search_cap_ms(self.request(400)), 400)

    def test_a_negative_client_cap_never_extends_the_search(self) -> None:
        self.assertEqual(self.service(cap_ms=2000).search_cap_ms(self.request(-1)), 0)


class _ServerCase(unittest.TestCase):
    def setUp(self) -> None:
        self._temp = tempfile.TemporaryDirectory()
        self.addCleanup(self._temp.cleanup)
        self.engine = _engine_command(Path(self._temp.name))

    def serve(self, factory: Callable[[AdviceRequest, int], StockfishSearch], cap_ms: int = 2000) -> int:
        service = AdviceService(api_key=KEY, cap_ms=cap_ms, search_factory=factory)
        server = make_server(service, "127.0.0.1", 0)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        self.addCleanup(server.server_close)
        self.addCleanup(server.shutdown)
        return int(server.server_address[1])

    def _request(self, connection: HTTPConnection, payload: dict[str, object]) -> None:
        body = json.dumps(payload)
        connection.request(
            "POST",
            ADVICE_PATH,
            body=body,
            headers={"Content-Type": "application/json", "Content-Length": str(len(body))},
        )

    def post(self, port: int, payload: dict[str, object]) -> tuple[int, str, str]:
        connection = HTTPConnection("127.0.0.1", port, timeout=10)
        self._request(connection, payload)
        response = connection.getresponse()
        text = response.read().decode("utf-8")
        status = response.status
        content_type = response.getheader("Content-Type", "")
        connection.close()
        return status, content_type, text


class StreamTests(_ServerCase):
    def factory(self, request: AdviceRequest, cap_ms: int) -> StockfishSearch:
        return _search(self.engine, request, cap_ms)

    def test_cap_ends_the_stream_with_white_view_updates(self) -> None:
        port = self.serve(self.factory, cap_ms=300)
        status, content_type, text = self.post(port, {"fen": START_FEN, "time_ms": 2000, "api_key": KEY})
        self.assertEqual(status, 200)
        self.assertEqual(content_type, NDJSON)
        messages = [json.loads(line) for line in text.splitlines() if line]
        self.assertEqual(messages[-1], {"reason": "cap"})
        updates = messages[:-1]
        self.assertTrue(updates)
        self.assertEqual(updates[0]["best_move_uci"], "e2e4")
        self.assertEqual(updates[0]["eval_cp"], 12)
        self.assertGreater(updates[-1]["eval_cp"], updates[0]["eval_cp"])

    def test_e2_is_delivered_within_the_cap_at_the_default_2000_ms(self) -> None:
        """ADR-0002 validation: advice ends by CFG.ADVICE_TIME_MS, measured on the wire."""
        port = self.serve(self.factory, cap_ms=2000)
        started = time.monotonic()
        status, _, text = self.post(port, {"fen": START_FEN, "time_ms": 2000, "api_key": KEY})
        elapsed_ms = (time.monotonic() - started) * 1000
        self.assertEqual(status, 200)
        self.assertLess(elapsed_ms, 2000)
        self.assertEqual(json.loads(text.splitlines()[-1]), {"reason": "cap"})

    def test_the_configured_cap_wins_over_a_longer_client_request(self) -> None:
        port = self.serve(lambda request, cap_ms: StockfishSearch(_endless_command(Path(self._temp.name)), request.fen, cap_ms), cap_ms=300)
        started = time.monotonic()
        status, _, text = self.post(port, {"fen": START_FEN, "time_ms": 100000, "api_key": KEY})
        self.assertEqual(status, 200)
        self.assertLess((time.monotonic() - started) * 1000, 1000)
        self.assertEqual(json.loads(text.splitlines()[-1]), {"reason": "cap"})

    def test_client_time_below_the_cap_stops_the_search_earlier(self) -> None:
        port = self.serve(lambda request, cap_ms: StockfishSearch(_endless_command(Path(self._temp.name)), request.fen, cap_ms), cap_ms=2000)
        started = time.monotonic()
        _, _, text = self.post(port, {"fen": START_FEN, "time_ms": 200, "api_key": KEY})
        self.assertLess((time.monotonic() - started) * 1000, 1000)
        self.assertEqual(json.loads(text.splitlines()[-1]), {"reason": "cap"})

    def test_wrong_key_does_not_open_a_search(self) -> None:
        opened: list[str] = []

        def factory(request: AdviceRequest, cap_ms: int) -> StockfishSearch:
            opened.append(request.fen)
            return _search(self.engine, request, cap_ms)

        port = self.serve(factory)
        status, _, text = self.post(port, {"fen": START_FEN, "time_ms": 2000, "api_key": "wrong"})
        self.assertEqual(status, 401)
        self.assertEqual(json.loads(text), {"reason": "error"})
        self.assertEqual(opened, [])

    def test_missing_key_ends_with_error(self) -> None:
        port = self.serve(self.factory)
        status, _, text = self.post(port, {"fen": START_FEN, "time_ms": 2000})
        self.assertEqual(status, 400)
        self.assertEqual(json.loads(text), {"reason": "error"})

    def test_engine_failure_ends_with_error_on_a_stream(self) -> None:
        port = self.serve(lambda request, cap_ms: StockfishSearch(["/nonexistent/stockfish"], request.fen, cap_ms))
        status, content_type, text = self.post(port, {"fen": START_FEN, "time_ms": 2000, "api_key": KEY})
        self.assertEqual(status, 200)
        self.assertEqual(content_type, NDJSON)
        lines = [line for line in text.splitlines() if line]
        self.assertEqual(lines, ['{"reason":"error"}'])


class ObservabilityTests(_ServerCase):
    """quality.md Observability: advice timing and errors are in the logs (ADR-0002 validation)."""

    def test_a_stream_logs_its_cap_and_its_end_record(self) -> None:
        port = self.serve(lambda request, cap_ms: StockfishSearch(_endless_command(Path(self._temp.name)), request.fen, cap_ms), cap_ms=200)
        with self.assertLogs("advice_backend", level="INFO") as logs:
            self.post(port, {"fen": START_FEN, "time_ms": 200, "api_key": KEY})
        self.assertTrue(any("advice_start" in line and "cap_ms=200" in line for line in logs.output), logs.output)

    def test_auth_failures_are_logged_as_errors(self) -> None:
        port = self.serve(lambda request, cap_ms: StockfishSearch(["/nonexistent/stockfish"], request.fen, cap_ms))
        with self.assertLogs("advice_backend", level="INFO") as logs:
            self.post(port, {"fen": START_FEN, "time_ms": 2000, "api_key": "wrong"})
        self.assertIn("advice_error reason=unauthorized", "\n".join(logs.output))


class CancelTests(_ServerCase):
    def test_client_gone_is_false_while_the_peer_is_connected(self) -> None:
        handler, client = self._connected_handler()
        self.assertFalse(handler.client_gone())
        client.close()

    def test_client_gone_is_true_once_the_peer_closed(self) -> None:
        handler, client = self._connected_handler()
        client.close()
        deadline = time.monotonic() + 2
        while not handler.client_gone() and time.monotonic() < deadline:
            time.sleep(0.01)
        self.assertTrue(handler.client_gone())

    def _connected_handler(self) -> tuple[AdviceHandler, socket.socket]:
        listener = socket.socket()
        listener.bind(("127.0.0.1", 0))
        listener.listen(1)
        self.addCleanup(listener.close)
        client = socket.socket()
        self.addCleanup(client.close)
        client.connect(listener.getsockname())
        accepted, _ = listener.accept()
        self.addCleanup(accepted.close)
        handler = AdviceHandler.__new__(AdviceHandler)
        handler.connection = accepted
        return handler, client


class CancelOnTheWireTests(_ServerCase):
    """O2 end to end: a stop mid-stream ends `cancel`, with no late update after it."""

    def test_stop_mid_stream_ends_with_cancel_and_drops_late_ticks(self) -> None:
        cancelled = threading.Event()

        class CancellingSearch(StockfishSearch):
            """Stops its own search once the first tick has reached the wire."""

            def request_stop(self) -> None:
                cancelled.set()
                super().request_stop()

            def _read_until(self, deadline: float, on_update, started: float) -> None:  # type: ignore[no-untyped-def]
                on_update(AdviceUpdate(best_move_uci="e2e4", eval_cp=12))
                self.request_stop()

        port = self.serve(
            lambda request, cap_ms: CancellingSearch(_endless_command(Path(self._temp.name)), request.fen, cap_ms),
            cap_ms=5000,
        )
        started = time.monotonic()
        status, content_type, text = self.post(port, {"fen": START_FEN, "time_ms": 5000, "api_key": KEY})
        elapsed_ms = (time.monotonic() - started) * 1000
        self.assertEqual(status, 200)
        self.assertEqual(content_type, NDJSON)
        self.assertTrue(cancelled.is_set())
        self.assertLess(elapsed_ms, 2000, "a cancel must end the stream promptly, not at the cap")
        messages = [json.loads(line) for line in text.splitlines() if line]
        self.assertEqual(messages[-1], {"reason": "cancel"})
        self.assertEqual(len(messages), 2, "no update follows the cancel")

    def test_a_client_that_closes_mid_stream_stops_the_search(self) -> None:
        stopped = threading.Event()

        class RecordingSearch(StockfishSearch):
            def request_stop(self) -> None:
                stopped.set()
                super().request_stop()

        port = self.serve(
            lambda request, cap_ms: RecordingSearch(_endless_command(Path(self._temp.name)), request.fen, cap_ms),
            cap_ms=5000,
        )
        connection = HTTPConnection("127.0.0.1", port, timeout=10)
        self._request(connection, {"fen": START_FEN, "time_ms": 5000, "api_key": KEY})
        response = connection.getresponse()
        self.assertEqual(response.status, 200)
        self.assertTrue(response.read1(4096))
        started = time.monotonic()
        response.close()
        connection.close()
        self.assertTrue(stopped.wait(timeout=2), "the cancel did not reach the search")
        self.assertLess((time.monotonic() - started) * 1000, 500)


class SessionTests(unittest.TestCase):
    def test_ticks_are_dropped_once_cancelled(self) -> None:
        from advice_backend.server import SearchSession

        class ScriptedSearch(StockfishSearch):
            def run(self, on_update) -> None:  # type: ignore[no-untyped-def]
                on_update(AdviceUpdate(best_move_uci="e2e4", eval_cp=10))
                self.script = on_update

        search = ScriptedSearch(["unused"], START_FEN, 100)
        session = SearchSession(search)
        seen: list[AdviceUpdate] = []
        session.run(seen.append)
        self.assertEqual(len(seen), 1)
        session.cancel()
        search.script(AdviceUpdate(best_move_uci="e2e4", eval_cp=99))
        self.assertEqual(len(seen), 1)
        self.assertTrue(session.cancelled)


if __name__ == "__main__":
    unittest.main()
