# Manifest

- **Issue**: 58
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (worktree `task/58-shared-play-verification-fixes`). Shared-play test `TEL.3`: `sess-1792611687035-28492-playtest`. Smoke `TEL.3`: `sess-1792611687781-28520-playtest`.
- **Coverage mode**: full (in-scope UX protocols named by #58 AC).
- **Screenshots**: waiting on graphical run of the same build (`../graphical-20261022T033800Z/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-shared-play select / place / refuse (C1/C2) | pass |
| PTU-controls S4 pick-and-drag (B10) via pointer events | pass |
| B2 change-selection while selected (pointer) | pass |
| B3 place-with-selection (pointer) | pass |
| PHY.M5 bad-drop return (`end_drag_illegal`) | pass |
| PTU-exceptions resign `EX.confirm` → `END.L2` → NAV.T6 | pass |
| S2 board unavailable + clock keeps ticking | pass |
| CTR-playtest-drive.O1 / DBG.1 pause halts clock and input | pass |
| F-move-advice.R2 Advice stub | pass |
| Timed clocks R2 (Blitz tabular) | pass |
| PRJ.A1 chrome reserve (16:9 board below R2–R4) | pass |
| Design PTD-shared-game (via session unit suite) | pass |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/shared-play-test.log`
- `logs/headless-smoke.log`
