"""Tests for the advice backend: wire shapes, the cap, cancel, and auth."""

from __future__ import annotations

import json
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

# Stands in for Stockfish: same UCI stdout shape, a few ticks, then bestmove.
_FAKE_ENGINE = """\
import sys, time
for line in sys.stdin:
    line = line.strip()
    if line.startswith("go movetime"):
        for depth in range(1, 200):
            print(f"info depth {depth} score cp {12 * depth} pv e2e4 e7e5", flush=True)
            time.sleep(0.02)
        print("bestmove e2e4", flush=True)
    elif line == "stop":
        print("bestmove e2e4", flush=True)
        break
    elif line == "quit":
        break
"""


def _engine_command(directory: Path) -> list[str]:
    path = directory / "fake_stockfish.py"
    path.write_text(_FAKE_ENGINE)
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

    def test_the_cap_holds_even_when_the_engine_never_stops(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            endless = Path(directory) / "endless.py"
            endless.write_text(
                "import sys, time\n"
                'for line in sys.stdin:\n'
                '    if line.startswith("go movetime"):\n'
                "        while True:\n"
                '            print("info depth 3 score cp 5 pv e2e4", flush=True)\n'
                "            time.sleep(0.01)\n"
            )
            search = StockfishSearch([sys.executable, str(endless)], START_FEN, 200)
            started = time.monotonic()
            ticks: list[AdviceUpdate] = []
            search.run(ticks.append)
            self.assertLess(time.monotonic() - started, 2)
            self.assertTrue(ticks)


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
        started = time.monotonic()
        status, content_type, text = self.post(port, {"fen": START_FEN, "time_ms": 2000, "api_key": KEY})
        elapsed = time.monotonic() - started
        self.assertEqual(status, 200)
        self.assertEqual(content_type, NDJSON)
        self.assertLess(elapsed, 1.5)
        messages = [json.loads(line) for line in text.splitlines() if line]
        self.assertEqual(messages[-1], {"reason": "cap"})
        updates = messages[:-1]
        self.assertTrue(updates)
        self.assertEqual(updates[0]["best_move_uci"], "e2e4")
        self.assertEqual(updates[0]["eval_cp"], 12)
        self.assertGreater(updates[-1]["eval_cp"], updates[0]["eval_cp"])

    def test_client_time_below_the_cap_is_the_cap(self) -> None:
        port = self.serve(self.factory, cap_ms=2000)
        started = time.monotonic()
        _, _, text = self.post(port, {"fen": START_FEN, "time_ms": 100, "api_key": KEY})
        self.assertLess(time.monotonic() - started, 2)
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

    def test_engine_failure_ends_with_error(self) -> None:
        port = self.serve(lambda request, cap_ms: StockfishSearch(["/nonexistent/stockfish"], request.fen, cap_ms))
        _, _, text = self.post(port, {"fen": START_FEN, "time_ms": 2000, "api_key": KEY})
        self.assertEqual(json.loads(text.splitlines()[-1]), {"reason": "error"})


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


if __name__ == "__main__":
    unittest.main()
