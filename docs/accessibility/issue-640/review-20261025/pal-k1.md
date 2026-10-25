# `PAL.K1` and the drawn swatches (#640)

Parent: [`../notes.md`](notes.md) · log: [`../logs/render-measurement.md`](logs/render-measurement.md) · data: [`../readings.json`](readings.json)

## `PAL.K1` — squares differ by lightness: `pass`

- Capture: the board canvas at its rendered pixel size, **624 × 624 capture px**, not a
  scaled-down page screenshot. Square edge 78 capture px (39 CSS px).
- **Control (un-simulated): Δ = 0.5495** (C1 L 0.6808, C2 L 0.1313).
- **Protanopia: Δ = 0.5465** (C1 `#65653C` L 0.1240, C2 `#D8D8B5` L 0.6705).
- **Deuteranopia: Δ = 0.5521** (C1 `#6D6D39` L 0.1448, C2 `#DCDCB4` L 0.6970).

Both simulations clear `K1`'s Δ ≥ 0.25 with a wide margin.

## Drawn swatches vs the spec hexes

Sampled from the **un-simulated** control as a 9 × 9 median patch well inside a square:

| Square | Capture (x, y) | CSS (x, y) | Drawn | Spec | Match |
|---|---|---|---|---|---|
| C1 light | 195, 1182 | 97.5, 591 | `#E8D5B5` | `#E8D5B5` | **exact** |
| C2 dark | 117, 1182 | 58.5, 591 | `#8B5A3C` | `#8B5A3C` | **exact** |

A second C1/C2 pair (files c and d, same rank) reads the same two hexes.
**No render-vs-swatch mismatch**: the shipped board draws the spec swatch exactly, so
`K1`'s Δ and `K2`'s ratios are computed on the colours the build actually paints. No third
square colour is drawn. Nothing is filed under this rule.
