# Issue #329 — acceptance probes (2026-10-24)

Acceptance testing: the checks judged in the verification comment, reproduced
from a clean checkout of `origin/main` (`a68640a`; the round-2 deliverable PR
#579 / `3e549da` is merged). No playable behaviour is involved, so no headless
or graphical playtest applies.

Inputs: a 3-record slice written for this run (`advice_backend/` never carries
the export, ADR-0008), player Elo 1480, `CFG` defaults (match range 100, widen
50, recent window 20).

## 1. `select_puzzle` / `DIF.Y1` (probe script, `PYTHONPATH=<clean tree>`)

| Probe | Expected | Got |
|---|---|---|
| unseen 1680 vs solved-on-last-deal 1480 | unseen | `unseen` |
| recent 1570 (in band) vs unseen 1591 (one widen step out) | unseen | `unseen` |
| unseen 2480 vs solved one deal ago 1480 | unseen | `far` |
| two unseen at 1400 / 1500 | nearest | `b` (1500) |
| only a recent record available | deal it, never None | `r` |
| empty snapshot | None | `None` |
| 25 solved ids, the 25th back outside the window | fresh | `target` |
| `recent_window` 0 | nothing recent | `r` |

## 2. Integrity checks (`python3 -m advice_backend.catalog check`)

| Snapshot | Result | Exit |
|---|---|---|
| served-count gate, 3-record slice | `I1: expected 6157341 records, found 3` | 1 |
| 3-record slice, `--expected-count 3` | (no findings) | 0 |
| one row with `Moves` = `e2e4` | `row 0: s1: fewer than two moves` | 1 |
| one row with `mateIn1` and three moves | `row 0: s1: mateIn1 needs exactly two moves` | 1 |

## 3. Deploy path from a clean checkout (`git archive origin/main`)

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

## 4. Wire contract on that served slice

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

## 5. Release bundle omits the export

- `git ls-tree -r origin/main` has no path matching `lichess*`, `puzzle_snapshot*`, or
  a puzzle `*.csv`; the only tracked files over 1 MB are `agent-orc/uv.lock` and
  audio/font assets.
- The Godot project root is `game/`; `game/export_presets.cfg` sets
  `include_filter=""` on both presets, and every `advice_backend/`,
  `audio_runtime/` and docs path is outside that root, so it is never exported.
- No `build/web`, `.pck`, or `.zip` artefact is tracked, so there is no stale
  bundle containing catalog bytes.

## 6. Client failure path (`F-puzzle-catalog` X2)

`game/puzzle_stream.gd` `poll()` sends a non-`ok` outcome to `refused()`, which
never calls `session.deal()`; `leave()` (K4) drops an owed deal. The Elo is held
by the session and is untouched on both paths. Exercised server-side above
through the `400` / `401` / `503` no-record responses.

## 7. Unit tests and lint (clean tree)

- `python3 -m unittest discover -s advice_backend/tests -t .` → **68 tests, OK**
- `python3 .github/scripts/spec_lint.py` → **0 errors, 1 warning** (pre-existing
  `specs/view/glossary.md` duplicate `Diagram`)

## 8. Not recorded here: I1 against the real 6,157,341-record snapshot

The Lichess export is host-side (ADR-0008); the repository holds no snapshot
bytes. The check above shows the I1 gate enforced at the served count and
passing at a slice's own count, but the operator run on the host is still open:

```bash
python3 -m advice_backend.catalog build <lichess-export.csv> <snapshot.json>
python3 -m advice_backend.catalog check <snapshot.json>   # PUZZLE_CATALOG_EXPECTED_COUNT unset
```
