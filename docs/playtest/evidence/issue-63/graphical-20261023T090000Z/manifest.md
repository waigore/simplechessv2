# Evidence manifest — issue #63, graphical run

| Field | Value |
|-------|-------|
| Issue | #63 |
| Environment | graphical (`xvfb-run`, 720×1280) |
| Build / session id | `demos/shared-game` as on `main` at `ea5e0d5`; Godot `4.7.2.stable.official.ed1daf0bf` |
| Coverage mode | issue acceptance criteria (demos: playtesting optional per `docs/demos.md`) |

## Results

Same units as the headless run; this run supplies the rendered judgement and screenshots.

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Runnable shared game (both scenarios) | `L-two-player-game.K1`/`K2`, `END.L1` | pass |
| `AES.P1` snap settle | `PHY.M1`, `MOT.T1` | pass (0–6 ms vs 150 ms) |
| `AES.P2` silhouette-first pieces | `FRM.P1`, `SPC.E1`, `PER.R1` | **fail** — see `logs/pixel-measure.log` |
| `AES.P3` quiet mahogany | `AES.P3`, `SRF.M1`, `PAL.C2` | pass |
| `PER.R7` coordinates | `PER.R7`, `PAL.C10` | pass — labels on the `#6E4430` lips, 7.38:1 |
| End panel / #456 regression | `L-two-player-game.E1`, `END.L1` | pass — panel x 41–678 inside the 720 px frame, above pieces |

**Protocol verdict:** the piece-extent set is **fail** in this environment too, matching the
headless run.

## Paths

| Artifact | Path |
|----------|------|
| Notes | `../headless-20261023T090000Z/notes.md` (shared judgement) |
| Autodrive log | `logs/autodrive.log` |
| Piece-body measurement (from sprites) | `logs/piece-body-measure.log` |
| Frame pixel measurement | `logs/pixel-measure.log` |
| Screenshots | `screenshots/demo-shared-game-exercise.png`, `screenshots/demo-shared-game-mate.png` |
