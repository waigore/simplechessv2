# Sound effects — Recipes

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../../.agents/specs/rules/assets/kinds.md).

Parent: [`../sound-effects.md`](../sound-effects.md).

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

### R1 — ElevenLabs SFX

- **Source type**: AI generation
- **Tool role**: TL.2
- **Inputs**: soft anchors when set
- **Prompt template (bootstrap)**: wood tactile {category} cue; compose with prompt_policy
- **Prompt template (series)**: {category} only; compose with prompt_policy
- **Settings**: duration in S1 band; mono OK
- **Seed policy**: `n/a` when tool has no seed
- **Post-processing**: trim silence; true peak to L2 (−14 dBTP); encode OGG
- **Outputs**: one file per V row

### R2 — Human-made SFX

- **Source type**: human-made
- **Tool role**: N/A — human-made
- **Inputs**: coverage subject; style series anchors when set
- **Prompt template (bootstrap)**: N/A — human-made
- **Prompt template (series)**: N/A — human-made
- **Settings**: N/A — human-made
- **Seed policy**: N/A — human-made
- **Post-processing**: trim silence; true peak to L2 (−14 dBTP); encode OGG
- **Outputs**: one file per V row

## Checks

N/A — see parent.

## Naming

N/A — see parent.
