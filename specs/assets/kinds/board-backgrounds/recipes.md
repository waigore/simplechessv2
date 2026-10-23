# Board backgrounds — Recipes

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../../.agents/specs/rules/assets/kinds.md).

Parent: [`../board-backgrounds.md`](../board-backgrounds.md).

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

### R1 — Recraft board

- **Source type**: AI generation
- **Tool role**: TL.1
- **Inputs**: style anchors when set
- **Prompt template (bootstrap)**: mahogany 8×8 on cafe table; compose with prompt_policy
- **Prompt template (series)**: board plane {slot}; compose with prompt_policy
- **Settings**: Recraft style when active; palette-locked C1 C2 C5; square canvas
- **Seed policy**: record or `n/a`
- **Post-processing**: S5–S7 (orient BR light; rasterize; layout JSON)
- **Outputs**: one V1 file; preview via `docs/asset-previews/rebuild_starting_position.py`

### R2 — Hand-drawn board

- **Source type**: human-made
- **Tool role**: N/A — human-made
- **Inputs**: V1 subject; style series anchors when set
- **Prompt template (bootstrap)**: N/A — human-made
- **Prompt template (series)**: N/A — human-made
- **Settings**: N/A — human-made
- **Seed policy**: N/A — human-made
- **Post-processing**: S5–S7 (orient BR light; rasterize; layout JSON)
- **Outputs**: one V1 file; preview via `docs/asset-previews/rebuild_starting_position.py`

## Checks

N/A — see parent.

## Naming

N/A — see parent.
