# Issue #329 — served-slice probes (2026-10-24)

Index and input notes: [acceptance.md](acceptance.md). This file covers the
deploy path, the wire contract, the release bundle, the client failure path,
and the clean-tree checks.

## 1. Deploy path from a clean checkout (`git archive origin/main`)

```bash
ADVICE_API_KEY=k PUZZLE_CATALOG_CSV=slice.csv PUZZLE_CATALOG_PATH=snap.json \
  .github/scripts/deploy_advice_backend.sh
# Prepared snapshot snap.json from slice.csv
# snapshot snap.json: 3 records
# I1: expected 6157341 records, found 3      -> exit 1 (the default gate holds)

ADVICE_API_KEY=k PUZZLE_CATALOG_CSV=slice.csv PUZZLE_CATALOG_PATH=snap.json \
  PUZZLE_CATALOG_EXPECTED_COUNT=3 PUZZLE_CATALOG_RATE_LIMIT=3 \
  .github/scripts/deploy_advice_backend.sh
# snapshot snap.json: 3 records
# INFO advice_backend listening on 127.0.0.1:18093 catalog_records=3
```

## 2. Wire contract on that served slice

| Request | Response |
|---|---|
| `{"player_elo":1480,"recent_solved":["s1"],"api_key":"k"}` | `200`, one object, exactly 13 fields, `snapshot_id` `2026-10-05`, `puzzle_id` `s2` (unseen, rating 1560 — not the just-solved `s1` at 1480) |
| wrong key | `401 {}` |
| missing key | `400 {}` |
| malformed `player_elo` | `400 {}` |
| rate limit 3, after one deal | `200 200 503` |
| `POST /catalog/puzzles`, `/catalog/deal/all`, `/puzzles.csv`, `/catalog`, `/catalog/export` | `404` each |
| `GET /catalog/deal` | `501` (no handler) |
| server started with `PUZZLE_CATALOG_PATH` unset | `503 {}` |

No response body is a list, a page, or a candidate set.

## 3. Release bundle omits the export

- `git ls-tree -r origin/main` has no path matching `lichess*`, `puzzle_snapshot*`, or
  a puzzle `*.csv`; the only tracked files over 1 MB are `agent-orc/uv.lock` and
  audio/font assets.
- The Godot project root is `game/`; `game/export_presets.cfg` sets
  `include_filter=""` on both presets, and every `advice_backend/`,
  `audio_runtime/` and docs path is outside that root, so it is never exported.
- No `build/web`, `.pck`, or `.zip` artefact is tracked, so there is no stale
  bundle containing catalog bytes.

## 4. Client failure path (`F-puzzle-catalog` X2)

`game/puzzle_stream.gd` `poll()` sends a non-`ok` outcome to `refused()`, which
never calls `session.deal()`; `leave()` (K4) drops an owed deal. The Elo is held
by the session and is untouched on both paths. Exercised server-side above
through the `400` / `401` / `503` no-record responses.

## 5. Unit tests and lint (clean tree)

- `python3 -m unittest discover -s advice_backend/tests -t .` → **68 tests, OK**
- `python3 .github/scripts/spec_lint.py` → **0 errors, 1 warning** (pre-existing
  `specs/view/glossary.md` duplicate `Diagram`)
