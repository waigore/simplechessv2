# Evidence — defect #592 (coordinate labels, `demos/shared-game`)

Environment: headless Godot 4.7.2 (`4.7.2.stable.official.ed1daf0bf`), plus a
graphical `xvfb-run -a` pass at 720×1280 for the screenshots.
Before: `main` at `abc6469`. After: this PR's branch.

## What was run

- `godot --headless --path demos/shared-game --import --quit` (clean import, no
  script errors).
- `DEMO_AUTODRIVE=1 godot --headless --path demos/shared-game` →
  `[demo] PASS` (`logs/autodrive.log`): 16 exercise moves + 7 mate moves, six
  piece bodies inside `SPC.E1`, and the new `PER.R7` check printing all 16
  label ink boxes inside their band.
- `DEMO_SHOT_DIR=… DEMO_AUTODRIVE=1 xvfb-run -a godot --path demos/shared-game
  --resolution 720x1280` on both trees → the four screenshots below.
- `python3 measure_labels.py <before> <after>` → `logs/coord-label-measure.log`.

## Result

`draw_string` takes the glyph **baseline**, and the old `CoordLabels._stamp`
passed a box-centered position as that baseline: every label drew ~31 px
(0.43 unit) too high. The 40 px face was also taller (≈ 48 px) than the whole
0.16-unit (11.5 px) band, so half of every glyph hung over the light `PAL.C1`
margin at 1.28:1.

The fix positions each label by its ink box (`CoordLabels.text_rect`), centres
it in its band (`CoordLabels.spots`), and clamps the face so ascent + descent
ink 80 % of the band — 6.5 px, a 9 px ink box in an 11.5 px band.

| Measurement (exercise frame) | Before | After |
|------------------------------|--------|-------|
| File-letter glyph clusters in the bottom band rows 930–933 | 0 (the letters were drawn over the rank-1 squares) | 8 |
| File-letter centres (expected 108, 180, 252, 324, 396, 468, 540, 612) | — | 107, 180, 251, 324, 395, 468, 540, 612 |
| Rank-number cream runs in the left band | 18, none centred on a rank (e.g. rows 487–493 vs. no rank centre; rank centres are 892, 820, 748, 676, 604, 532, 460, 388) | 0 rows of stray ink; each of the 8 digits prints its box inside the band |
| Label ink on the light margin / board (1.28:1 / 5.16:1) | half the glyphs | 0 px |
| Label ink inside the 8×8 | ~half (file letters on rank 1, rank digits on the a-file) | 0 px |

The autodrive reproduces the geometry check every run: `[demo] coordinates 6.5 px
glyph ink 9.0 px in a 11.5 px band (PER.R7)`, then one `[demo]   <label> box …
band …` line per label, and `[demo] PASS` only when every box is inside its band.

## Notes

- `UIS.T2`'s 16 px floor cannot be met inside a 0.16-unit band at this frame:
  `PER.R7`'s ≥ 4.5:1 floor is the binding constraint and is met for every glyph
  pixel. Recorded in README D13.
- Headless exit still logs `ObjectDB instances leaked at exit` — engine
  shutdown noise, present before this change.
