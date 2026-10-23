"""Tests for the puzzle catalog service: one-record deals, DIF.Y1, auth, and the rate limit."""

from __future__ import annotations

import contextlib
import csv
import io
import json
import tempfile
import threading
import unittest
from http.client import HTTPConnection
from pathlib import Path

from advice_backend.catalog import (
    CATALOG_PATH,
    SNAPSHOT_ID,
    CatalogRecord,
    CatalogService,
    CatalogStore,
    RateLimiter,
    parse_deal_request,
    parse_record,
    select_puzzle,
)
from advice_backend.server import AdviceService, make_server

KEY = "test-key"
SNAPSHOT_KEYS = {
    "snapshot_id",
    "puzzle_id",
    "fen",
    "moves",
    "rating",
    "rating_deviation",
    "popularity",
    "nb_plays",
    "themes",
    "game_url",
    "opening_tags",
    "daily_date",
    "any_checkmate_wins",
}


def _record(puzzle_id: str, rating: int, themes: str = "") -> CatalogRecord:
    return CatalogRecord(
        puzzle_id=puzzle_id,
        fen="6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1",
        moves=("a1a8", "g8h8"),
        rating=rating,
        rating_deviation=80,
        popularity=90,
        nb_plays=1000,
        themes=tuple(themes.split()),
        game_url="https://lichess.org/example",
        opening_tags="",
        daily_date="",
        any_checkmate_wins="mateIn1" in themes.split(),
    )


def _store(*records: CatalogRecord) -> CatalogStore:
    return CatalogStore(list(records))


class ParseTests(unittest.TestCase):
    def test_a_row_becomes_every_f1_to_f13_field(self) -> None:
        record = parse_record(
            {
                "PuzzleId": "abc12",
                "FEN": "6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1",
                "Moves": "a1a8 g8h8",
                "Rating": "1500",
                "RatingDeviation": "80",
                "Popularity": "90",
                "NbPlays": "1000",
                "Themes": "mateIn1 endgame",
                "GameUrl": "https://lichess.org/x",
                "OpeningTags": "",
                "DailyDate": "",
            }
        )
        self.assertEqual(record.puzzle_id, "abc12")
        self.assertEqual(record.moves, ("a1a8", "g8h8"))
        self.assertEqual(record.rating, 1500)
        self.assertTrue(record.any_checkmate_wins)
        self.assertEqual(set(record.wire()), SNAPSHOT_KEYS)
        self.assertEqual(record.wire()["snapshot_id"], SNAPSHOT_ID)

    def test_a_row_with_fewer_than_two_moves_is_refused_on_ingest(self) -> None:
        with self.assertRaises(ValueError):
            parse_record({"PuzzleId": "x", "FEN": "8/8/8/8/8/8/8/K6k w - - 0 1", "Moves": "a1a8", "Rating": "1", "RatingDeviation": "1", "Popularity": "1", "NbPlays": "1"})

    def test_mate_in_one_is_derived_from_themes_not_from_the_file(self) -> None:
        common = {"PuzzleId": "x", "FEN": "8/8/8/8/8/8/8/K6k w - - 0 1", "Rating": "1", "RatingDeviation": "1", "Popularity": "1", "NbPlays": "1"}
        self.assertFalse(parse_record({**common, "Moves": "a1a8 b8c8"}).any_checkmate_wins)
        with self.assertRaises(ValueError):
            parse_record({**common, "Moves": "a1a8 b8c8 c8d8", "Themes": "mateIn1"})

    def test_an_empty_rating_is_refused(self) -> None:
        with self.assertRaises(ValueError):
            parse_record({"PuzzleId": "x", "FEN": "8/8/8/8/8/8/8/K6k w - - 0 1", "Moves": "a1a8 b8c8", "Rating": "", "RatingDeviation": "1", "Popularity": "1", "NbPlays": "1"})


class SelectionTests(unittest.TestCase):
    """DIF.Y1 / F-puzzle-catalog I1 and D1."""

    def test_the_nearest_rating_inside_the_band_wins(self) -> None:
        picked = select_puzzle([_record("far", 1400), _record("near", 1050), _record("mid", 950)], 1000.0, ())
        assert picked is not None
        self.assertEqual(picked.puzzle_id, "near")

    def test_a_recently_solved_puzzle_is_preferred_against(self) -> None:
        picked = select_puzzle([_record("recent", 1000), _record("fresh", 1090)], 1000.0, ("recent",))
        assert picked is not None
        self.assertEqual(picked.puzzle_id, "fresh")

    def test_the_band_widens_by_the_configured_step_until_one_fits(self) -> None:
        # 1200 is outside ±100 but inside ±150 once the band widens by 50.
        picked = select_puzzle([_record("wide", 1200)], 1000.0, ())
        assert picked is not None
        self.assertEqual(picked.puzzle_id, "wide")

    def test_a_recent_puzzle_is_allowed_once_the_band_spans_the_snapshot(self) -> None:
        picked = select_puzzle([_record("only", 1000)], 1000.0, ("only",))
        assert picked is not None
        self.assertEqual(picked.puzzle_id, "only")

    def test_the_recent_window_is_the_configured_length(self) -> None:
        picked = select_puzzle(
            [_record("old", 1000), _record("new", 1000)],
            1000.0,
            ("old", "new"),
            recent_window=1,
        )
        assert picked is not None
        self.assertEqual(picked.puzzle_id, "old", "only the newest id is inside a window of one")

    def test_an_unseen_puzzle_outranks_a_just_solved_one_inside_the_band(self) -> None:
        # #329 verification: a puzzle solved on the previous deal sat at the
        # player's Elo, while an unseen one was only 200 away. Widening must
        # reach the unseen puzzle rather than re-deal the recent one.
        picked = select_puzzle(
            [_record("recent", 1480), _record("unseen", 1680)], 1480.0, ("recent",)
        )
        assert picked is not None
        self.assertEqual(picked.puzzle_id, "unseen")

    def test_an_unseen_puzzle_one_widen_step_away_beats_a_tighter_recent_one(self) -> None:
        # #329 verification: recent 1570 is outside ±100 and unseen 1591 is
        # outside it too; one widen step reaches both, and the unseen one wins.
        picked = select_puzzle(
            [_record("recent", 1570), _record("unseen", 1591)], 1480.0, ("recent",)
        )
        assert picked is not None
        self.assertEqual(picked.puzzle_id, "unseen")

    def test_an_unseen_puzzle_far_outside_the_band_beats_the_previous_deal(self) -> None:
        # #329 verification: a 1000-Elo-away unseen puzzle still outranks the
        # puzzle solved one deal ago; a recent id is the last rule relaxed.
        picked = select_puzzle(
            [_record("recent", 1480), _record("far", 2480)], 1480.0, ("recent",)
        )
        assert picked is not None
        self.assertEqual(picked.puzzle_id, "far")

    def test_the_nearest_unseen_puzzle_wins_once_the_band_spans_them_all(self) -> None:
        picked = select_puzzle(
            [_record("recent", 1000), _record("nearer", 1900), _record("farther", 2600)],
            1000.0,
            ("recent",),
        )
        assert picked is not None
        self.assertEqual(picked.puzzle_id, "nearer")

    def test_an_empty_snapshot_deals_nothing(self) -> None:
        self.assertIsNone(select_puzzle([], 1000.0, ()))


class DealRequestTests(unittest.TestCase):
    def test_the_three_wire_fields_are_required(self) -> None:
        with self.assertRaises(ValueError):
            parse_deal_request({"recent_solved": [], "api_key": KEY})
        with self.assertRaises(ValueError):
            parse_deal_request({"player_elo": True, "recent_solved": [], "api_key": KEY})
        with self.assertRaises(ValueError):
            parse_deal_request({"player_elo": 1000, "recent_solved": "x", "api_key": KEY})
        request = parse_deal_request({"player_elo": 1000, "recent_solved": ["a", "b"], "api_key": KEY})
        self.assertEqual(request.player_elo, 1000.0)
        self.assertEqual(request.recent_solved, ("a", "b"))


class RateLimiterTests(unittest.TestCase):
    def test_the_thirtieth_request_in_a_minute_is_the_last_one_allowed(self) -> None:
        limiter = RateLimiter(30, clock=lambda: 0.0)
        self.assertEqual(sum(1 for _ in range(30) if limiter.allow(KEY)), 30)
        self.assertFalse(limiter.allow(KEY))

    def test_counts_are_per_key(self) -> None:
        limiter = RateLimiter(1, clock=lambda: 0.0)
        self.assertTrue(limiter.allow("a"))
        self.assertFalse(limiter.allow("a"))
        self.assertTrue(limiter.allow("b"))

    def test_a_minute_after_the_first_request_the_key_may_deal_again(self) -> None:
        now = [0.0]
        limiter = RateLimiter(1, clock=lambda: now[0])
        self.assertTrue(limiter.allow(KEY))
        now[0] = 61.0
        self.assertTrue(limiter.allow(KEY))


class ServiceTests(unittest.TestCase):
    def service(self, *records: CatalogRecord, rate_limit: int = 30) -> CatalogService:
        return CatalogService(_store(*records), KEY, rate_limit=rate_limit)

    def test_a_valid_key_gets_exactly_one_record(self) -> None:
        record = self.service(_record("a", 1000)).deal(parse_deal_request({"player_elo": 1000, "recent_solved": [], "api_key": KEY}))
        assert record is not None
        self.assertEqual(record["puzzle_id"], "a")
        self.assertEqual(set(record), SNAPSHOT_KEYS)

    def test_a_missing_or_wrong_key_gets_nothing(self) -> None:
        service = self.service(_record("a", 1000))
        self.assertIsNone(service.deal(parse_deal_request({"player_elo": 1000, "recent_solved": [], "api_key": "wrong"})))
        self.assertIsNone(service.deal(parse_deal_request({"player_elo": 1000, "recent_solved": [], "api_key": ""})))

    def test_a_rapid_fire_deal_gets_nothing(self) -> None:
        service = self.service(_record("a", 1000), rate_limit=1)
        request = {"player_elo": 1000, "recent_solved": [], "api_key": KEY}
        self.assertIsNotNone(service.deal(parse_deal_request(request)))
        self.assertIsNone(service.deal(parse_deal_request(request)))

    def test_an_empty_snapshot_deals_nothing(self) -> None:
        self.assertIsNone(self.service().deal(parse_deal_request({"player_elo": 1000, "recent_solved": [], "api_key": KEY})))


class SnapshotFileTests(unittest.TestCase):
    def setUp(self) -> None:
        self._temp = tempfile.TemporaryDirectory()
        self.addCleanup(self._temp.cleanup)
        self.root = Path(self._temp.name)

    def test_build_snapshot_reads_every_row_and_publishes_one_list(self) -> None:
        from advice_backend.catalog import build_snapshot

        source = self.root / "export.csv"
        with open(source, "w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=["PuzzleId", "FEN", "Moves", "Rating", "RatingDeviation", "Popularity", "NbPlays", "Themes", "GameUrl", "OpeningTags", "DailyDate"])
            writer.writeheader()
            writer.writerow({"PuzzleId": "a", "FEN": "8/8/8/8/8/8/8/K6k w - - 0 1", "Moves": "a1a8 b8c8", "Rating": "1200", "RatingDeviation": "80", "Popularity": "1", "NbPlays": "2", "Themes": "mateIn1", "GameUrl": "", "OpeningTags": "", "DailyDate": ""})
        out = self.root / "snapshot.json"
        self.assertEqual(build_snapshot(source, out), 1)
        self.assertEqual(len(CatalogStore.from_json(out)), 1)
        self.assertFalse(out.with_suffix(".json.part").exists(), "the staging file is renamed, never left behind")

    def test_a_snapshot_with_an_invalid_row_fails_rather_than_serving_part_of_it(self) -> None:
        from advice_backend.catalog import build_snapshot

        source = self.root / "export.csv"
        with open(source, "w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=["PuzzleId", "FEN", "Moves", "Rating", "RatingDeviation", "Popularity", "NbPlays", "Themes", "GameUrl", "OpeningTags", "DailyDate"])
            writer.writeheader()
            writer.writerow({"PuzzleId": "a", "FEN": "8/8/8/8/8/8/8/K6k w - - 0 1", "Moves": "a1a8", "Rating": "1200", "RatingDeviation": "80", "Popularity": "1", "NbPlays": "2", "Themes": "", "GameUrl": "", "OpeningTags": "", "DailyDate": ""})
        out = self.root / "snapshot.json"
        with self.assertRaises(ValueError):
            build_snapshot(source, out)
        self.assertFalse(out.exists(), "nothing is published when a row is refused")


class IntegrityTests(unittest.TestCase):
    """SCH-puzzle-catalog I1–I3, recorded on #329 as host-side checks."""

    def _snapshot(self, rows: list[dict[str, str]]) -> Path:
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        path = Path(temp.name) / "snapshot.json"
        path.write_text(json.dumps(rows), encoding="utf-8")
        return path

    def _row(self, puzzle_id: str = "a", moves: str = "a1a8 b8c8", themes: str = "") -> dict[str, str]:
        return {"PuzzleId": puzzle_id, "FEN": "8/8/8/8/8/8/8/K6k w - - 0 1", "Moves": moves, "Rating": "1200", "RatingDeviation": "80", "Popularity": "1", "NbPlays": "2", "Themes": themes, "GameUrl": "", "OpeningTags": "", "DailyDate": ""}

    def test_the_record_count_is_checked_against_i1(self) -> None:
        from advice_backend.catalog import check_snapshot

        failures = check_snapshot(self._snapshot([self._row()]))
        self.assertEqual(len(failures), 1)
        self.assertTrue(failures[0].startswith("I1:"), failures)

    def test_a_short_moves_list_is_caught_by_i2(self) -> None:
        from advice_backend.catalog import check_snapshot

        self.assertTrue(any("fewer than two moves" in failure for failure in check_snapshot(self._snapshot([self._row(moves="a1a8")]))))

    def test_a_mate_in_one_with_more_than_two_moves_is_caught_by_i3(self) -> None:
        from advice_backend.catalog import check_snapshot

        failures = check_snapshot(self._snapshot([self._row(moves="a1a8 b8c8 c8d8", themes="mateIn1")]))
        self.assertTrue(any("mateIn1" in failure for failure in failures), failures)

    def test_the_check_command_exits_non_zero_on_a_failing_snapshot(self) -> None:
        from advice_backend.catalog import main

        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(main(["check", str(self._snapshot([self._row()]))]), 1)

    def test_a_slice_passes_i1_at_its_own_count(self) -> None:
        # #329 verification AC5: the deploy path must be demonstrable on a
        # prepared slice without the host-side export.
        from advice_backend.catalog import check_snapshot

        slice_path = self._snapshot([self._row("a"), self._row("b")])
        self.assertEqual(check_snapshot(slice_path, expected_count=2), [])

    def test_a_slice_still_fails_i1_at_a_count_it_does_not_hold(self) -> None:
        from advice_backend.catalog import check_snapshot

        failures = check_snapshot(self._snapshot([self._row()]), expected_count=2)
        self.assertEqual(failures, ["I1: expected 2 records, found 1"])

    def test_the_expected_count_defaults_to_the_served_snapshot(self) -> None:
        from advice_backend.catalog import EXPECTED_RECORD_COUNT

        self.assertEqual(EXPECTED_RECORD_COUNT, 6_157_341)

    def test_the_check_command_accepts_a_slice_count(self) -> None:
        from advice_backend.catalog import main

        slice_path = self._snapshot([self._row(), self._row("b")])
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(main(["check", str(slice_path), "--expected-count", "2"]), 0)
            self.assertEqual(main(["check", str(slice_path), "--expected-count", "3"]), 1)

    def test_the_build_command_writes_a_checkable_snapshot(self) -> None:
        from advice_backend.catalog import main

        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        source = Path(temp.name) / "export.csv"
        with open(source, "w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(self._row()))
            writer.writeheader()
            writer.writerow(self._row())
        out = Path(temp.name) / "snapshot.json"
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(main(["build", str(source), str(out)]), 0)
        self.assertTrue(out.exists())


class RouteTests(unittest.TestCase):
    """CTR-puzzle-catalog-read on the wire, on the advice server's own host."""

    def setUp(self) -> None:
        self.catalog = CatalogService(_store(_record("a", 1000), _record("b", 1600)), KEY, rate_limit=2)
        service = AdviceService(api_key=KEY, cap_ms=100)
        self.server = make_server(service, "127.0.0.1", 0, self.catalog)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.addCleanup(self.server.server_close)
        self.addCleanup(self.server.shutdown)
        self.port = int(self.server.server_address[1])

    def post(self, payload: dict[str, object], path: str = CATALOG_PATH) -> tuple[int, dict[str, str], str]:
        body = json.dumps(payload)
        connection = HTTPConnection("127.0.0.1", self.port, timeout=10)
        connection.request("POST", path, body=body, headers={"Content-Type": "application/json", "Content-Length": str(len(body))})
        response = connection.getresponse()
        text = response.read().decode("utf-8")
        status = response.status
        headers = dict(response.getheaders())
        connection.close()
        return status, headers, text

    def test_a_valid_deal_returns_one_record_at_the_players_level(self) -> None:
        status, headers, text = self.post({"player_elo": 1000, "recent_solved": [], "api_key": KEY})
        self.assertEqual(status, 200)
        record = json.loads(text)
        self.assertIsInstance(record, dict)
        self.assertNotIsInstance(record, list)
        self.assertEqual(record["puzzle_id"], "a")
        self.assertEqual(record["snapshot_id"], SNAPSHOT_ID)

    def test_a_record_body_is_never_a_list_or_a_page(self) -> None:
        _, _, text = self.post({"player_elo": 1600, "recent_solved": [], "api_key": KEY})
        self.assertIsInstance(json.loads(text), dict)

    def test_a_missing_or_wrong_key_returns_no_record(self) -> None:
        for key in ("", "wrong"):
            status, _, text = self.post({"player_elo": 1000, "recent_solved": [], "api_key": key})
            self.assertEqual(status, 401)
            self.assertNotIn("puzzle_id", text)

    def test_a_malformed_request_returns_no_record(self) -> None:
        status, _, text = self.post({"recent_solved": [], "api_key": KEY})
        self.assertEqual(status, 400)
        self.assertNotIn("puzzle_id", text)

    def test_a_rapid_fire_deal_returns_no_record(self) -> None:
        payload = {"player_elo": 1000, "recent_solved": [], "api_key": KEY}
        self.assertEqual(self.post(payload)[0], 200)
        self.assertEqual(self.post(payload)[0], 200)
        status, _, text = self.post(payload)
        self.assertEqual(status, 503)
        self.assertNotIn("puzzle_id", text)

    def test_the_advice_route_still_owns_its_path(self) -> None:
        status, _, _ = self.post({"fen": "8/8/8/8/8/8/8/K6k w - - 0 1", "time_ms": 1, "api_key": KEY}, path="/advice")
        self.assertNotEqual(status, 404)

    def test_no_other_catalog_path_is_served(self) -> None:
        for path in ("/catalog", "/catalog/list", "/catalog/deal.csv", "/advice.json"):
            status, _, _ = self.post({"api_key": KEY}, path=path)
            self.assertEqual(status, 404, path)


class DisabledRouteTests(unittest.TestCase):
    def test_a_server_without_a_snapshot_answers_the_deal_route_with_no_record(self) -> None:
        server = make_server(AdviceService(api_key=KEY), "127.0.0.1", 0)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        self.addCleanup(server.server_close)
        self.addCleanup(server.shutdown)
        body = json.dumps({"player_elo": 1000, "recent_solved": [], "api_key": KEY})
        connection = HTTPConnection("127.0.0.1", int(server.server_address[1]), timeout=10)
        connection.request("POST", CATALOG_PATH, body=body, headers={"Content-Type": "application/json", "Content-Length": str(len(body))})
        response = connection.getresponse()
        self.assertEqual(response.status, 503)
        self.assertNotIn("puzzle_id", response.read().decode("utf-8"))
        connection.close()


if __name__ == "__main__":
    unittest.main()
