# Evidence manifest — issue #63, acceptance run (graphical)

| Field | Value |
|-------|-------|
| Issue | #63 |
| Environment | graphical (`xvfb-run`, 720×1280) |
| Build / session id | `origin/main` `7299459`, `demos/shared-game/`; Godot `4.7.2.stable.official.ed1daf0bf` |
| Coverage mode | issue acceptance criteria (demos: playtesting optional per `docs/demos.md`) |

## Results

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Runnable shared game, both scenarios | `L-two-player-game.K1`/`K2`, `END.L1` | pass |
| Coordinates on the outer margin, ≥ 4.5:1, never inside squares | `PER.R7`, `PAL.C10`, `UIS.T2` | **fail** |
| Rendered piece bodies inside the extent at their `FRM.P2` heights | `SPC.E1`, `FRM.P1`, `FRM.P2`, `PER.R1` | pass |
| `AES.P1` motion budget | `PHY.M1`, `MOT.T1` | pass |
| `AES.P3` quiet mahogany, wooden bevel, rose only for check/refusal | `AES.P3`, `SRF.M1`, `PAL.C2`/`C5`/`C8` | pass |
| End panel inside the frame above the board | `END.L1` | pass |

Defects: #592 (coordinate label placement and contrast).

## Paths

| Artifact | Path |
|----------|------|
| Notes | `notes.md` |
| Autodrive log | `logs/autodrive.log` |
| Coordinate-label measurement log | `logs/coord-label-measure.log` |
| Coordinate-label measurement script | `measure_coord_labels.py` |
| Exercise screenshot | `screenshots/demo-shared-game-exercise.png` |
| Mate screenshot | `screenshots/demo-shared-game-mate.png` |
| Exercise frame with coordinate labels off (diff baseline) | `screenshots/demo-shared-game-exercise-labels-off.png` |
