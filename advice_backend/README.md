# Advice backend

The separate Python server that is the sole UCI peer of Stockfish
(`specs/technical/components/advice-backend.md`, M2). The Godot client never
talks to Stockfish (ADR-0002, ADR-0010, ADR-0011).

## Run

Stockfish is not shipped (ADR-0012). An operator installs it and points the
server at it:

```bash
export ADVICE_API_KEY=<the key the client is configured with>
export STOCKFISH_PATH=/path/to/stockfish        # default: stockfish on PATH
export ADVICE_HOST=127.0.0.1 ADVICE_PORT=8080   # listen address this process is given
export ADVICE_TIME_MS=2000                      # CFG.ADVICE_TIME_MS
python3 -m advice_backend
```

Serve it over TLS behind whatever proxy the operator deploys; the process
must not be reachable without that TLS terminator. The client opens advice
traffic only to its configured endpoint, carrying the API key (ADR-0010).
There are no accounts and no player state.

Both routes deploy from a clean checkout with one command, which prepares the
catalog snapshot if asked and runs the integrity checks before serving:

```bash
PUZZLE_CATALOG_CSV=/srv/lichess_puzzles.csv \
PUZZLE_CATALOG_PATH=/srv/puzzle_snapshot.json \
ADVICE_API_KEY=<configured key> \
.github/scripts/deploy_advice_backend.sh
```

## Puzzle catalog route

The catalog is a second route on this server (ADR-0013,
[`CMP-catalog-service`](../specs/technical/components/catalog-service.md)). It
stores the ADR-0008 snapshot and runs `DIF.Y1` selection itself, so the client
never receives a catalog, a page, or a file.

```bash
export PUZZLE_CATALOG_PATH=/srv/puzzle_snapshot.json   # unset: deals fail, advice runs
export PUZZLE_CATALOG_RATE_LIMIT=30                    # T11, per key per minute
```

Prepare the snapshot from the Lichess export beside the server:

```bash
python3 -m advice_backend.catalog build /srv/lichess_puzzles.csv /srv/puzzle_snapshot.json
python3 -m advice_backend.catalog check /srv/puzzle_snapshot.json
```

`check` enforces `SCH-puzzle-catalog` I1–I3: the served snapshot's record
count, every record's moves length, and the mate-in-one mark. A new snapshot is
a new ADR-0008 decision; the served one is never edited in place (L2–L3).

To rehearse the deploy path on a prepared slice — the export stays host-side
(ADR-0008), so the full count cannot be reproduced from a clean checkout — pass
the slice's own record count:

```bash
python3 -m advice_backend.catalog check /srv/slice.json --expected-count 3
PUZZLE_CATALOG_EXPECTED_COUNT=3 .github/scripts/deploy_advice_backend.sh
```

Leave `PUZZLE_CATALOG_EXPECTED_COUNT` unset when serving the real snapshot: I1
then requires all 6,157,341 records.

Selection follows `DIF.Y1` server-side: an unseen puzzle wins at any band
before a recently solved one, and the recent-id rule is relaxed only once
widening has spanned the snapshot.

## Wire

`POST /advice` with `{"api_key", "fen", "time_ms"}` (`CTR-advice-stream` O1).
The response is `application/x-ndjson`, chunked: one `advice_update` per line
(`best_move_uci`, `eval_cp` in White centipawns, optional `mate_in`, `depth`,
`time_ms`), then one `{"reason": "cap" | "cancel" | "error"}`. A missing or
wrong key answers `401` with `{"reason": "error"}` without starting a search.

`POST /catalog/deal` with `{"api_key", "player_elo", "recent_solved"}`
(`CTR-puzzle-catalog-read` O1). A success body is exactly one
`SCH-puzzle-catalog` F1–F13 record — never a list, a page, or the export. A
missing or wrong key answers `401`, a malformed request `400`, and a
rapid-fire refusal or empty snapshot `503`, each with no record, so nothing is
dealt and `GS.playerElo` is unchanged (`F-puzzle-catalog` X2, `FAIL.T14`).
There is no list, page, or file operation; every other path is `404`. The raw
export is never a public static file and never enters the client bundle.

The search stops at the earlier of the client's `time_ms` and
`ADVICE_TIME_MS` (`CFG.ADVICE_TIME_MS`, default 2000) — F-move-advice R7 and
`CMP-advice-backend` R3 make the configured value the maximum think time, so
the client may shorten a search but never extend it. The end message is
delivered by the cap, not after it: a small reserve is held back from the
search, and a child that will not exit is killed after E2 is written. A client
that drops the response is a cancel; no update follows it. An engine that
exits or closes its output before sending `bestmove` is a backend failure, so
the stream ends `error` at once instead of waiting out the cap.

Timing and errors are logged on `advice_backend` (`advice_start` with
`cap_ms`, `advice_end` with `reason` / `elapsed_ms` / `disconnected`,
`advice_error` with `reason`) for Observability playtests.

## Test

```bash
python3 -m unittest discover -s advice_backend/tests -t .
```

The tests use a stand-in engine script, so no Stockfish binary is needed.
