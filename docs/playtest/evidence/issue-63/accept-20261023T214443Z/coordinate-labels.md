# `PER.R7` measured from rendered pixels

Part of the [issue #63 acceptance run](notes.md). This measures the coordinate labels in
the frames this run produced, not the build's predicted boxes: the acceptance of #592/#63
compatibility hinges on the ink being outside the 8x8, and a predicted box once disagreed
with the render.

Method ([measure_independent.py](measure_independent.py), log
[logs/independent-measure.log](logs/independent-measure.log)):

- Two frames of the same build: the graphical autodrive
  [exercise frame](screenshots/demo-shared-game-exercise.png) and the same scene with the
  `Coordinates` control hidden ([nolabels.png](screenshots/nolabels.png), rendered by
  [make_nolabels_probe.gd](make_nolabels_probe.gd)).
- The 8x8 is found from the frame: only the square columns and rows carry dark square wood
  (`PAL.C2`). Measured square field: **x 61..694, y 306..927**.
- Label ink = pixels that differ between the two frames in the margins left of and below
  that field. Every one of the 1,755 differing pixels sits on light inlay wood in the
  labels-off frame (100%), so each glyph's background is known exactly.

| Element | Measured | `PER.R7` wants | Verdict |
|---------|----------|----------------|---------|
| Rank numerals (8) | x 37..47, one numeral per rank row: y 381..394 (rank 8) through y 885..898 (rank 1); row pitch exactly 72.0 px = one board unit | inside the left band, beside their own rank row, never inside the 8x8 | pass |
| File letters (8) | y 950..968, one letter per file column: x 102..111 (a) through x 607..616 (h); column pitch 71.0–73.5 px | inside the bottom band, under their own file column, never inside the 8x8 | pass |
| Squares | all 16 glyphs lie left of x 61 or below y 927; the square field starts at x 61 / ends at y 927 | never inside the 8x8 | pass |
| Contrast | darkest ink luminance 0.023–0.038 against the band wood behind it (0.681) → **8.33:1 to 9.95:1** per glyph | ≥ 4.5:1 | pass |
| Face size | `[demo] coordinates: UIS.T2 face 16.0 px (18.0 screen px at the 640 px reference frame), line box 23.0 px in a 32.0 px band; OK` | ≥ `UIS.T2` at the 640 px reference | pass |

The build's own rendered-pixel probe agrees and is the second, independent path: on the
read-back frame with pieces hidden it reports `left band 322 px, bottom band 324 px
(floor 202), inside 8x8 0 px, off-band 0 px`
([logs/graphical-autodrive.log](logs/graphical-autodrive.log)). That path reads
`image.get_pixel()` of the rendered frame (`board_view.gd` `coord_ink_problems`), so it
measures ink, not geometry; this run read the code and ran it, rather than trusting the
comment.
