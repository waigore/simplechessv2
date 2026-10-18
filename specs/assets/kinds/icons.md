# Asset Kind: Icons

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Icons
- **Source types**: AI generation; human-made
- **Style**: P3; [UI.I1](../../aesthetics/ui-style.md); [PAL.C9 C6](../../aesthetics/palette.md)
- **Tool roles**: TL.1
- **Approval**: As hub
- **Serves**: Mode pick C1–C3; play controls; Cafe calm

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Mode: Shared game | One glyph | 1 |
| V2 | Mode: Puzzle stream | One glyph | 1 |
| V3 | Quit / leave sitting | One glyph | 1 |
| V4 | Back | One glyph | 1 |
| V5 | Advice on/off | One glyph (or two states) | 1–2 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Grid | 24×24 art units (UI.I1) |
| S2 | Style | Flat fill preferred; stroke 1.5 art units if stroked; soft round; flat perspective |
| S3 | Medium | SVG preferred |
| S4 | Color | Monochrome ink/gold; tinted in engine OK |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per icon | ≤ 20 KB | Load time; G1 |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: visual
- **Enforce**: hard
- **Style anchors**: None yet
- **Style binding**: TBD — Recraft style id after `APR.establish-style`?
- **Aesthetics**: P3; UI.I1; PAL.C9 C6
- **Built from**: None
- **Refresh when**: aesthetics change, anchor set change, or review Fail pattern

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative.
- **Master**: flat 24 grid cafe UI icon; soft round; simple silhouette
- **Negative**: skeuomorphic; 3D; emoji style; busy detail; esports badges

## Recipes

### R1 — Recraft icon

- **Source type**: AI generation
- **Tool role**: TL.1
- **Inputs**: style anchors when set
- **Prompt template (bootstrap)**: 24 grid flat icon {subject}; compose with prompt_policy
- **Prompt template (series)**: {subject} icon; compose with prompt_policy
- **Settings**: transparent; Recraft style when active
- **Seed policy**: record or `n/a`
- **Post-processing**: fit 24 grid; mono SVG clean
- **Outputs**: one file per coverage row

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Grid / stroke | Inspect | UI.I1 |
| K2 | Readable at UI size | Look on phone-width | Recognizable subject |
| K3 | Budget | File size | ≤ 20 KB |
| K4 | Style | Look vs P3 | Quiet, flat |

## Naming

- **Handle name**: `icons/<subject>` (e.g. `icons/mode-shared`)
- **Path**: `icons/<name>.svg` under `game_assets/`
