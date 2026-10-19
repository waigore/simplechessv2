# Asset Kind: Music

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Music
- **Source types**: AI generation; human-made
- **Style**: P3; [SND.M1](../../aesthetics/sound.md) [SND.M2](../../aesthetics/sound.md); [SND.L1](../../aesthetics/sound.md)
- **Tool roles**: TL.3
- **Approval**: As hub
- **Serves**: Cafe calm; Instant play; [experience.md](../../design/experience.md) playlist

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Cafe ambient bed A (M1) | One bed | 1 |
| V2 | Cafe ambient bed B (M2) | One bed | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Genre | Soft cafe ambient — acoustic guitar / light jazz; no lyrics (SND.M1 M2) |
| S2 | Tempo | 70–90 BPM |
| S3 | Loudness | ~−18 LUFS integrated (SND.L1); under SFX |
| S4 | Duration | ~3 min per bed; end-to-end, not a loop |
| S5 | Format | OGG |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per bed | ≤ 3 MB OGG | Load time; G3 |
| B2 | Kind total | 2 assets | Load time; G3 |

## Style series

### SS1 — primary

- **State**: active
- **Modality**: music
- **Enforce**: hard
- **Style anchors**: `01a15200-69b2-7d13-a30d-696fa4ff390b` (`music/cafe-ambient-a`), `01a15200-69b2-7964-a602-ad5b19583125` (`music/cafe-ambient-b`)
- **Style binding**: ElevenLabs `elevenlabs_finetune_id` `emkyd6q7yw5tfkcdajro`; model per [`docs/asset-tools-elevenlabs.md`](../../../docs/asset-tools-elevenlabs.md); name `simplechessv2-music-SS1`; Audio Reference `optional`
- **Aesthetics**: P3; SND.M1 M2; SND.L1
- **Built from**: the two anchors above, 2026-10-19
- **Refresh when**: aesthetics or anchors change, or review Fails

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative.
- **Master**: quiet cafe ambient; acoustic / light jazz; no lyrics; unhurried table (SND.M1 M2)
- **Negative**: EDM drop; vocals; stadium anthem; horror drones; loud mastering (vs SND.M1 M2; SND.L1)

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

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Genre / lyrics | Listen | SND.M1 M2; no lyrics; V1 and V2 same style |
| K2 | Loudness | Meter | ~L1; under SFX |
| K3 | Duration | Measure | 3 min ±30 s |
| K4 | Budget | File size | ≤ 3 MB |
| K5 | Playlist join | Listen A→B and B→A | Clean start; no harsh cut |
| K6 | Spec S2 | Measure | 70–90 BPM |
| K7 | Spec S5 | File extension | OGG |
| K8 | Budget B2 | Catalog count | 2 |

## Naming

- **Handle name**: `music/cafe-ambient-a`, `music/cafe-ambient-b`
- **Path**: `music/<name>.ogg` under `game_assets/`
