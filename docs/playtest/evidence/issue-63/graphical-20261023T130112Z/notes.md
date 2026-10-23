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
| Realizes the demo-ready ID set; cited IDs exist | **fail** | every cited ID resolves in `specs/` (64 qualified IDs, machine-checked), but `PER.R7` is not realized: `logs/coord-label-measure.log` |
| Only cataloged, approved, review-Pass assets | pass | all 20 `assets.json` entries `state: approved`, `review.verdict: Pass` |
| Expresses `AES.P1`–`P3` | pass | P1 0.15 s budget; P2 bodies measured K 0.85 / Q 0.79 / B 0.76 / N 0.75 / R 0.68 / P 0.62; P3 mahogany board, wooden bevel, rose only for check/refusal |
| Lives under `demos/`; main code does not import it | pass | standalone `project.godot`; no `demos/` reference in `game/` |
| New assumptions recorded | pass (demo scope) | README A1–A4, each naming its owning spec; `docs/demos.md` puts demo assumptions in the README |
| README records citations, type, question | pass, with corrections needed | the `PER.R7` Included row and D13 overstate the label placement |

## Failure — coordinate labels inside the 8×8, half under 4.5:1

`PER.R7` (`specs/view/perception.md`) requires the coordinates on the outer 1-unit margin
only, at ≥ 4.5:1, never inside squares.

`BoardView.CoordLabels._stamp` passes `at - Vector2(width, rise) / 2.0` to `draw_string`,
whose y is a **baseline**, so every label is drawn ~31 px (0.43 unit) above its computed
centre. Diffing a labels-on and a labels-off render of the same frame:

- 1811 of 3386 label-ink pixels (53%) are inside the 8×8 — the file letters across the
  rank-1 squares (`g1` 405 px, `f1` 217, `d1` 149, `h1`/`e1` 92 each, `c1` 62, `b1` 37,
  `a1` 31) and the rank numbers overlapping the a-file.
- 1201 of 2499 solid ink pixels (48%) sit on the cream margin `#E8D5B5` at **1.28:1**;
  639 px sit on the grain band at 7.38:1 and 546 px on the board at 5.16:1.

The band is 0.16 unit while the label is 0.55 unit tall, so a correctly centred label would
still overrun it; `PER.R7` needs a field that meets 4.5:1 under the whole glyph. Filed as
defect #592.

## Passing details worth recording

- `AES.P2` rendered bodies, read from the exercise screenshot (`measure_pieces.py` from the
  earlier `graphical-20261023T113000Z` folder): every body inside `SPC.E1`, King 0.85,
  each type within one raster pixel of `FRM.P2`.
- `AES.P3`: board fills are `PAL.C2` 47% / `PAL.C1` 45.5% of the 8×8; the bottom lip is
  `PAL.C5`; no neutral-grey or blue chrome above 0.2% of the board; rose `PAL.C8` appears
  only in the mate frame (check/end).
- #456 end-panel regression: panel `x 41–678` inside the 720 px frame, `z 10`, margins
  230/160.
- Headless exit logs `ObjectDB instances leaked at exit` — engine shutdown noise.
- The `AES.P1` "0–4 ms" line in the README and logs times the tween start, not the 150 ms
  travel; the constant `TRAVEL_S = 0.15` is what meets `MOT.T1`.
