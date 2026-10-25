# Judgement notes — #640 accessibility review

Run: [`docs/accessibility/issue-640/review-20261025/`](.) · manifest: [`manifest.md`](manifest.md)
· source: [`logs/source-validation.md`](logs/source-validation.md) · measurements:
[`logs/render-measurement.md`](logs/render-measurement.md)

All three claims are judged on the **published** `Web release` build of `main` `69a03d4`,
at the shipped phone frame (390 × 844 CSS px, DPR 2). The published squares draw
**exactly** the spec hexes `#E8D5B5` / `#8B5A3C`.

## Verdicts

| Claim | Element | Verdict | Detail |
|---|---|---|---|
| Piece type readable from shape alone | `PER.R1` (first two clauses) | **`pass`** | [`per-r1.md`](per-r1.md) |
| Squares differ by lightness, not hue alone | `PAL.K1` | **`pass`** | [`pal-k1.md`](pal-k1.md) |
| Piece side not told by square colour alone | `PAL.K2` (piece side) | **`fail`** | [`pal-k2.md`](pal-k2.md) |

`PAL.K2` fails because two of its four carriers read below 3:1 on the shipped board:
white `C4` contour on C1 1.28:1 / 1.25:1 (bar 9.95:1) and black `C3` contour on C2
2.83:1 / 3.19:1 (bar 5.10:1). Filed as **#883**.

## Defects filed

| Defect | Element | What it records |
|---|---|---|
| #883 | `PAL.K2` | the piece-side carrier failure, with drawn tones, crop paths, judged pixel size, both simulations |
| #885 | `PAL.K2` (reference sheet) | the `sheets/palette.html` figure's two swapped side labels, the `surface.md` `O1` mapping they contradict, and the four computed ratios |

Nothing else is filed: no `PER.R1` row failed, both squares draw their spec hexes exactly,
no claim is unownable, and the overlay accents are #641's.

## Boundaries

`K4` has no leaf; the overlay accents, `K8`/`K9`, `SIT.6` and the accessible names belong
to #641/#649/#546/#643. See [`boundaries.md`](boundaries.md).
