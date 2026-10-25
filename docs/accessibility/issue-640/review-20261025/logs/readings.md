# Readings — K1, swatches, K2 (#640)

Reproduced by `node read.mjs .` then `node piece.mjs ../../../../game_assets .`
([`render-measurement.md`](render-measurement.md)). Raw numbers: `../readings.json`.

| Measure | Capture px | CSS px |
|---|---|---|
| capture | 780 × 1688 | 390 × 844 |
| board left / top | 78 / 753 | 39 / 376.5 |
| board side | 624 | 312 |
| square edge | 78 | 39 |

The edge is found from the build's own dark-square paint; a full `PRJ.V1` frame gives
39 CSS px at 10 units on the 390 px short axis, and the measured 39.0 agrees.

## K1 — board canvas

| Image | C1 sample | C2 sample | Luminance Δ | Verdict |
|---|---|---|---|---|
| control | `#E8D5B5` (L 0.6808) | `#8B5A3C` (L 0.1313) | **0.5495** | quote only |
| protanopia | `#65653C` (L 0.1240) | `#D8D8B5` (L 0.6705) | **0.5465** | pass |
| deuteranopia | `#6D6D39` (L 0.1448) | `#DCDCB4` (L 0.6970) | **0.5521** | pass |

Two C1/C2 sample pairs per image read the same Δ (`lightness.<sim>.deltaPerPair`).
`lightness-<sim>.png` is the board canvas at 624 × 624 capture px, not a downscaled page.

## Drawn swatches vs spec hexes

| Sample | file/rank | capture (x, y) | CSS (x, y) | Drawn | Match |
|---|---|---|---|---|---|
| C1 | d3 | 195, 1182 | 97.5, 591 | `#E8D5B5` | yes |
| C2 | a3 | 117, 1182 | 58.5, 591 | `#8B5A3C` | yes |
| C2 second | c3 | 273, 1182 | 136.5, 591 | `#8B5A3C` | yes |
| C1 second | d3 | 351, 1182 | 175.5, 591 | `#E8D5B5` | yes |

## K2 — the four worked pairs

Judged square = 78 capture px (39 CSS px); each crop is one square, 78 × 78 capture px.

| Pair | Carrier | Protanopia | Deuteranopia |
|---|---|---|---|
| White on C2 (b2 pawn) | fill `C3` | 5.97:1 pass | 5.27:1 pass |
| White on C1 (f1 bishop) | contour `C4` | **1.28:1 fail** | **1.25:1 fail** |
| Black on C1 (a8 rook) | fill `C4` | 9.86:1 pass | 10.10:1 pass |
| Black on C2 (b8 knight) | contour `C3` | **2.83:1 fail** | 3.19:1 pass |

Weak tones (recorded, never scored): white-on-C2 contour 5.34 / 4.74; white-on-C1 fill
1.43 / 1.39; black-on-C1 contour 11.83 / 12.13; black-on-C2 fill 2.36 / 2.66. All ratios
in `readings.json` `k2.simulations`.

**Drawn piece tones:** white fill `#FDFDFC`, contour `#F5F0E6` (plus a fine `#141211`
line); black fill `#2C2A28`, contour `#1D1B1A`. The white fill is **not** spec `C3` — see
[`../pal-k2.md`](../pal-k2.md).

## Parity sweep (used to pick the four crops)

Each rank's file sweep: rank 8 `D/L/D/L/D/L/D/L`, rank 7 `L/D/L/D/L/D/L/D`, … rank 1
`D/L/D/L/D/L/D/L`. So a1 is C2, a8 is C1, b2 is C2, f1 is C1.

## Simulation model

Viénot, Brettel & Mollon (1999) dichromat LMS-plane reduction in linear RGB, sRGB transfer
after the matrix (`measure.mjs` `SIMULATIONS`).
