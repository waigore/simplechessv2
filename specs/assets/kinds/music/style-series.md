# Music — Style series

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

- **State**: active
- **Modality**: music
- **Enforce**: hard
- **Style anchors**: `01a15200-69b2-7d13-a30d-696fa4ff390b` (`music/cafe-ambient-a`), `01a15200-69b2-7964-a602-ad5b19583125` (`music/cafe-ambient-b`)
- **Style binding**: ElevenLabs `elevenlabs_finetune_id` `emkyd6q7yw5tfkcdajro`; model per [`docs/asset-tools-elevenlabs.md`](../../../../docs/asset-tools-elevenlabs.md); name `simplechessv2-music-SS1`; Audio Reference `optional`
- **Aesthetics**: AES.P3; SND.M1 M2; SND.L1
- **Built from**: the two anchors above, 2026-10-19
- **Refresh when**: aesthetics or anchors change, or review Fails

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative.
- **Master**: quiet cafe ambient; acoustic / light jazz; no lyrics; unhurried table (SND.M1 M2)
- **Negative**: EDM drop; vocals; stadium anthem; horror drones; loud mastering (vs SND.M1 M2; SND.L1)

## Recipes

N/A — see [`recipes.md`](recipes.md).

## Checks

N/A — see parent.

## Naming

N/A — see parent.
