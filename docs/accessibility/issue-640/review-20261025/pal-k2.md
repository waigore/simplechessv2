# `PAL.K2` — piece side, the four worked pairs (#640)

Parent: [`../notes.md`](notes.md) · log: [`../logs/render-measurement.md`](logs/render-measurement.md) · data: [`../readings.json`](readings.json)

## The verdict — `fail`

`K2`'s tested unit is the `O1`-composed silhouette (fill plus `SRF.O1` contour) against
the square it stands on. Carriers are the ones `palette.md` `K2` and `surface.md` `O1`
name: **white → `C4` contour, black → `C3` contour**. Judged pixel size is the board's
own square, **78 capture px (39 CSS px)**; each pair is a 78 × 78 crop of the
un-simulated control, then simulated.

| Pair | Piece / square | Carrier (`K2`) | Protanopia | Deuteranopia | Verdict |
|---|---|---|---|---|---|
| White on C2 | b2 pawn | fill `C3` | 5.97:1 pass | 5.27:1 pass | `pass` |
| White on C1 | f1 bishop | contour `C4` | **1.28:1 fail** | **1.25:1 fail** | `fail` |
| Black on C1 | a8 rook | fill `C4` | 9.86:1 pass | 10.10:1 pass | `pass` |
| Black on C2 | b8 knight | contour `C3` | **2.83:1 fail** | 3.19:1 pass | `fail` |

**Two of four carriers read below 3:1 → `PAL.K2` (piece side) is `fail`.** Filed as
**#883** against #34 under the `PAL.K2` element.

Weak tones, recorded and never scored: white-on-C2 contour 5.34 / 4.74; white-on-C1 fill
1.43 / 1.39; black-on-C1 contour 11.83 / 12.13; black-on-C2 fill 2.36 / 2.66. Field and
edge ratios for every pair in both simulations are in `readings.json` `k2.simulations`.

## The drawn piece tones

The simulation showed the piece tones are not the spec tones:

| Side | Spec fill / contour (`C3`/`C4`, `SRF.O1`) | Drawn fill / contour |
|---|---|---|
| White | `#F5F0E6` / `#2C2A28` | `#FDFDFC` / `#F5F0E6` (plus a fine `#141211` line) |
| Black | `#2C2A28` / `#F5F0E6` | `#2C2A28` / `#1D1B1A` |

The white side's fill is ~6% lighter than `C3` and its contour is `C3`-light ink, not the
`C4` `O1` rules for a white piece; the black side's contour is darker than `C3`. That is
what produces the failure, and it is recorded inside #883. The task's tone-mismatch route
is the swatch (`C1`/`C2`) rule, which both squares pass, so no separate filing is made.

## Why these four and nothing else

`K2`'s "each ≥ 3:1 both squares" is met by exactly these four carriers. A piece on
another square colour or a scaled-up board would be an out-of-set observation for #641;
none was seen — the board draws only `C1` and `C2`.
