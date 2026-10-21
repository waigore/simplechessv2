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
| S4 | Duration | 150–210 s (3 min ±30 s); end-to-end, not a loop |
| S5 | Format | OGG |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per bed | ≤ 3 MB OGG | Load time; G3 |
| B2 | Kind total | 2 assets | Load time; G3 |

## Style series

Full fields: [`music/style-series.md`](music/style-series.md).

### SS1 — primary

- **State**: active — see style-series.md for binding, anchors, aesthetics

#### Prompt policy

N/A — see [`music/style-series.md`](music/style-series.md).

## Recipes

Full recipe: [`music/recipes.md`](music/recipes.md).

### R1 — ElevenLabs music

- **Post-processing**: trim ends; loudness L1; OGG; see recipes.md

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Genre / lyrics | Listen | SND.M1 M2; no lyrics; V1 and V2 same style |
| K2 | Loudness | Meter | ~L1; under SFX |
| K3 | Duration | Measure | 150–210 s (3 min ±30 s); [`CAT.I11`](../catalog/audio-duration.md) |
| K4 | Budget | File size | ≤ 3 MB |
| K5 | Playlist join | Listen A→B and B→A | Clean start; no harsh cut |
| K6 | Spec S2 | Measure | 70–90 BPM |
| K7 | Spec S5 | File extension | OGG |
| K8 | Budget B2 | Catalog count | 2 |

## Naming

- **Handle name**: `music/cafe-ambient-a`, `music/cafe-ambient-b`
- **Path**: `music/<name>.ogg` under `game_assets/`
