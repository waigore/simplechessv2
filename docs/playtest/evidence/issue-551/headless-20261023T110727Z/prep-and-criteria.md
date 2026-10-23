# Prep and acceptance criteria — #551

Companion to [`notes.md`](notes.md) in the same run folder.

## Build under test

Godot 4.7.2.stable.official.ed1daf0bf, `972e2a1` on `main`. That build carries the
defect's whole deliverable, the merge of PR #563 as `9376bc5`; the only later commit
(`972e2a1`, PR #564) changes `PTU-localization` docs and no client code.

## Prep

- `godot --headless --path game --import --quit` — exit 0 (`logs/import.log`)
- `python3 .github/scripts/gdscript_tests.py test` — 19 headless unit test(s) passed
- `python3 .github/scripts/gdscript_tests.py coverage` — 86.9% statement-line coverage,
  threshold 80 (`logs/coverage.log`)
- `gdlint game` / `gdformat --check game` (gdtoolkit 4.5.0) — clean, 44 files unchanged
  (`logs/lint.log`)
- `python3 .github/scripts/spec_lint.py` — 0 error(s), 1 pre-existing warning
  (`logs/spec-lint.log`)
- `godot --headless --path game` — playtest smoke, exit 0, `TEL.1`–`TEL.5` emitted
  (`logs/headless-smoke.log`)

## Acceptance criteria

| AC (issue body) | Result |
|-----------------|--------|
| Player Elo updates use `CFG.ELO_K` = 20 as the default | pass — `game/puzzle_session.gd:50` `const ELO_K := 20.0`, documented as the `T3` mirror; the session reads it once into `elo_k` and applies that at `:508` |
| A solve at equal ratings adds 10, a loss subtracts 10 (`DIF.Y1`; `difficulty`, `conditions-puzzle`) | pass — 1010 and 990 in the probe, matching the story text |
| The Elo tests read the `T3` tunable, not `PuzzleSession.ELO_K` | pass — assertions bound by `session.elo_k`; no self-referential bound remains |
| Spec numeric cases added so a wrong constant reddens the suite (1010, 990, 3010) | pass — `_check_w1_equal_ratings`, `_check_l5_equal_ratings`, `_check_elo_k_default` present in `game/puzzle_session_test.gd` |
| `ELO_START` / `ELO_MATCH_RANGE` / `ELO_RECENT_WINDOW` / `ELO_BAND_WIDEN` unchanged | pass — all four still match their spec defaults |
| No spec change required | pass — `specs/` untouched by PR #563; the code was the drift |

## Notes

- Display server was headless (`ENV.1`); no graphical twin is needed (see `notes.md`).
- The probe's injected write failure logs an expected `persist_store.gd` backtrace in
  `logs/playtest-headless.log`; that is the `EX.save-failure` path being exercised, not
  an unexpected error. The run exits 0 with `PROBE_RESULT fails=0`.
