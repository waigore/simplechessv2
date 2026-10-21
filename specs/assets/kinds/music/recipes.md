# Music — Recipes

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../../.agents/specs/rules/assets/kinds.md).

Parent: [`../music.md`](../music.md).

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

### R1 — ElevenLabs music

- **Source type**: AI generation
- **Tool role**: TL.3
- **Inputs**: finetune when active; Audio Reference optional
- **Prompt template (bootstrap)**: soft cafe ambient bed; compose with prompt_policy
- **Prompt template (series)**: ambient bed {a\|b}; compose with prompt_policy
- **Settings**: duration ~3 min; finetune_id when active
- **Seed policy**: `n/a` when tool has no seed
- **Post-processing**: trim ends; loudness L1; OGG
- **Outputs**: one file per V row

## Checks

N/A — see parent.

## Naming

N/A — see parent.
