# Asset Kind: Sound effects

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Sound effects
- **Source types**: AI generation; human-made
- **Style**: [AES.P1](../../aesthetics/aesthetics.md); [AES.P3](../../aesthetics/aesthetics.md); [SND.X1–X5](../../aesthetics/sound.md); [SND.L2](../../aesthetics/sound.md)
- **Tool roles**: TL.2
- **Approval**: As hub
- **Serves**: Instant play; Cafe calm; experience feedback; Shared/Puzzle play

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Touch / select (X1) | One cue | 1 |
| V2 | Movement settle (X2) | One cue | 1 |
| V3 | Check (X3) | One cue | 1 |
| V4 | End (checkmate / resign / clock) (X4) | One cue | 1 |
| V5 | Puzzle wrong move (X5) | One cue | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Durations | X1 0.05–0.15 s; X2 0.08–0.15 s; X3 0.10–0.25 s; X4 0.20–0.40 s; X5 0.08–0.20 s |
| S2 | Character | Wood / tactile; soft cafe; never gates a move ([AES.P1](../../aesthetics/aesthetics.md)) |
| S3 | Loudness | −14 dBTP true peak (ITU-R BS.1770-4, 4× oversampling) ([SND.L2](../../aesthetics/sound.md)) |
| S4 | Format | OGG |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per cue | ≤ 100 KB OGG | Load time; G2 |

## Style series

Full fields: [`sound-effects/style-series.md`](sound-effects/style-series.md).

### SS1 — primary

- **State**: active — see style-series.md for binding, anchors, aesthetics

#### Prompt policy

N/A — see [`sound-effects/style-series.md`](sound-effects/style-series.md).

## Recipes

Full recipes: [`sound-effects/recipes.md`](sound-effects/recipes.md).

### R1 — ElevenLabs SFX

- **Post-processing**: trim silence; true peak to −14 dBTP (L2); OGG; see recipes.md

### R2 — Human-made SFX

- **Source type**: human-made — see recipes.md for N/A tool/prompts/settings/seed

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Duration | Measure | Within S1 for category; [`CAT.I11`](../catalog/audio-duration.md) |
| K2 | Loudness | True-peak meter | −14 dBTP (L2) |
| K3 | Character / voice | Listen vs X*; fail voice | Wood/cafe; not chrome; no voice ([SND.V1](../../aesthetics/sound.md)) |
| K4 | Budget | File size | ≤ 100 KB |
| K5 | Spec S4 | File extension | OGG |

## Naming

- **Handle name**: `sound-effects/<x-category>` (e.g. `sound-effects/move-settle`)
- **Path**: `sound-effects/<name>.ogg` under `game_assets/`
