# Icons — Recipes

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../../.agents/specs/rules/assets/kinds.md).

Parent: [`../icons.md`](../icons.md).

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

### R1 — Recraft icon

- **Source type**: AI generation
- **Tool role**: TL.1
- **Inputs**: style anchors when set
- **Prompt template (bootstrap)**: 24 grid flat icon {subject}; compose with prompt_policy
- **Prompt template (series)**: {subject} icon; compose with prompt_policy
- **Settings**: transparent; Recraft style when active
- **Seed policy**: record or `n/a`
- **Post-processing**: fit 24 grid; mono SVG clean
- **Outputs**: one file per coverage row

### R2 — Human-made icon

- **Source type**: human-made
- **Tool role**: N/A — human-made
- **Inputs**: coverage subject; style series anchors when set
- **Prompt template (bootstrap)**: N/A — human-made
- **Prompt template (series)**: N/A — human-made
- **Settings**: N/A — human-made
- **Seed policy**: N/A — human-made
- **Post-processing**: fit 24 grid; mono SVG clean
- **Outputs**: one file per coverage row

## Checks

N/A — see parent.

## Naming

N/A — see parent.
