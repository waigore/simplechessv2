# Evidence manifest — issue #63, headless run

| Field | Value |
|-------|-------|
| Issue | #63 |
| Environment | headless |
| Build / session id | `demos/shared-game` as on `main` at `ea5e0d5`; Godot `4.7.2.stable.official.ed1daf0bf` |
| Coverage mode | issue acceptance criteria (demos: playtesting optional per `docs/demos.md`) |

## Results

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Runnable shared game | `L-two-player-game.K1`/`K2`, `END.L1` | pass |
| Cited IDs resolve in `specs/` | — | pass |
| Cataloged, approved, review-Pass assets | asset hub; `docs/demo-style-assets.md` | pass (20/20) |
| `AES.P1` snap settle | `PHY.M1`, `MOT.T1` | pass (0–6 ms vs 150 ms) |
| `AES.P2` silhouette-first pieces | `FRM.P1`, `SPC.E1`, `PER.R1` | **fail** — bodies 1.32–1.81 units tall vs 0.85 max |
| `AES.P3` quiet mahogany | `AES.P3`, `SRF.M1`, `PAL.C2` | pass |
| `PER.R7` coordinates | `PER.R7`, `PAL.C10` | pass (7.38:1) |
| Isolation under `demos/` | — | pass |

**Protocol verdicts:** the piece-extent set is **fail**; every other judged unit is pass.

## Paths

| Artifact | Path |
|----------|------|
| Notes | `notes.md` |
| Autodrive log | `logs/autodrive.log` |
| Piece-body measurement (from sprites) | `logs/piece-body-measure.log` |
| Screenshots | waiting on the graphical run — see `../graphical-20261023T090000Z/` |
