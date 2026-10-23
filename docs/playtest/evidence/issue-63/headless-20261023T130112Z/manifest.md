# Evidence manifest — issue #63, acceptance run (headless)

| Field | Value |
|-------|-------|
| Issue | #63 |
| Environment | headless |
| Build / session id | `origin/main` `7299459`, `demos/shared-game/`; Godot `4.7.2.stable.official.ed1daf0bf` |
| Coverage mode | issue acceptance criteria (demos: playtesting optional per `docs/demos.md`) |

## Results

No playtest protocol is cited for a demo (`docs/demos.md`: playtesting is optional).
Judged units are the issue's acceptance criteria.

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Runnable shared game, both scenarios | `L-two-player-game.K1`/`K2`, `END.L1` | pass |
| Piece bodies inside the extent at their `FRM.P2` heights | `SPC.E1`, `FRM.P1`, `FRM.P2`, `PER.R1` | pass |
| `AES.P1` motion budget | `PHY.M1`, `MOT.T1` | pass |
| End panel inside the frame above the board | `END.L1` | pass |

Defects: #592 (coordinate labels: placement and contrast, measured in the graphical run).

## Paths

| Artifact | Path |
|----------|------|
| Notes | `notes.md` |
| Import log | `logs/import.log` |
| Autodrive log | `logs/autodrive.log` |
| Screenshots | waiting on the graphical run (`../graphical-20261023T130112Z/screenshots/`) |
