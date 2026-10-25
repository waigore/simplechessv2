# Contrast as drawn and after simulation, and what else was measured

`readings.json` → `contrast` reports WCAG relative-luminance ratios of each `PAL` accent against the
light square `C1` and the dark square `C2`, as drawn and after each full-severity simulation applied
by `simulate.py`.

| Accent | as drawn C1 / C2 | protanopia C1 / C2 | deuteranopia C1 / C2 |
|---|---|---|---|
| `C6` selection | 2.01 / 2.01 | 2.10 / 2.06 | 1.95 / 1.98 |
| `C8` refused, check | 2.01 / 2.01 | 2.12 / 2.04 | 1.94 / 1.99 |
| `C11` legal | 2.01 / 2.01 | 1.89 / 2.29 | 2.10 / 1.84 |
| `C7` advice (not on this build) | 2.01 / 2.01 | 1.79 / 2.41 | 2.16 / 1.79 |

`K5`/`K6`'s landed 2.0:1 is reproduced exactly as drawn (2.01:1 on both squares). After simulation the
same marks land between 1.79:1 and 2.41:1: the accents sit *on* the 2:1 floor, so a reader under
either simulation is left with roughly the minimum separation the rule allows, and one pairing lands
about a tenth under it (`C11` on a light square under protanopia, on a dark square under deuteranopia).
These are model readings, not measurements of a viewer, and no row's verdict rests on them — each mark
is still found by its **form**. Recorded so the floor is not mistaken for headroom.

## Observations with no verdict

- **Status label height.** The `White to move` label's painted glyph box measures 83 image px =
  41.5 CSS px at this frame, about **1/20** of the 844 px frame. `PER.R6` names ≥ 1/12 (≈ 70 CSS px).
  This run judges colour redundancy and takes no verdict on that metric; flagged for whoever owns
  `PER.R6`.
- **Check keyline after simulation.** The `C8` keyline on the `Check` chip turns pale tan and nearly
  meets the cream chip under both simulations. The word carries the check, which is what the row
  cites, but the keyline should not be leaned on.
- **Refused-place duration.** The rim is present in the pointer-up capture and gone by the next
  capture (`logs/capture-timings.txt`); `PER.R8` specifies 0.3 s and this run did not time it more
  finely than "present at +0 ms, gone by the next sample".
- **Capture ring versus selection ring.** Both are closed rings on this build, told apart by placement
  and by the piece inside. `PAL.K9` makes selection the only closed ring and gives captures corner
  brackets; #792 owns that change, so nothing is filed here.

## Method note

The simulation is the Machado, Oliveira & Fernandes (2009) matrix at full severity, applied in linear
RGB and re-encoded to sRGB, with nothing else changed — no sharpening, no palette snapping, no
per-image tuning. Grayscale was not used for any verdict.
