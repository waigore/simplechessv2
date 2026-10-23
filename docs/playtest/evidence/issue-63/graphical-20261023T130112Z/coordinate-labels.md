# Failure — coordinate labels inside the 8×8, half under 4.5:1

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

Source frame: `screenshots/demo-shared-game-exercise.png`, baseline
`screenshots/demo-shared-game-exercise-labels-off.png`, log `logs/coord-label-measure.log`.
