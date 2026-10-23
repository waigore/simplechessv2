# Headless notes — #551

Acceptance playtest for #551 (Player Elo must use `CFG.ELO_K` = 20, not a local `32.0`) on
`972e2a1` on `main`. That build carries the defect's whole deliverable, the merge of
PR #563 as `9376bc5`; the only later commit (`972e2a1`, PR #564) touches
`PTU-localization` docs and no client code.

## Prep

- `godot --headless --path game --import --quit` — exit 0 (`logs/import.log`)
- `python3 .github/scripts/gdscript_tests.py test` — 19 headless unit test(s) passed
- `python3 .github/scripts/gdscript_tests.py coverage` — statement-line coverage above
  the 80 threshold (`logs/coverage.log`)
- `gdlint game` / `gdformat --check game` (gdtoolkit 4.5.0) — clean (`logs/lint.log`)
- `python3 .github/scripts/spec_lint.py` — 0 error(s), 1 pre-existing warning
  (`logs/spec-lint.log`)
- `godot --headless --path game` — playtest smoke, exit 0, `TEL.1`–`TEL.5` emitted
  (`logs/headless-smoke.log`)

## Scope

The deliverable is code that changes playable behaviour (the `DIF.Y1` Elo update), so
playtesting applies. Intersecting the `full` coverage set with the IDs this defect can
affect:

- `PTD-difficulty` (Design, cites `DIF`, headless only) — the Elo update direction and size.
- `PTD-game-state` (Design, cites `GS` persist fields `playerElo` / `lastMode` /
  `recentSolved`, headless only) — those fields across reopen, and the failed-write path.

The K factor changes no screen, control, copy, or journey step, so **no UX protocol is in
scope** and no graphical run is required. Both selected protocols are Design protocols
whose Evidence row reads "Default evidence rules (Headless: no screenshots)", so this
headless run is sufficient for acceptance.

## How the run drove the session

`probe/accept551_probe.gd` (copied into `game/` for the run, then removed) drives
`PuzzleSession` through the verbs the puzzle-play screen binds — `deal`, `place`, and
`request_confirm` with `C3` (reveal) / `C4` (abandon) followed by `confirm` — and judges
the literal numbers the design stories state. It is an acceptance probe, not a re-run of
the PR's tests: the assertions are written against
`specs/design/stories/difficulty.md`,
`specs/design/stories/end-conditions/conditions-puzzle.md`, and
`specs/design/stories/game-state/fields-persist.md`, not against
`game/puzzle_session_test.gd`.

## Judgement (headless)

| ID | Outcome | Evidence |
|----|---------|----------|
| `PTD-difficulty` S1 / P1 — `PS1.1` `END.W1` at equal ratings reaches 1000 + 20 × 0.5 | pass | `1010.0`; `elo_k=20.0` |
| `PTD-difficulty` S2 / P1 — `PS1.2` `END.L6` (abandon, `C4`) at equal ratings reaches 990 | pass | `990.0` |
| `PTD-difficulty` S2 / P1 — `END.L5` (reveal, `C3`) at equal ratings reaches 990 | pass | `990.0` |
| `PTD-difficulty` F1 — Elo does not move opposite `DIF` | pass | win `1010.0` > start; loss `990.0` < start |
| `PTD-difficulty` P1 — the defect's K=32 numbers (1016 / 984) are gone | pass | `no K=32 drift (win=1010.0 abandon=990.0)` |
| `PTD-difficulty` S3 / P2 — Shared endings leave Player Elo unchanged | pass | Shared game exposes no Player Elo field; `PuzzleSession` mutates `player_elo` only in `_apply_outcome` |
| `PTD-game-state` S5 / P2 — `playerElo` survives reopen | pass | committed `3010.0` read back by a fresh session via `restore(load_document())` |
| `PTD-game-state` S5 — `lastMode` survives reopen | pass | `puzzle` |
| `PTD-game-state` S5 — `recentSolved` survives reopen | pass | `["p1"]` |
| `PTD-game-state` P2 / `EX.save-failure` — a failed write keeps the prior commit | pass | `save_failed` raised; committed Elo stays `3010.0` |
| `fields-persist` PS1.7 — no Elo cap at high rating | pass | `3000 → 3010.0` |

Protocol verdicts: `PTD-difficulty` **pass**, `PTD-game-state` **pass**, both headless (`ENV.1`).

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

- No defect filed: no protocol failed.
- Display server was headless (`ENV.1`). No graphical twin is needed — see Scope.
- The probe's injected write failure logs an expected `persist_store.gd` backtrace in
  `logs/playtest-headless.log`; that is the `EX.save-failure` path being exercised, not
  an unexpected error. The run exits 0 with `PROBE_RESULT fails=0`.
