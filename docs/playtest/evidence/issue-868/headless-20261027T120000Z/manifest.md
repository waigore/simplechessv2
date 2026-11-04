# Manifest

- **Issue**: 868 — The S4 promotion chooser is never exercised through the real screen pointer path (`type:defect`)
- **Environment**: headless (`ENV.1`). No graphical protocol is required — see `notes.md` §Why this run accepts.
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf` (macOS, `/opt/homebrew/bin/godot`), `origin/main` `a1fa8e302380d3b169193df1b6dfe9ff6660dade`
- **Coverage mode**: not applicable — the deliverable is one test file, so no playable behavior changes and no protocol is in scope.
- **Method**: clean detached worktree at `origin/main`, created for this run. Nothing judged from the shared checkout.
- **Defects**: none filed by this run.

## Results

| Acceptance criterion | Result |
|---|---|
| AC1 — White `c7→c8` drives the screen to S4, pawn on `c7`, `c8` empty, four sprites in `PROMOTE_ORDER` at the 2×2 slots | **pass** |
| AC2 — Black `c2→c1` gives the same observables with `pending_to == "c1"` | **pass** |
| AC3 — a real painted tap on the Queen commits through C6, not a direct `show_promotion_choice()` call; Queen lands, side passes, state `S1`, overlay cleared | **pass** |
| AC4 — tapping the destination centre drops the choice: `S1`, pending cleared, pawn on its origin and still selected, overlay cleared | **pass** |
| AC5 — the check is named in the PR and fails on a build where the seam is broken | **pass** — three break-and-restore runs, each failing by name |

## Deliverables

- PR #873 (merged `36997a6`, `Refs #868`) — `game/presentation_test.gd` only: `_exercise_promotion_choice()`, `_promotion_screen()`, `_chooser_sprites()`, `_tap_promotion_sprite()`, `_promote_offsets()`.
- CI on the merged tree: `Unit tests`, `Code lint`, `Coverage`, `Spec lint` green locally (33 passed, lint clean).

## Paths

- `notes.md` — why this run accepts, and the two earlier attempts
- `criteria.md` — per-AC mapping to the merged test
- `logs/unit-tests.txt` — import, 33 tests, lint, format, spec lint
- `logs/mutations.txt` — the three break-and-restore runs proving non-vacuity
- `screenshots/` — omitted: no protocol requiring one is in scope

## Prior evidence (retained)

- `graphical-20261025T011500Z/` (#896) and the second attempt recorded in #932 —
  both waited on a graphical reading this defect's ACs do not require.
