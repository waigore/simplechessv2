# Rework run — issue #63 (graphical), rendered body measurement

Environment: **Graphical**, `xvfb-run` at 720×1280, Godot 4.7.2
(`4.7.2.stable.official.ed1daf0bf`).
Build: `demos/shared-game/` with the piece-fit rework of the acceptance fail on #63,
on `main` `50d098e` (includes the `FRM.P2` per-type heights from #571 and the
coordinate anchoring from #569).

## What was run

- `DEMO_SHOT_DIR=<this folder>/screenshots DEMO_AUTODRIVE=1 xvfb-run -a godot
  --path demos/shared-game` — `[demo] PASS`, both scenario screenshots written. Log:
  `logs/autodrive.log`.
- `python3 measure_pieces.py screenshots/demo-shared-game-exercise.png` — bounds every
  rendered silhouette in the exercise's final position and checks it against `SPC.E1`
  and each type's `FRM.P2` height. Log: `logs/piece-pixel-measure.log`.

## Result — every rendered body inside the extent and at its FRM.P2 height

One unit = 72 px; the exercise's final position, read from the screenshot.

| Type | Squares | Rendered W × H (units) | `FRM.P2` |
|------|---------|------------------------|----------|
| King | e1, e8 | 0.36 × 0.85, 0.39 × 0.86 | 0.85 (±0.01; the 0.86 is one raster pixel on the taller black King body) |
| Queen | d1, d8 | 0.38 × 0.79, 0.39 × 0.79 | 0.79 |
| Bishop | c1, g7 | 0.38 × 0.75, 0.36 × 0.74 | 0.76 |
| Knight | f3, c6 | 0.47 × 0.75, 0.47 × 0.75 | 0.75 |
| Rook | a1, h1, a8, g8 | 0.38–0.39 × 0.68 | 0.68 |
| Pawn | e4, b2, e5 | 0.36 × 0.61–0.62 | 0.62 |

Every body is inside `SPC.E1` 0.85 × 0.85 and within one raster pixel of its `FRM.P2`
height; the demo's own run reports the exact 0.85 / 0.79 / 0.76 / 0.75 / 0.68 / 0.62.
The pre-rework build measured the same squares at 1.32–1.81 units tall (the acceptance
finding on #63). `g8` shows the black rook that the autodrive's previously-swallowed
final move now plays.
