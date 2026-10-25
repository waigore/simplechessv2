# Asset Kind: Piece sprites

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Sprites
- **Source types**: AI generation; human-made
- **Style**: [AES.P2](../../aesthetics/aesthetics.md); [AES.P3](../../aesthetics/aesthetics.md); [FRM.S1 L1 D1](../../aesthetics/form.md); [PAL.S1](../../aesthetics/palette.md) [C3](../../aesthetics/palette.md) [C4](../../aesthetics/palette.md)
- **Tool roles**: TL.1
- **Approval**: As hub
- **Serves**: Clear board; Instant play; [E-pieces](../../design/entities/pieces.md); [PER.R1](../../view/perception.md)

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Types KQRBNP | Ivory C3; charcoal C4 | 12 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Canvas | Square; body/canvas height = [FRM.P2](../../aesthetics/form.md) ±0.01; transparent outside |
| S2 | Medium | SVG preferred ([ADR-0005](../../adr/decisions/0005-asset-catalog-roots.md)); PNG alpha OK |
| S3 | Detail | ≤ 3 fills; Staunton; height [FRM.P2](../../aesthetics/form.md) |
| S4 | Anchor | Opaque bottoms on the bottom edge of [SPC.E1](../../view/spatial-model.md) |
| S5 | Rasterize | SVG → PNG via one pipeline rasterizer ([`docs/asset-tools-recraft.md`](../../../docs/asset-tools-recraft.md)); never mix rasterizers. Ship PNGs carry the O1 contour hex |
| S6 | Transparency | Edge flood-fill near-white (RGB ≥ 250); never global white punch |
| S7 | Sheet crop | Pipeline input only: crop AI/human sheet (ivory top / charcoal bottom; KQRBNP; 6-col; ~8px pad) into twelve cell files; catalog result is V1 (twelve files), never the sheet |
| S8 | Fit | `fit_contain` square (LANCZOS); center; no stretch |
| S9 | On-board | Preview box 0.88 × square (layout JSON). Play size is [FRM.P2](../../aesthetics/form.md) |

S5–S9 definitive for SS1. Reproduce: [`docs/asset-previews/README.md`](../../../docs/asset-previews/README.md).

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per asset | ≤ 80 KB | Load time |
| B2 | Kind total | 12 | Load time; G2 |

## Style series

Full fields: [`piece-sprites/style-series.md`](piece-sprites/style-series.md).

### SS1 — primary

- **State**: active — see style-series.md for binding, anchors, aesthetics

#### Prompt policy

N/A — see [`piece-sprites/style-series.md`](piece-sprites/style-series.md).

## Recipes

Full recipe: [`piece-sprites/recipes.md`](piece-sprites/recipes.md).

### R1 — Recraft series / bootstrap

- **Post-processing**: S5–S9; see recipes.md for prompts/settings/outputs

### R2 — Human-made piece

- **Source type**: human-made — see recipes.md for N/A tool/prompts/settings/seed

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Silhouette | Solid-black at FRM.L1 (~1/21 @ 9:16; ~1/12 @ 16:9) | Type named (FRM.L1) |
| K2 | Spec S1–S9 | Review + inspect | Spec met |
| K3 | Budget B1 | File size | ≤ 80 KB |
| K4 | Style | Look vs [AES.P2](../../aesthetics/aesthetics.md) [AES.P3](../../aesthetics/aesthetics.md) | Quiet mahogany mood |
| K5 | Budget B2 | Catalog vs V1 | 12 entries (one file each; not a sheet) |
| K6 | Fit / crop | Rebuild; compare catalog PNGs by asset ID for each V1 handle | No stretch; ivory intact |
| K7 | Side fills | Inspect vs [PAL.C3](../../aesthetics/palette.md) [PAL.C4](../../aesthetics/palette.md) [SRF.O1](../../aesthetics/surface.md) | Fill C3 / C4; whole contour O1 |

## Naming

- **Handle name**: `piece-sprites/<type>-<white\|black>` (twelve V1 handles)
- **Path**: `piece-sprites/<name>.svg` (or `.png`) under `game_assets/` — one file per handle; sheets are not catalog outputs
