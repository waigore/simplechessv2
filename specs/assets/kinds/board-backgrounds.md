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
| V1 | Play board plane | One mahogany table + 8×8 light/dark | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Layout | Full 8×8 readable; soft grain never breaks squares (SRF.M1) |
| S2 | Colors | Light C1 / dark C2 / table C5 (PAL.S1); contrast [PAL.K1](../../aesthetics/palette.md) |
| S3 | Medium | SVG or PNG; square or board-aspect |
| S4 | Overlays | No piece art; no chrome badges |
| S5 | Orientation | Light square bottom-right (h1); rotate SVG if needed |
| S6 | Rasterize | Recraft SVG → PNG via Chrome headless only (not qlmanage/rsvg) |
| S7 | Square layout | Centers + pitch in `starting-position.layout.json`; pieces 0.88 fill ([piece S9](piece-sprites.md)) |

S5–S7 definitive for SS1 look. Reproduce: [`docs/asset-previews/README.md`](../../../docs/asset-previews/README.md).

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Per asset | ≤ 400 KB | Load time; G2 |

## Style series

### SS1 — primary

- **State**: active
- **Modality**: visual
- **Enforce**: hard
- **Style anchors**: `01a14f8e-1cfa-7e93-bc94-ef0e7b4e3855` (`board-backgrounds/play-table`)
- **Style binding**: reuses piece-sprites SS1 Recraft `recraft_style_id` `58840487-cf72-41fa-b83f-5773ea7a1c11` (no separate board style)
- **Aesthetics**: P3; PAL.C1 C2 C5; SRF.M1; FRM.S2
- **Built from**: `01a14f8e-1cfa-7e93-bc94-ef0e7b4e3855` on 2026-10-19 (palette-remapped; binding shared with piece-sprites SS1)
- **Refresh when**: aesthetics / anchors change, piece SS1 refresh, or review Fail pattern

#### Prompt policy

- **Compose**: subject-first when `active`; append master + negative; cite IDs only.
- **Master**: quiet mahogany cafe chessboard; warm wood; soft daylight (SRF.L1); square readability first
- **Negative**: neon; esports chrome; 3D perspective board; cluttered props; blood

## Recipes

### R1 — Recraft board

- **Source type**: AI generation
- **Tool role**: TL.1
- **Inputs**: style anchors when set
- **Prompt template (bootstrap)**: mahogany 8×8 on cafe table; compose with prompt_policy
- **Prompt template (series)**: board plane {slot}; compose with prompt_policy
- **Settings**: Recraft style when active; high square clarity
- **Seed policy**: record or `n/a`
- **Post-processing**: S5–S7 (orient BR light; Chrome rasterize; layout JSON); crush
- **Outputs**: one V1 file; preview via `docs/asset-previews/rebuild_starting_position.py`

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Square contrast | Luminance / color-blind sim | PAL.K1 |
| K2 | Spec S1–S7 | Look review | Spec met |
| K3 | Budget | File size | ≤ 400 KB |
| K4 | Cafe calm | Look vs P3 | Quiet wood, not tournament chrome |
| K5 | Orientation | Inspect h1 | Light square bottom-right |

## Naming

- **Handle name**: `board-backgrounds/play-table`
- **Path**: `board-backgrounds/<name>.png` or `.svg` under `game_assets/`
