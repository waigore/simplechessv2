# Asset Kind: Piece sprites

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Sprites
- **Source types**: AI generation; human-made
- **Style**: P2, P3; [FRM.S1 L1 D1](../../aesthetics/form.md); [PAL.S1](../../aesthetics/palette.md) C3 C4
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
| S1 | Canvas | Square; body ~85% ([SPC.E1](../../view/spatial-model.md)); transparent outside |
| S2 | Medium | SVG preferred ([ADR-0005](../../adr/decisions/0005-asset-catalog-roots.md)); PNG alpha OK |
| S3 | Detail | ≤ 3 fills; Staunton; height [FRM.P2](../../aesthetics/form.md) |
| S4 | Anchor | Center of square |
| S5 | Rasterize | Recraft SVG → PNG via Chrome headless only (not qlmanage/rsvg) |
| S6 | Transparency | Edge flood-fill near-white (RGB ≥ 250); never global white punch |
| S7 | Sheet crop | Ivory top / charcoal bottom; KQRBNP; 6-col projection; ~8px pad |
| S8 | Fit | `fit_contain` square (LANCZOS); center; no stretch |
| S9 | On-board | Box = 0.88 × square; centers from board layout JSON |

S5–S9 definitive for SS1. Reproduce: [`game_assets/previews/README.md`](../../../game_assets/previews/README.md).

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per asset | ≤ 80 KB | Load time |
| B2 | Kind total | 12 | Load time; G2 |

## Style series

Full fields: [`piece-sprites/style-series.md`](piece-sprites/style-series.md).

### SS1 — primary

- **State**: bootstrapping — see style-series.md for binding, anchors, aesthetics

#### Prompt policy

N/A — see [`piece-sprites/style-series.md`](piece-sprites/style-series.md).

## Recipes

Full recipe: [`piece-sprites/recipes.md`](piece-sprites/recipes.md).

### R1 — Recraft series / bootstrap

- **Post-processing**: S5–S9; see recipes.md for prompts/settings/outputs

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Silhouette | Solid-black ~1/12 frame | Type named (FRM.L1) |
| K2 | Spec S1–S9 | Review + inspect | Spec met |
| K3 | Budget B1 | File size | ≤ 80 KB |
| K4 | Style | Look vs P2 P3 | Quiet mahogany mood |
| K5 | Budget B2 | Catalog vs V1 | 12 entries |
| K6 | Fit / crop | Rebuild; compare golden PNG | No stretch; ivory intact |

## Naming

- **Handle name**: `piece-sprites/<type>-<white\|black>`
- **Path**: `piece-sprites/<name>.svg` (or `.png`) under `game_assets/`
