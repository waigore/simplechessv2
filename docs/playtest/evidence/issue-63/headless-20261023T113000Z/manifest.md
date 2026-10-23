# Evidence manifest — issue #63, headless rework run

| Field | Value |
|-------|-------|
| Issue | #63 |
| Environment | headless |
| Build / session id | `demos/shared-game` on branch `task/63-demo-piece-extent` (rebased onto `main` `50d098e`); Godot `4.7.2.stable.official.ed1daf0bf` |
| Coverage mode | issue acceptance criteria (demos: playtesting optional per `docs/demos.md`) |

## Results

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Runnable shared game (both scenarios) | `L-two-player-game.K1`/`K2`, `END.L1` | pass |
| Body inside the extent, King full height, each at its FRM.P2 height | `SPC.E1`, `FRM.P1`, `FRM.P2`, `PER.R1` | pass (K 0.85, Q 0.79, B 0.76, R 0.68, N 0.75, P 0.62 tall; widths 0.38–0.48) |
| `AES.P1` snap settle | `PHY.M1`, `MOT.T1` | pass (0–18 ms vs 150 ms) |
| End panel inside the frame above the board | `END.L1`, defect #456 | pass |
| Scripted move always reaches the board | `I33`/`I34`, `PHY.M1` | pass — promotion chooser dismissed, `h8g8` now executes |

## Paths

| Artifact | Path |
|----------|------|
| Notes | `notes.md` |
| Autodrive log | `logs/autodrive.log` |
| Rendered-body measurement | `../graphical-20261023T113000Z/logs/piece-pixel-measure.log` |
