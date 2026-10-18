# Asset Kind: Music

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Music
- **Source types**: AI generation; human-made
- **Style**: P3; [SND.M1](../../aesthetics/sound.md); [SND.L1](../../aesthetics/sound.md)
- **Tool roles**: TL.3
- **Approval**: As hub
- **Serves**: Cafe calm; mode pick and all play; Instant play (never ducks moves)

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Cafe ambient bed (M1) | One seamless loop | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Genre | Soft cafe ambient — acoustic guitar / light jazz; no lyrics (M1) |
| S2 | Tempo | 70–90 BPM |
| S3 | Loudness | About −18 LUFS integrated (L1); always under SFX |
| S4 | Loop | Seamless; suitable for long sittings |
| S5 | Format | OGG |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Loop file | ≤ 3 MB OGG | Load time; G1 |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: music
- **Enforce**: hard
- **Style anchors**: None yet
- **Style binding**: TBD — ElevenLabs finetune id and Audio Reference policy (`optional`?) after `APR.establish-style`?
- **Aesthetics**: P3; SND.M1; SND.L1
- **Built from**: None
- **Refresh when**: aesthetics change, anchor set change, or review Fail pattern

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative.
- **Master**: quiet cafe ambient; acoustic / light jazz; no lyrics; unhurried table (M1)
- **Negative**: EDM drop; vocals; stadium anthem; horror drones; loud mastering

## Recipes

### R1 — ElevenLabs music

- **Source type**: AI generation
- **Tool role**: TL.3
- **Inputs**: finetune when active; Audio Reference optional
- **Prompt template (bootstrap)**: soft cafe ambient loop bed; compose with prompt_policy
- **Prompt template (series)**: ambient bed {mood slot}; compose with prompt_policy
- **Settings**: loopable; duration enough for seamless loop; finetune_id when active
- **Seed policy**: `n/a` when tool has no seed
- **Post-processing**: loop point edit; loudness toward L1; OGG encode
- **Outputs**: one V1 file

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Genre / lyrics | Listen | M1; no lyrics |
| K2 | Loudness | Meter | ~L1; under SFX |
| K3 | Loop | A/B loop join | No click |
| K4 | Budget | File size | ≤ 3 MB |

## Naming

- **Handle name**: `music/cafe-ambient`
- **Path**: `music/<name>.ogg` under `game_assets/`
