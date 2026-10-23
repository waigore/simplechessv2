"""Puzzle catalog service: the host-side deal read (CMP-catalog-service, ADR-0013).

The catalog is a second route on this server. It stores the ADR-0008 snapshot
and answers a deal with exactly one ``SCH-puzzle-catalog`` F1–F13 record,
chosen here by ``DIF.Y1``. The browser never receives the export, a page, or a
candidate set: a failed read is O2 (no record) and the client deals nothing
(``F-puzzle-catalog`` X2, ``FAIL.T14``).

Wire names follow ``CTR-puzzle-catalog-read``: the request carries
``player_elo``, ``recent_solved``, and ``api_key``; the response is the record.
"""

from __future__ import annotations

import csv
import hmac
import itertools
import json
import logging
import os
import threading
import time
from collections import deque
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

LOGGER = logging.getLogger("advice_backend")

# CTR-puzzle-catalog-read O1: the one deal route on the advice server's host.
CATALOG_PATH = "/catalog/deal"

# CFG.ELO_MATCH_RANGE, CFG.ELO_BAND_WIDEN, CFG.ELO_RECENT_WINDOW (configuration.md).
DEFAULT_ELO_MATCH_RANGE = 100
DEFAULT_ELO_BAND_WIDEN = 50
DEFAULT_ELO_RECENT_WINDOW = 20
# configuration.md T11: requests per key per minute.
DEFAULT_RATE_LIMIT = 30
# SCH-puzzle-catalog F1: the only snapshot this service serves (L3).
SNAPSHOT_ID = "2026-10-05"

# The Lichess export columns (F-puzzle-catalog R3, ADR-0008).
_CSV_COLUMNS = (
    "PuzzleId",
    "FEN",
    "Moves",
    "Rating",
    "RatingDeviation",
    "Popularity",
    "NbPlays",
    "Themes",
    "GameUrl",
    "OpeningTags",
)


@dataclass(frozen=True)
class CatalogRecord:
    """One ``SCH-puzzle-catalog`` record. Selection reads only F2 and F5."""

    puzzle_id: str
    fen: str
    moves: tuple[str, ...]
    rating: int
    rating_deviation: int
    popularity: int
    nb_plays: int
    themes: tuple[str, ...]
    game_url: str
    opening_tags: str
    daily_date: str
    any_checkmate_wins: bool

    def wire(self) -> dict[str, object]:
        """The F1–F13 record as CTR-puzzle-catalog-read O1 returns it."""
        return {
            "snapshot_id": SNAPSHOT_ID,
            "puzzle_id": self.puzzle_id,
            "fen": self.fen,
            "moves": list(self.moves),
            "rating": self.rating,
            "rating_deviation": self.rating_deviation,
            "popularity": self.popularity,
            "nb_plays": self.nb_plays,
            "themes": list(self.themes),
            "game_url": self.game_url,
            "opening_tags": self.opening_tags,
            "daily_date": self.daily_date,
            "any_checkmate_wins": self.any_checkmate_wins,
        }


@dataclass(frozen=True)
class DealRequest:
    """CTR-puzzle-catalog-read O1 request: Elo, recent solved ids, and the key."""

    player_elo: float
    recent_solved: tuple[str, ...]
    api_key: str


def _require_int(record: dict[str, str], column: str) -> int:
    raw = record.get(column, "").strip()
    if not raw:
        raise ValueError(f"{column} is empty")
    return int(raw)


def parse_record(record: dict[str, str]) -> CatalogRecord:
    """Read one Lichess CSV row as a record. Raises ValueError when it is malformed."""
    moves = tuple(move for move in record.get("Moves", "").split() if move)
    # I2: moves length >= 2, so the derived required sequence has length >= 1.
    if len(moves) < 2:
        raise ValueError(f"{record.get('PuzzleId')}: fewer than two moves")
    fen = record.get("FEN", "").strip()
    if not fen:
        raise ValueError("FEN is empty")
    themes = tuple(theme.strip() for theme in record.get("Themes", "").split() if theme.strip())
    # I3 is derived, never trusted from the file.
    mate_in_one = "mateIn1" in themes
    if mate_in_one and len(moves) != 2:
        raise ValueError(f"{record.get('PuzzleId')}: mateIn1 needs exactly two moves")
    return CatalogRecord(
        puzzle_id=record.get("PuzzleId", "").strip(),
        fen=fen,
        moves=moves,
        rating=_require_int(record, "Rating"),
        rating_deviation=_require_int(record, "RatingDeviation"),
        popularity=_require_int(record, "Popularity"),
        nb_plays=_require_int(record, "NbPlays"),
        themes=themes,
        game_url=record.get("GameUrl", "").strip(),
        opening_tags=record.get("OpeningTags", "").strip(),
        daily_date=record.get("DailyDate", "").strip(),
        any_checkmate_wins=mate_in_one,
    )


def select_puzzle(
    records: list[CatalogRecord],
    player_elo: float,
    recent_solved: tuple[str, ...],
    *,
    match_range: int = DEFAULT_ELO_MATCH_RANGE,
    band_widen: int = DEFAULT_ELO_BAND_WIDEN,
    recent_window: int = DEFAULT_ELO_RECENT_WINDOW,
) -> CatalogRecord | None:
    """Pick the next puzzle per ``DIF.Y1`` (``F-puzzle-catalog`` I1, ``D1``).

    Prefer a Rating within ±``match_range`` of ``player_elo`` and an id outside
    the last ``recent_window`` solved ids. If none fit, widen the band by
    ``band_widen`` and/or allow a recent id, repeat until one is found. Only
    None when the snapshot is empty.
    """
    if not records:
        return None
    recent = set(recent_solved[-recent_window:]) if recent_window > 0 else set()
    fresh = [record for record in records if record.puzzle_id not in recent]
    solved = [record for record in records if record.puzzle_id in recent]
    # Relax DIF.Y1 rule by rule: an unseen puzzle wins at any band before a
    # recently solved one at the same or a tighter band; the recent-id rule is
    # relaxed last, only once widening has spanned the whole snapshot.
    for group in (fresh, solved):
        picked = _nearest_in_band(group, player_elo, match_range, band_widen)
        if picked is not None:
            return picked
    return None


def _nearest_in_band(
    group: list[CatalogRecord], player_elo: float, match_range: int, band_widen: int
) -> CatalogRecord | None:
    """Widen ``match_range`` by ``band_widen`` until one record fits, nearest first."""
    if not group:
        return None
    for band in itertools.count(0):
        window = match_range + band * band_widen
        inside = [record for record in group if abs(record.rating - player_elo) <= window]
        if inside:
            return min(inside, key=lambda record: abs(record.rating - player_elo))
        # Once the band spans the group, the nearest puzzle is the answer;
        # widening past that changes no outcome.
        if window >= _widest_gap(group, player_elo):
            return min(group, key=lambda record: abs(record.rating - player_elo))
    return None


def _widest_gap(records: list[CatalogRecord], player_elo: float) -> float:
    """How far the band must widen before it reaches the farthest-rated record."""
    return max(abs(record.rating - player_elo) for record in records)


class CatalogStore:
    """The immutable served snapshot (L2–L3): read whole, never edited.

    The export is read once from a local path. Nothing here writes, pages, or
    exports it, and the store is the only thing that knows the snapshot's
    bytes.
    """

    def __init__(self, records: list[CatalogRecord]) -> None:
        self._records = tuple(records)

    def __len__(self) -> int:
        return len(self._records)

    @property
    def records(self) -> tuple[CatalogRecord, ...]:
        return self._records

    @classmethod
    def from_csv(cls, path: str | Path) -> CatalogStore:
        """Read the Lichess CSV export into memory, one record per row."""
        with open(path, newline="", encoding="utf-8") as handle:
            return cls([parse_record(row) for row in csv.DictReader(handle)])

    @classmethod
    def from_json(cls, path: str | Path) -> CatalogStore:
        """Read the prepared snapshot ``build_snapshot`` writes."""
        with open(path, encoding="utf-8") as handle:
            rows = json.load(handle)
        return cls([parse_record(row) for row in rows])


class RateLimiter:
    """T11: per-key request counts in the last minute, refused above the limit."""

    def __init__(self, limit: int, clock: Callable[[], float] = time.monotonic) -> None:
        self._limit = limit
        self._clock = clock
        self._lock = threading.Lock()
        self._requests: dict[str, deque[float]] = {}

    def allow(self, key: str) -> bool:
        """Count this request; False once the key went over its per-minute limit."""
        now = self._clock()
        with self._lock:
            recent = self._requests.setdefault(key, deque())
            while recent and now - recent[0] >= 60.0:
                recent.popleft()
            if len(recent) >= self._limit:
                return False
            recent.append(now)
            return True


class CatalogService:
    """Authorizes and selects one deal (CMP-catalog-service R1–R8)."""

    def __init__(
        self,
        store: CatalogStore,
        api_key: str,
        *,
        rate_limit: int = DEFAULT_RATE_LIMIT,
        match_range: int = DEFAULT_ELO_MATCH_RANGE,
        band_widen: int = DEFAULT_ELO_BAND_WIDEN,
        recent_window: int = DEFAULT_ELO_RECENT_WINDOW,
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        self._store = store
        self._api_key = api_key
        self._match_range = match_range
        self._band_widen = band_widen
        self._recent_window = recent_window
        self._limiter = RateLimiter(rate_limit, clock)

    @property
    def store(self) -> CatalogStore:
        return self._store

    def authorizes(self, request: DealRequest) -> bool:
        """R4: only the configured advice key opens a deal."""
        return hmac.compare_digest(request.api_key, self._api_key)

    def rate_allows(self, request: DealRequest) -> bool:
        """R5: a refused rapid-fire request is the same failure as a wrong key."""
        return self._limiter.allow(request.api_key)

    def deal(self, request: DealRequest) -> dict[str, object] | None:
        """O1: one F1–F13 record, or None when any failed read applies (O2).

        None covers a missing or wrong key, a rapid-fire refusal, and an empty
        snapshot. The caller sends no record, so nothing is dealt and
        ``GS.playerElo`` is unchanged (``FAIL.T14``).
        """
        if not self.authorizes(request):
            LOGGER.warning("catalog_error reason=unauthorized")
            return None
        if not self.rate_allows(request):
            LOGGER.warning("catalog_error reason=rate_limited")
            return None
        record = select_puzzle(
            list(self._store.records),
            request.player_elo,
            request.recent_solved,
            match_range=self._match_range,
            band_widen=self._band_widen,
            recent_window=self._recent_window,
        )
        if record is None:
            LOGGER.error("catalog_error reason=empty_snapshot")
            return None
        LOGGER.info("catalog_deal puzzle_id=%s player_elo=%s", record.puzzle_id, request.player_elo)
        return record.wire()


def parse_deal_request(payload: object) -> DealRequest:
    """Read an O1 request. Raises ValueError when a required field is malformed."""
    if not isinstance(payload, dict):
        raise ValueError("request must be a JSON object")
    player_elo = payload.get("player_elo")
    if isinstance(player_elo, bool) or not isinstance(player_elo, (int, float)):
        raise ValueError("player_elo must be a number")
    recent = payload.get("recent_solved", [])
    if not isinstance(recent, list) or not all(isinstance(item, str) for item in recent):
        raise ValueError("recent_solved must be a list of strings")
    api_key = payload.get("api_key")
    if not isinstance(api_key, str):
        raise ValueError("api_key must be a string")
    return DealRequest(player_elo=float(player_elo), recent_solved=tuple(recent), api_key=api_key)


def build_snapshot(csv_path: str | Path, out_path: str | Path) -> int:
    """Prepare the export for serving: one JSON list of validated records.

    Every row is read through ``parse_record``, so I2 and I3 are checked on
    the way in rather than trusted once served (L2: no edit after this).
    Returns the record count.
    """
    store = CatalogStore.from_csv(csv_path)
    rows = [
        {
            "PuzzleId": record.puzzle_id,
            "FEN": record.fen,
            "Moves": " ".join(record.moves),
            "Rating": str(record.rating),
            "RatingDeviation": str(record.rating_deviation),
            "Popularity": str(record.popularity),
            "NbPlays": str(record.nb_plays),
            "Themes": " ".join(record.themes),
            "GameUrl": record.game_url,
            "OpeningTags": record.opening_tags,
            "DailyDate": record.daily_date,
        }
        for record in store.records
    ]
    out = Path(out_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    staging = out.with_suffix(out.suffix + ".part")
    with open(staging, "w", encoding="utf-8") as handle:
        json.dump(rows, handle, separators=(",", ":"), ensure_ascii=False)
    # Publish whole or not at all: a half-written snapshot is never served.
    os.replace(staging, out)
    return len(rows)


# SCH-puzzle-catalog I1: the served snapshot's record count.
EXPECTED_RECORD_COUNT = 6_157_341


def check_snapshot(
    snapshot_path: str | Path, expected_count: int = EXPECTED_RECORD_COUNT
) -> list[str]:
    """The host-side integrity checks over a prepared snapshot.

    Returns the failures, empty when the snapshot holds (``SCH-puzzle-catalog``
    I1–I3): the record count of the served snapshot, every record's moves
    length, and the mate-in-one mark. ``parse_record`` already refuses I2/I3
    violations on ingest, so I2 and I3 are re-read from the served bytes here.

    ``expected_count`` defaults to the served snapshot's count. A rehearsal or
    a smoke run passes its own count so the deploy path can be exercised on a
    prepared slice without the full export (ADR-0008 keeps it host-side).
    """
    with open(snapshot_path, encoding="utf-8") as handle:
        rows = json.load(handle)
    failures = []
    if len(rows) != expected_count:
        failures.append(f"I1: expected {expected_count} records, found {len(rows)}")
    for index, row in enumerate(rows):
        try:
            parse_record(row)
        except ValueError as failure:
            failures.append(f"row {index}: {failure}")
    return failures


def main(argv: list[str] | None = None) -> int:
    """Build the served snapshot from the Lichess export, or check one already built."""
    import argparse

    parser = argparse.ArgumentParser(description="Build or check the puzzle catalog snapshot (ADR-0008).")
    subcommands = parser.add_subparsers(dest="command", required=True)
    build = subcommands.add_parser("build", help="prepare the export for serving")
    build.add_argument("csv", type=Path, help="the downloaded Lichess export CSV")
    build.add_argument("out", type=Path, help="where to write the served snapshot JSON")
    check = subcommands.add_parser("check", help="run the I1–I3 integrity checks over a built snapshot")
    check.add_argument("snapshot", type=Path, help="a snapshot written by build")
    check.add_argument(
        "--expected-count",
        type=int,
        default=EXPECTED_RECORD_COUNT,
        help=(
            "I1 record count to require (default: the served snapshot's "
            f"{EXPECTED_RECORD_COUNT}); pass a slice's own count to rehearse the deploy path"
        ),
    )
    arguments = parser.parse_args(argv)

    if arguments.command == "build":
        count = build_snapshot(arguments.csv, arguments.out)
        LOGGER.info("catalog_snapshot snapshot_id=%s records=%d", SNAPSHOT_ID, count)
        print(f"snapshot {arguments.out}: {count} records")
        return 0
    failures = check_snapshot(arguments.snapshot, arguments.expected_count)
    for failure in failures[:20]:
        print(failure)
    if len(failures) > 20:
        print(f"... and {len(failures) - 20} more")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
