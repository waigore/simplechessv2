# Asset Kind: Piece sprites

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Sprites
- **Source types**: AI generation; human-made
- **Style**: P2, P3; [FRM.S1](../../aesthetics/form.md) [FRM.L1](../../aesthetics/form.md) [FRM.D1](../../aesthetics/form.md); [PAL.S1](../../aesthetics/palette.md) C3 C4
- **Tool roles**: TL.1
- **Approval**: As hub
- **Serves**: Clear board; Instant play; [E-pieces](../../design/entities/pieces.md); [PER.R1](../../view/perception.md)

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Each piece type (K Q R B N P) | White (ivory C3); Black (charcoal C4) | 12 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Canvas | Square; body fills ~85% ([SPC.E1](../../view/spatial-model.md)); transparent outside |
| S2 | Medium | SVG preferred ([ADR-0005](../../adr/decisions/0005-asset-catalog-roots.md)); PNG alpha OK |
| S3 | Detail | ≤ 3 fill regions; Staunton-inspired; height order [FRM.P2](../../aesthetics/form.md) |
| S4 | Anchor | Center of square |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per asset file | ≤ 80 KB SVG/PNG | Load time |
| B2 | Kind total | 12 assets (6 types × 2 sides per V1) | Load time; G2 |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: visual
- **Enforce**: hard
- **Style anchors**: None yet
- **Style binding**: TBD — Recraft style id after `APR.establish-style`?
- **Aesthetics**: P2 P3; PAL.S1; FRM.S1 L1 D1
- **Built from**: None
- **Refresh when**: aesthetics change, anchor set change, or review Fail pattern

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative; cite IDs only.
- **Master**: Staunton vector chess piece; flat fills; ivory/charcoal side; readable silhouette (FRM.L1); cafe calm not chrome (P3)
- **Negative**: pixel art; 3D render; blood; rank badges; AI avatar; busy texture; neon; tournament UI

## Recipes

### R1 — Recraft series / bootstrap

- **Source type**: AI generation
- **Tool role**: TL.1
- **Inputs**: style anchors when set; no REF images yet
- **Prompt template (bootstrap)**: look + Staunton {type} {side}; compose with prompt_policy
- **Prompt template (series)**: {type} {side} only; compose with prompt_policy
- **Settings**: transparent background; square canvas; Recraft `input_style_id` when active
- **Seed policy**: record seed when tool returns one; else `n/a`
- **Post-processing**: trim; ensure transparency; SVG clean or PNG crush
- **Outputs**: one file per V1 variant under naming path

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Silhouette | Solid-black at ~1/12 frame height | Type named (FRM.L1 / Accessibility) |
| K2 | Spec S1–S4 | Review + file inspect | Spec met |
| K3 | Budget B1 | File size | ≤ 80 KB |
| K4 | Style vs P2 P3 | Look review | Distinct vectors; quiet mahogany mood |
| K5 | Budget B2 | Catalog count vs V1 | 12 entries (6 types × 2 sides) |

## Naming

- **Handle name**: `piece-sprites/<type>-<white\|black>` (e.g. `piece-sprites/knight-white`)
- **Path**: `piece-sprites/<name>.svg` (or `.png`) under `game_assets/`
