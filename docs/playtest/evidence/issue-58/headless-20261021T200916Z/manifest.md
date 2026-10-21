# Manifest

- **Issue**: 58
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`fff626b` on worktree, includes merged #337 / `576242f`). Shared-play test `TEL.3`: `sess-1792613320485-61272-playtest`. Smoke `TEL.3`: `sess-1792613321241-61274-playtest`. Graphical twin: `sess-1792613378781-62127-playtest`.
- **Coverage mode**: full (in-scope protocols named by #58 AC: `PTU-shared-play`, `PTU-controls`, `PTU-exceptions`, `PTD-shared-game`).
- **Screenshots**: waiting on graphical run of the same build (`../graphical-20261021T200916Z/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-shared-play S1–S4 (select / place / both seats / resign / coordinates chrome) | pass |
| PTU-controls S4 pick-and-drag (B10) via pointer events | pass |
| PTU-controls B2 change-selection / B3 place-with-selection | pass |
| PHY.M5 bad-drop return (`end_drag_illegal`) | pass |
| PTU-exceptions resign `EX.confirm` → `END.L2` → NAV.T6; Cancel → S1 | pass |
| S2 board unavailable + clock keeps ticking | pass |
| CTR-playtest-drive.O1 / DBG.1 pause | pass |
| F-move-advice.R2 Advice stub | pass |
| Timed clocks R2 (Blitz tabular) | pass |
| PRJ.A1 / D1 chrome reserve + full board at 16:9 / 9:16 | pass |
| controls.md F1 focus C1→C2→C3→C4 | pass |
| Design PTD-shared-game (session + rules suite) | pass |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/shared-play-test.log`
- `logs/headless-smoke.log`
