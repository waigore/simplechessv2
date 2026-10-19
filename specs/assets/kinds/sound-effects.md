# Asset Kind: Sound effects

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Sound effects
- **Source types**: AI generation; human-made
- **Style**: P1 P3; [SND.X1–X5](../../aesthetics/sound.md); [SND.L2](../../aesthetics/sound.md)
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
| S2 | Character | Wood / tactile; soft cafe; never gates a move (P1) |
| S3 | Loudness | Peaks toward −14 LUFS (L2) |
| S4 | Format | OGG |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per cue | ≤ 100 KB OGG | Load time; G2 |

## Style series

### SS1 — primary

- **State**: active
- **Modality**: sfx
- **Enforce**: soft
- **Style anchors**: `01a151f8-b7d8-7ae6-84af-767ba53d09f6` (`sound-effects/touch-select`), `01a151f8-b7d8-710a-b767-92c9137bfd63` (`sound-effects/move-settle`), `01a151f8-b7d8-7e05-9921-e892e9a2e064` (`sound-effects/check`), `01a151f8-b7d8-7fe3-b94f-e3a562395d96` (`sound-effects/end-resolve`), `01a151f8-b7d8-759c-89c5-e1be5eecb2b2` (`sound-effects/puzzle-fail`)
- **Style binding**: None — soft exemplars only (`soft_enforce`)
- **Aesthetics**: P1 P3; SND.X1–X5; SND.L2
- **Built from**: the five anchors above on 2026-10-19 (PO-confirmed; X1 feather-light touch)
- **Refresh when**: aesthetics change, anchor set change, or review Fail pattern

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative.
- **Master**: soft wood cafe SFX; short; unhurried table; never harsh; X1 feather-light muted brush (SND.X1–X5; SND.L2; P3)
- **Negative**: stadium crowd; synth laser; gore impact; loud alarm; voice; sharp click; hard knock (vs SND.X1–X5 character; SND.L2; SND.V1)

## Recipes

### R1 — ElevenLabs SFX

- **Source type**: AI generation
- **Tool role**: TL.2
- **Inputs**: soft anchors when set
- **Prompt template (bootstrap)**: wood tactile {category} cue; compose with prompt_policy
- **Prompt template (series)**: {category} only; compose with prompt_policy
- **Settings**: duration in S1 band; mono OK
- **Seed policy**: `n/a` when tool has no seed
- **Post-processing**: trim silence; loudness toward L2; encode OGG
- **Outputs**: one file per V row

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Duration | Measure | Within S1 for category |
| K2 | Loudness | Meter | ~L2 peaks |
| K3 | Character | Listen vs X* | Wood/cafe; not chrome |
| K4 | Budget | File size | ≤ 100 KB |
| K5 | Spec S4 | File extension | OGG |

## Naming

- **Handle name**: `sound-effects/<x-category>` (e.g. `sound-effects/move-settle`)
- **Path**: `sound-effects/<name>.ogg` under `game_assets/`
