# Evidence manifest — issue #63, graphical rework run

| Field | Value |
|-------|-------|
| Issue | #63 |
| Environment | graphical (`xvfb-run`, 720×1280) |
| Build / session id | `demos/shared-game` on branch `task/63-demo-piece-extent` (rebased onto `main` `50d098e`); Godot `4.7.2.stable.official.ed1daf0bf` |
| Coverage mode | issue acceptance criteria (demos: playtesting optional per `docs/demos.md`) |

## Results

Same units as the headless run; this run supplies the rendered judgement and screenshots.

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Runnable shared game (both scenarios) | `L-two-player-game.K1`/`K2`, `END.L1` | pass |
| Rendered body inside the extent, King full height, each at its FRM.P2 height | `SPC.E1`, `FRM.P1`, `FRM.P2`, `PER.R1` | pass — see `logs/piece-pixel-measure.log` |
| `AES.P1` snap settle | `PHY.M1`, `MOT.T1` | pass |
| `AES.P3` quiet mahogany, wooden bevel | `AES.P3`, `SRF.M1`, `PAL.C2` | pass |
| `PER.R7` coordinates | `PER.R7`, `PAL.C10` | pass (7.38:1, unchanged) |
| End panel inside the frame above the board | `END.L1`, defect #456 | pass |

## Paths

| Artifact | Path |
|----------|------|
| Notes | `notes.md` |
| Run log | `logs/autodrive.log` |
| Exercise screenshot | `screenshots/demo-shared-game-exercise.png` |
| Mate screenshot | `screenshots/demo-shared-game-mate.png` |
| Body measurement script | `measure_pieces.py` |
| Body measurement log | `logs/piece-pixel-measure.log` |
