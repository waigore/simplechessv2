# Asset Kind: Icons

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Icons
- **Source types**: AI generation; human-made
- **Style**: [AES.P3](../../aesthetics/aesthetics.md); [UIS.I1](../../aesthetics/ui-style.md); [PAL.C9 C6](../../aesthetics/palette.md)
- **Tool roles**: TL.1
- **Approval**: As hub
- **Serves**: Mode pick C1–C3; play controls; Cafe calm

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Mode: Shared game | One glyph | 1 |
| V2 | Mode: Puzzle stream | One glyph | 1 |
| V3 | Quit / leave sitting | One glyph | 1 |
| V4 | Back | One glyph | 1 |
| V5 | Advice on/off | One on/off glyph | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Grid | 24×24 art units (UIS.I1) |
| S2 | Style | Flat fill preferred; stroke 1.5 art units if stroked; soft round; flat perspective |
| S3 | Medium | SVG preferred |
| S4 | Color | Monochrome ink/gold; tinted in engine OK |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per icon | ≤ 20 KB | Load time; G1 |

## Style series

Full fields: [`icons/style-series.md`](icons/style-series.md).

### SS1 — primary

- **State**: active — see style-series.md for binding, anchors, aesthetics

#### Prompt policy

N/A — see [`icons/style-series.md`](icons/style-series.md).

## Recipes

Full recipes: [`icons/recipes.md`](icons/recipes.md).

### R1 — Recraft icon

- **Post-processing**: fit 24 grid; mono SVG clean; see recipes.md

### R2 — Human-made icon

- **Source type**: human-made — see recipes.md for N/A tool/prompts/settings/seed

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Grid / stroke | Inspect | UIS.I1 |
| K2 | Readable at UI size | Look on phone-width | Recognizable subject |
| K3 | Budget | File size | ≤ 20 KB |
| K4 | Style | Look vs AES.P3 | Quiet, flat |
| K5 | Spec S3 | File inspect | SVG shipped (preferred), or justified PNG |
| K6 | Spec S4 | Inspect | Monochrome ink (C9) / gold (C6); tint-safe |

## Naming

- **Handle name**: `icons/<subject>` (e.g. `icons/mode-shared`)
- **Path**: `icons/<name>.svg` under `game_assets/`
