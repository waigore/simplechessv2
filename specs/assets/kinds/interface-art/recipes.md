# Interface art — Recipes

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../../.agents/specs/rules/assets/kinds.md).

Parent: [`../interface-art.md`](../interface-art.md).

## Coverage

N/A — see parent.

## Specification

N/A — see parent.

## Budgets

N/A — see parent.

## Style series

### SS1 — primary

N/A — see [`style-series.md`](style-series.md).

#### Prompt policy

N/A — see [`style-series.md`](style-series.md).

## Recipes

### R1 — Recraft UI surface

- **Source type**: AI generation
- **Tool role**: TL.1
- **Inputs**: style anchors when set
- **Prompt template (bootstrap)**: cream panel button surface; compose with prompt_policy
- **Prompt template (series)**: {panel\|chip} surface; compose with prompt_policy
- **Settings**: Recraft style when active; alpha edges
- **Seed policy**: record or `n/a`
- **Post-processing**: 9-slice guides if PNG; strip text
- **Outputs**: V1 and V2 files

### R2 — Human-made UI surface

- **Source type**: human-made
- **Tool role**: N/A — human-made
- **Inputs**: coverage subject; style series anchors when set
- **Prompt template (bootstrap)**: N/A — human-made
- **Prompt template (series)**: N/A — human-made
- **Settings**: N/A — human-made
- **Seed policy**: N/A — human-made
- **Post-processing**: 9-slice guides if PNG; strip text
- **Outputs**: V1 and V2 files

## Checks

N/A — see parent.

## Naming

N/A — see parent.
