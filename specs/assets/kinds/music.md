# Asset Kind: Music

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Music
- **Source types**: AI generation; human-made
- **Style**: P3; [SND.M1](../../aesthetics/sound.md) [SND.M2](../../aesthetics/sound.md); [SND.L1](../../aesthetics/sound.md)
- **Tool roles**: TL.3
- **Approval**: As hub
- **Serves**: Cafe calm; mode pick and all play; Instant play; [experience.md](../../design/experience.md) playlist

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Cafe ambient bed A (M1) | One ~3 min bed | 1 |
| V2 | Cafe ambient bed B (M2) | One ~3 min bed | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Genre | Soft cafe ambient — acoustic guitar / light jazz; no lyrics (M1/M2) |
| S2 | Tempo | 70–90 BPM |
| S3 | Loudness | About −18 LUFS integrated (L1); always under SFX |
| S4 | Duration | About 3 minutes per bed; end-to-end (not a loop) |
| S5 | Format | OGG |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per bed file | ≤ 3 MB OGG | Load time; G1 |
| B2 | Kind total | 2 assets | Coverage |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: music
- **Enforce**: hard
- **Style anchors**: None yet
- **Style binding**: Audio Reference policy `optional`; finetune id TBD — ElevenLabs finetune id after `APR.establish-style`?
- **Aesthetics**: P3; SND.M1 M2; SND.L1
- **Built from**: None
- **Refresh when**: aesthetics change, anchor set change, or review Fail pattern

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative; cite IDs only.
- **Master**: quiet cafe ambient; acoustic / light jazz; no lyrics; unhurried table (M1/M2)
- **Negative**: EDM drop; vocals; stadium anthem; horror drones; loud mastering

## Recipes

### R1 — ElevenLabs music

- **Source type**: AI generation
- **Tool role**: TL.3
- **Inputs**: finetune when active; Audio Reference optional
- **Prompt template (bootstrap)**: soft cafe ambient bed; compose with prompt_policy
- **Prompt template (series)**: ambient bed {a\|b}; compose with prompt_policy
- **Settings**: duration ~3 min; finetune_id when active
- **Seed policy**: `n/a` when tool has no seed
- **Post-processing**: trim ends for playlist handoff; loudness toward L1; OGG encode
- **Outputs**: one file per V1 and V2

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Genre / lyrics | Listen | M1/M2; no lyrics; V1 and V2 same style |
| K2 | Loudness | Meter | ~L1; under SFX |
| K3 | Duration | Measure | 3 min ±30 s |
| K4 | Budget | File size | ≤ 3 MB |
| K5 | Playlist join | Listen A→B and B→A | Clean start; no harsh cut |
| K6 | Spec S2 | Measure | 70–90 BPM |
| K7 | Spec S5 | File extension | OGG |

## Naming

- **Handle name**: `music/cafe-ambient-a`, `music/cafe-ambient-b`
- **Path**: `music/<name>.ogg` under `game_assets/`
