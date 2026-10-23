# `PER.R7` measured from rendered pixels

Part of the [issue #63 verification run](notes.md).

Method: diff the graphical exercise frame against the same frame with the coordinate pass
hidden. Every differing pixel inside the coordinate regions is coordinate ink, so its
position and its background are exact. Frame 720×1280; 8×8 at x 72..648, y 352..928.

| Region | Ink measured (this run) | `PER.R7` wants | Verdict |
|--------|-------------------------|----------------|---------|
| Left band (ranks 1–8) | ink at **x 37..47**, y 381..823 — one numeral per rank row | inside the left band (x ≈ 25..61), never inside the 8×8 | **Pass** |
| Bottom band (files a–h) | ink at **y 950..964**, x 103..610 — one letter per file column | inside the bottom band (y ≈ 935..977), never inside the 8×8 | **Pass** |
| Square membership | **0** solid ink pixels inside the 8×8, in either region | never inside squares | **Pass** |
| Contrast | ink `PAL.C9` on the `PAL.C1` band `(232, 213, 181)` = **9.95:1** | ≥ 4.5:1 | **Pass** |
| Size | `UIS.T2` face 16.0 px, 18.0 screen px at the 640 px reference frame; line box 23.0 px in a 32.0 px band | ≥ `UIS.T2` at the 640 reference | **Pass** |

The shipped build's own probe agrees with the render rather than with itself: its
predicted rank boxes (x 38.2..48.2) bracket the ink the renderer actually drew (x 37..47).
The prior verification found the opposite — the probe asserted `text_rect` geometry while
the render put the numerals at x 74..80 inside the a-file — so this run checks the
rendered frame, not the computed box, for the finding that failed before.
