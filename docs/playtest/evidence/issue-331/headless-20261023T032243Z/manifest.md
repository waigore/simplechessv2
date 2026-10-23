# Manifest

- **Issue**: 331
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf, `b8a1e81` on this worktree (component from merged PR #514 `463e19c`); headless smoke `TEL.3` session in `logs/headless-smoke.log`.
- **Coverage mode**: in-scope only — `CMP-puzzle-session` R1 (deal). No graphical run; the component has no screen yet.
- **Screenshots**: none — no graphical protocol is in scope.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTD-difficulty S1/S2 deal direction (`DIF.Y1`) | pass — `_check_deal_within_window`, `_check_deal_widens`, `_check_deal_allows_recent`, `_check_deal_still_deals_when_only_far` |
| PTD-difficulty S1 recent preference (`F-puzzle-catalog` I1) | pass — `_check_deal_skips_recent` |
| PTD-puzzle-stream K1 deal yields a puzzle | pass — `_check_first_move_is_applied` |
| `F-puzzle-catalog` X1 empty solution | pass — `_check_x1_empty_solution` |
| `F-puzzle-catalog` X2 unreadable catalog | pass — `_check_x2_failed_read` |
| `F-puzzle-catalog` R4–R5 mate-in-one mark | pass — `_check_mate_in_one_mark` |
| PTD-puzzle-stream K2–K4 / PTD-progression / result commit | n/a — session leaf |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/headless-smoke.log`
