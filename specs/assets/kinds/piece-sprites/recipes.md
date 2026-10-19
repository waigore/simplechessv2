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
- **Inputs**: style anchors when set
- **Prompt template (bootstrap)**: look + Staunton {type} {side}; compose with prompt_policy
- **Prompt template (series)**: {type} {side} only; compose with prompt_policy
- **Settings**: transparent; square; Recraft `input_style_id` when active
- **Seed policy**: record when returned; else `n/a`
- **Post-processing**: parent S5–S9 (rasterize per S5 → edge flood-fill → crop → fit_contain → on-board 0.88)
- **Outputs**: one V1 file; preview via `docs/asset-previews/rebuild_starting_position.py`

## Checks

N/A — see parent.

## Naming

N/A — see parent.
