# Asset Kind: Interface art

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Interface art
- **Source types**: AI generation; human-made
- **Style**: P3; [UI.F1 F2](../../aesthetics/ui-style.md); [PAL.S3](../../aesthetics/palette.md) C9 C10 C6
- **Tool roles**: TL.1
- **Approval**: As hub
- **Serves**: Cafe calm; Localization layouts; mode-pick / setup / result / play chrome

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Panel / button surface | Default cream panel (F1) | 1 |
| V2 | Tooltip / chip surface | Lighter F2 treatment | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Look | Flat cream (C10); thin warm border (C5 family); soft radius (UI.F1) |
| S2 | Medium | SVG or 9-slice PNG with alpha |
| S3 | Text | No baked-in copy (Localization) |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per asset | ≤ 100 KB | Load time; G1 |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: visual
- **Enforce**: hard
- **Style anchors**: None yet
- **Style binding**: TBD — Recraft style id after `APR.establish-style`?
- **Aesthetics**: P3; UI.F1 F2; PAL.S3
- **Built from**: None
- **Refresh when**: aesthetics change, anchor set change, or review Fail pattern

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative.
- **Master**: quiet cafe UI panel; flat cream; soft radius; warm thin border; no chrome (UI.F1; PAL.C10; P3)
- **Negative**: glassmorphism; neon; heavy shadow stacks; esports HUD; baked text (vs UI.F1 F2; PAL.S3)

## Recipes

### R1 — Recraft UI surface

- **Source type**: AI generation
- **Tool role**: TL.1
- **Inputs**: style anchors when set
- **Prompt template (bootstrap)**: cream panel button surface; compose with prompt_policy
- **Prompt template (series)**: {panel\|chip} surface; compose with prompt_policy
- **Settings**: Recraft style when active; alpha edges
- **Seed policy**: record or `n/a`
- **Post-processing**: 9-slice guides if PNG; strip text
- **Outputs**: V1 and V2 files

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | No baked text | Inspect | Empty of glyphs |
| K2 | Contrast ready | C9 on C10 region | PAL.K4 feasible |
| K3 | Budget | File size | ≤ 100 KB |
| K4 | Quiet UI | Look vs P3 | Apart from board; calm |
| K5 | Spec S2 | File inspect | SVG or 9-slice PNG with alpha |

## Naming

- **Handle name**: `interface-art/<panel\|chip>-surface`
- **Path**: `interface-art/<name>.svg` or `.png` under `game_assets/`
