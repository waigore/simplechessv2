# Acceptance run — issue #63 (graphical)

Environment: **Graphical**, `xvfb-run` at 720×1280, Godot 4.7.2
(`4.7.2.stable.official.ed1daf0bf`).
Build: `origin/main` at `7299459`; `demos/shared-game/` as shipped.
Scope: the issue's acceptance criteria, judged from the rendered frame. Playtesting is
optional for demos (`docs/demos.md`), so no playtest protocol is cited.

## What was run

- `DEMO_SHOT_DIR=<this folder>/screenshots DEMO_AUTODRIVE=1 xvfb-run -a godot
  --path demos/shared-game --resolution 720x1280` — `[demo] PASS`, both scenario
  screenshots written (`logs/autodrive.log`).
- `python3 measure_coord_labels.py screenshots/demo-shared-game-exercise.png
  <same frame with _build_coords() disabled>` — `logs/coord-label-measure.log`. The
  labels-off frame used for the diff is kept as
  `screenshots/demo-shared-game-exercise-labels-off.png`.

## Result

| AC | Outcome | Evidence |
|----|---------|----------|
| Runs from the repo; one shared game | pass | headless + graphical autodrive `[demo] PASS` |
| Realizes the demo-ready ID set; cited IDs exist | **fail** | every cited ID resolves in `specs/` (64 qualified IDs, machine-checked), but `PER.R7` is not realized: [coordinate-labels.md](coordinate-labels.md) |
| Only cataloged, approved, review-Pass assets | pass | all 20 `assets.json` entries `state: approved`, `review.verdict: Pass` |
| Expresses `AES.P1`–`P3` | pass | P1 0.15 s budget; P2 bodies measured K 0.85 / Q 0.79 / B 0.76 / N 0.75 / R 0.68 / P 0.62; P3 mahogany board, wooden bevel, rose only for check/refusal |
| Lives under `demos/`; main code does not import it | pass | standalone `project.godot`; no `demos/` reference in `game/` |
| New assumptions recorded | pass (demo scope) | README A1–A4, each naming its owning spec; `docs/demos.md` puts demo assumptions in the README |
| README records citations, type, question | pass, with corrections needed | the `PER.R7` Included row and D13 overstate the label placement |

## Failure

`PER.R7` is not realized: the coordinate labels land inside the 8×8 and half of their ink
sits below 4.5:1. Measurements and remedy: [coordinate-labels.md](coordinate-labels.md).
Filed as defect #592.

Passing details of the same run: [passing-details.md](passing-details.md).
