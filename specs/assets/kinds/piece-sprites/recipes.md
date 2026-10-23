# Piece sprites — Recipes

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../../.agents/specs/rules/assets/kinds.md).

Parent: [`../piece-sprites.md`](../piece-sprites.md).

## Coverage

N/A — see parent.

## Specification

N/A — see parent (S5–S9 pipeline).

## Budgets

N/A — see parent.

## Style series

### SS1 — primary

N/A — see [`style-series.md`](style-series.md).

#### Prompt policy

N/A — see [`style-series.md`](style-series.md).

## Recipes

### R1 — Recraft series / bootstrap

- **Source type**: AI generation
- **Tool role**: TL.1
- **Inputs**: style anchors when set; optional 6-col sheet as S7 pipeline input only
- **Prompt template (bootstrap)**: Staunton {type} {side}; flat fills; ivory or charcoal; silhouette readable; compose with prompt_policy
- **Prompt template (series)**: {type} {side} only; compose with prompt_policy
- **Settings**: transparent; square; Recraft `input_style_id` when active
- **Seed policy**: record when returned; else `n/a`
- **Post-processing**: parent S5–S9 (rasterize per S5 → edge flood-fill → S7 crop sheet to twelve cells → fit_contain → preview box 0.88)
- **Outputs**: twelve V1 files (`piece-sprites/<type>-<white|black>`); never catalog the sheet

### R2 — Human-made piece

- **Source type**: human-made
- **Tool role**: N/A — human-made
- **Inputs**: coverage type×side; style series anchors when set; optional sheet as S7 input only
- **Prompt template (bootstrap)**: N/A — human-made
- **Prompt template (series)**: N/A — human-made
- **Settings**: N/A — human-made
- **Seed policy**: N/A — human-made
- **Post-processing**: parent S5–S9 when rasterizing or cropping a sheet; skip steps already met by the source file
- **Outputs**: twelve V1 files (`piece-sprites/<type>-<white|black>`); never catalog the sheet

## Checks

N/A — see parent.

## Naming

N/A — see parent.
