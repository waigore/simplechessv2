# Evidence manifest — issue #63, acceptance run

| Field | Value |
|-------|-------|
| Issue | #63 |
| Environment | graphical (native macOS window, Metal, 720×1280) and headless; `ENV.1` |
| Build / session id | `origin/main` `28c4d9f`, `demos/shared-game/` as shipped by PR #624; Godot `4.7.2.stable.official.ed1daf0bf` |
| Coverage mode | issue acceptance criteria (demos: playtesting optional per `docs/demos.md`) |

## Results

No playtest protocol is cited for a demo (`docs/demos.md`: playtesting is optional).
Judged units are the issue's acceptance criteria.

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Runnable shared game, both scenarios | `L-two-player-game.K1`/`K2`, `END.L1` | pass |
| Cited ID set resolves in `specs/` | README included set | pass |
| Coordinates outside the 8x8, ≥ 4.5:1, ≥ `UIS.T2` | `PER.R7`, `PAL.C1`, `PAL.C9`, `UIS.T2` | pass |
| Cataloged assets with a review Pass | `specs/assets/` kinds, `AST.O3` | pass |
| `AES.P1`–`P3`: budget, silhouette, calm mahogany | `MOT.T1`, `FRM.P2`, `PER.R7`, `PAL.C2`/`C5` | pass |
| Demo isolated under `demos/` | `docs/demos.md` | pass |
| README: citations, type, question, assumptions | `docs/demos.md` | pass |

Defects: none.

## Paths

| Artifact | Path |
|----------|------|
| Notes | `notes.md` |
| Coordinate measurement | `coordinate-labels.md` |
| Coordinate measurement script | `measure_independent.py` |
| Spec-ID check script | `check_spec_ids.py` |
| Labels-off probe | `make_nolabels_probe.gd` |
| Import log | `logs/import.log` |
| Headless autodrive log | `logs/autodrive.log` |
| Graphical autodrive log | `logs/graphical-autodrive.log` |
| Labels-off probe log | `logs/nolabels-probe.log` |
| Coordinate measurement log | `logs/independent-measure.log` |
| Spec-ID check log | `logs/spec-ids.log` |
| Asset catalog read-back | `logs/assets.json` |
| Exercise screenshot | `screenshots/demo-shared-game-exercise.png` |
| Mate screenshot | `screenshots/demo-shared-game-mate.png` |
| Labels-off diff baseline | `screenshots/nolabels.png` |
