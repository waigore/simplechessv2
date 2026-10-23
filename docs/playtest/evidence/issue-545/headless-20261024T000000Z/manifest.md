# Manifest

- **Issue**: 545
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf, `origin/main` `16e197b` (deliverable merged as `5a7541b`, PR #595; no later commit touches `game/playtest_seams.gd` or `game/playtest_seams_test.gd`). Headless probe `TEL.3`: `sess-1792774312435-52704-playtest`.
- **Coverage mode**: full, intersected with issue scope: `PTU-shared-play` (UX), steps S3/S4/S6 and P4. The deliverable is the `O11 assert_telemetry` read plus its `AssertTelemetry` debug control; it changes no start position, seat rule, or move gesture, so `S1`/`S2`/`S5` and `P1`/`P3` are outside this change's blast radius. `S6`/`P4`/`F3` are the judged rows.
- **Defects**: none — no protocol failed.
- **Screenshots**: waiting on the graphical sibling `../graphical-20261024T000000Z/screenshots/`. Per [`evidence.md`](../../../../specs/playtest/evidence.md) a headless run omits them without a fail and files no defect.
- **Log window cited by `SIT.5`**: `sess-1792774312435-52704-playtest`, 5 events (see `logs/playtest-headless.log`).

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTU-shared-play` S6 / P4 — a driven shared game's judged stories carry `TEL.1`–`TEL.5` with their IDs | pass — `US1` `ok`, `US1.4` `toggled`, `US1.1` `end` all matched |
| `PTU-shared-play` S6 / P4 — `O11` verdict for the judged set is `pass` with matched events | pass — `verdict=pass`, `matched=3` |
| `PTU-shared-play` F3 — a judged story with no correlating event fails, named in `missing` | pass — `US9-never-judged` in `missing`, `verdict=fail` |
| `SIT.5` — the seam reports the log window it read | pass — `session_id` = `TEL.3`, `event_count=5` |
| `SIT.5` — no-`story_id` convention (D1) | pass — empty `story_id` matches only events without `TEL.4` |
| `PTU-shared-play` S1/S2/S5, P1/P3 | not-judged — outside the change's blast radius (seat and move-gesture paths untouched) |
| **Protocol verdict `PTU-shared-play`** | **pass** (headless); screenshot requirement satisfied by the graphical twin |

## Paths

- `notes.md`
- `probe/accept545_probe.gd` — the driver and judgements
- `probe/accept545_release_probe.gd` — independent release-absence check (AC3)
- `logs/playtest-headless.log`
- `logs/release-absence.log`
- `logs/import.log`
- `logs/unit-tests.log`
- `logs/coverage.log`
- `logs/lint.log`
- `logs/spec-lint.log`
- `logs/headless-smoke.log`
