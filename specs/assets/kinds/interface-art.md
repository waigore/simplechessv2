# Asset Kind: Interface art

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Interface art
- **Source types**: AI generation; human-made
- **Style**: [AES.P3](../../aesthetics/aesthetics.md); [UIS.F1](../../aesthetics/ui-style.md) [UIS.F2](../../aesthetics/ui-style.md); [PAL.S3](../../aesthetics/palette.md) C9 C10 C6
- **Tool roles**: TL.1
- **Approval**: As hub
- **Serves**: Cafe calm; Localization layouts; mode-pick / setup / result / play chrome

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Panel / button surface | Default cream panel (UIS.F1) | 1 |
| V2 | Tooltip / chip surface | Lighter UIS.F2 treatment | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Look | Flat cream (C10); thin warm border (C5 family); soft radius (UIS.F1) |
| S2 | Medium | SVG or 9-slice PNG with alpha |
| S3 | Text | No baked-in copy (Localization) |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per asset | ≤ 100 KB | Load time; G1 |

## Style series

Full fields: [`interface-art/style-series.md`](interface-art/style-series.md).

### SS1 — primary

- **State**: active — see style-series.md for binding, anchors, aesthetics

#### Prompt policy

N/A — see [`interface-art/style-series.md`](interface-art/style-series.md).

## Recipes

Full recipes: [`interface-art/recipes.md`](interface-art/recipes.md).

### R1 — Recraft UI surface

- **Post-processing**: 9-slice guides if PNG; strip text; see recipes.md

### R2 — Human-made UI surface

- **Source type**: human-made — see recipes.md for N/A tool/prompts/settings/seed

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | No baked text | Inspect | Empty of glyphs |
| K2 | Contrast ready | C9 on C10 region | PAL.K4 feasible |
| K3 | Budget | File size | ≤ 100 KB |
| K4 | Quiet UI | Look vs AES.P3 | Apart from board; calm |
| K5 | Spec S2 | File inspect | SVG or 9-slice PNG with alpha |
| K6 | Spec S1 | Inspect | Flat cream fill; thin warm border; soft radius (UIS.F1) |
| K7 | Readable at min panel | Look at smallest phone-width panel screens use | Soft radius and warm border still clear; surface not mush |

## Naming

- **Handle name**: `interface-art/<panel\|chip>-surface`
- **Path**: `interface-art/<name>.svg` or `.png` under `game_assets/`
