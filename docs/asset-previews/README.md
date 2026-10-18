# Board + pieces preview pipeline

Approved look for the SS1 mahogany board and ivory/charcoal piece set. Lives under `docs/` (not `game_assets/`) so regenerable tooling is not cataloged (ACC.P1 / I1).

**Definitive rules** (kind specs): [piece-sprites S5–S9](../../specs/assets/kinds/piece-sprites.md), [board-backgrounds S5–S7](../../specs/assets/kinds/board-backgrounds.md).

## Kept in this folder

| Path | Role |
|------|------|
| `README.md` | This summary |
| `rebuild_starting_position.py` | Implements the kind-spec pipeline |
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

Requires Chrome and Pillow. Writes `starting-position.preview.png` and regenerable `_work/` artifacts.
