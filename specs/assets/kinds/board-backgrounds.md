# Asset Kind: Board backgrounds

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Backgrounds
- **Source types**: AI generation; human-made
- **Style**: P3; [PAL.C1 C2 C5](../../aesthetics/palette.md); [SRF.M1](../../aesthetics/surface.md); [FRM.S2](../../aesthetics/form.md)
- **Tool roles**: TL.1
- **Approval**: As hub
- **Serves**: Cafe calm; Clear board; [PER.R2](../../view/perception.md); Shared/Puzzle play

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Play board plane | One mahogany table + 8×8 light/dark squares | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Layout | Full 8×8 grid readable; optional soft wood grain never breaks squares (SRF.M1) |
| S2 | Colors | Light C1 / dark C2 / table C5 (PAL.S1); contrast [PAL.K1](../../aesthetics/palette.md) |
| S3 | Medium | SVG or PNG; square or board-aspect canvas |
| S4 | Overlays | No piece art; no chrome badges |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per asset | ≤ 400 KB | Load time; G2 |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: visual
- **Enforce**: hard
- **Style anchors**: None yet
- **Style binding**: TBD — Recraft style id after `APR.establish-style`?
- **Aesthetics**: P3; PAL.C1 C2 C5; SRF.M1; FRM.S2
- **Built from**: None
- **Refresh when**: aesthetics change, anchor set change, or review Fail pattern

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative.
- **Master**: quiet mahogany cafe table chessboard; warm wood; soft daylight (SRF.L1); square readability first
- **Negative**: neon; esports chrome; 3D perspective board; cluttered props; blood

## Recipes

### R1 — Recraft board

- **Source type**: AI generation
- **Tool role**: TL.1
- **Inputs**: style anchors when set
- **Prompt template (bootstrap)**: mahogany 8×8 board on cafe table; compose with prompt_policy
- **Prompt template (series)**: board plane variant {slot}; compose with prompt_policy
- **Settings**: Recraft style when active; high square clarity
- **Seed policy**: record or `n/a`
- **Post-processing**: align grid if needed; crush size
- **Outputs**: one V1 file

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Square contrast | Luminance / color-blind sim | PAL.K1 |
| K2 | Spec S1–S4 | Look review | Spec met |
| K3 | Budget | File size | ≤ 400 KB |
| K4 | Cafe calm | Look vs P3 | Quiet wood, not tournament chrome |

## Naming

- **Handle name**: `board-backgrounds/play-table`
- **Path**: `board-backgrounds/<name>.png` or `.svg` under `game_assets/`
