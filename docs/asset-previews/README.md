# Board + pieces preview pipeline

Approved look for the SS1 mahogany board and ivory/charcoal piece set. Lives under `docs/` (not `game_assets/`) so regenerable tooling is not cataloged (ACC.P1 / I1).

**Definitive rules** (kind specs): [piece-sprites S5–S9](../../specs/assets/kinds/piece-sprites.md), [board-backgrounds S5–S7](../../specs/assets/kinds/board-backgrounds.md).

## Kept in this folder

| Path | Role |
|------|------|
| `README.md` | This summary |
| `piece_sprite_pipeline.py` | Shared S5–S8 steps (one Chrome/Chromium rasterizer) |
| `rebuild_starting_position.py` | Board composite (S9) |
| `derive_piece_sprites.py` | Writes the twelve ship PNGs from the sheet only |
| `recenter_piece_contours.py` | Re-tones the ship PNG contour/fill to the O1 hexes |
| `starting-position.layout.json` | Authoritative square centers / fill / fit (board S7, piece S9) |
| `starting-position.preview.png` | Golden approved composite (rewritten by rebuild) |

Everything else under `_work/` is regenerable and not kept.

## Outside inputs

| Path | Role |
|------|------|
| `game_assets/piece-sprites/style-anchor-sheet.svg` | Cataloged bootstrap sheet |
| `game_assets/board-backgrounds/play-table.svg` | Cataloged play board (light square BR) |

## Pipeline (matches kind specs)

1. **S5 / board S6** — Rasterize Recraft SVGs with Chrome headless only.
2. **S6** — Edge flood-fill near-white (RGB ≥ 250) → transparency.
3. **S7** — Crop 2×6 sheet (ivory/charcoal, KQRBNP) via projection; ~8px pad.
4. **S8** — `fit_contain` into square (LANCZOS); no stretch.
5. **S9 / board S7** — Place at `piece_fill` × `square_size` using layout JSON centers; black top, white bottom.

## Rebuild

```bash
python3 docs/asset-previews/rebuild_starting_position.py
```

Requires Chrome/Chromium and Pillow. Set `CHROME` to the binary when it is not on `PATH`. Writes `starting-position.preview.png` and regenerable `_work/` artifacts.

## Ship sprites

```bash
python3 docs/asset-previews/derive_piece_sprites.py
```

Same S5–S7 crop, then one shared LANCZOS scale so the tallest body is about 85% of the square and shorter types stay shorter. Writes `game_assets/piece-sprites/<type>-<white|black>.png`. No generative API.

Then re-tone the contour to [SRF.O1](../../specs/aesthetics/surface.md#outline): white pieces C4, black pieces C3. Re-runs write the same twelve files from the same sheet, so the result is reproducible.

```bash
python3 docs/asset-previews/recenter_piece_contours.py
```

Per-tone pass: the body fill goes to the side's fill hex and every other ink to the O1 hex; alpha, and so the silhouettes, stay as S8 drew them.

## Ship UI surfaces

```bash
python3 docs/asset-previews/derive_ui_surfaces.py
```

Splits `interface-art/style-anchor-sheet.svg` into `panel-surface` and `chip-surface`, and groups `icons/style-anchor-sheet.svg` left to right into five 24×24 ink SVGs (`mode-shared`, `mode-puzzle`, `quit`, `back`, `advice`). No generative API. The board file is not rewritten.
