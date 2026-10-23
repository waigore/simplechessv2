# Asset Kind: Board backgrounds

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Backgrounds
- **Source types**: AI generation; human-made
- **Style**: [AES.P3](../../aesthetics/aesthetics.md); [PAL.C1 C2 C5](../../aesthetics/palette.md); [SRF.M1](../../aesthetics/surface.md); [FRM.S2](../../aesthetics/form.md)
- **Tool roles**: TL.1
- **Approval**: As hub
- **Serves**: Cafe calm; Clear board; [PER.R2](../../view/perception.md); Shared/Puzzle play

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Play board plane | One mahogany table + 8×8 light/dark | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Layout | Full 8×8 readable; soft grain never breaks squares (SRF.M1) |
| S2 | Colors | Light C1 / dark C2 / table C5 (PAL.S1); contrast [PAL.K1](../../aesthetics/palette.md) |
| S3 | Medium | SVG or PNG; square or board-aspect |
| S4 | Overlays | No piece art; no chrome badges |
| S5 | Orientation | Light square bottom-right (h1) |
| S6 | Rasterize | SVG → PNG via the pipeline rasterizer ([`docs/asset-tools-recraft.md`](../../../docs/asset-tools-recraft.md)); no mixing |
| S7 | Square layout | Centers + pitch in `starting-position.layout.json`; preview fill 0.88 ([piece S9](piece-sprites.md)) |

S5–S7 definitive for SS1 look.

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per asset | ≤ 400 KB | Load time; G2 |

## Style series

Full fields: [`board-backgrounds/style-series.md`](board-backgrounds/style-series.md).

### SS1 — primary

- **State**: active — see style-series.md for binding, anchors, aesthetics

#### Prompt policy

See [`board-backgrounds/style-series.md`](board-backgrounds/style-series.md).

## Recipes

Full recipes: [`board-backgrounds/recipes.md`](board-backgrounds/recipes.md).

### R1 — Recraft board

- **Source type**: AI generation — see recipes.md for prompts/settings/outputs

### R2 — Hand-drawn board

- **Source type**: human-made — see recipes.md for N/A tool/prompts/settings/seed

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Square contrast | Luminance / color-blind sim | PAL.K1 |
| K2 | Spec S1–S7 | Look review | Spec met |
| K3 | Budget | File size | ≤ 400 KB |
| K4 | Cafe calm | Look vs AES.P3 | Quiet wood, not tournament chrome |
| K5 | Orientation | Inspect h1 | Light square bottom-right |

## Naming

- **Handle name**: `board-backgrounds/play-table`
- **Path**: `board-backgrounds/<name>.png` or `.svg` under `game_assets/`
