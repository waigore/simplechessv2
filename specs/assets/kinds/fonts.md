# Asset Kind: Fonts

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Fonts
- **Source types**: Third-party; human-made
- **Style**: [AES.P3](../../aesthetics/aesthetics.md); [UIS.T1](../../aesthetics/ui-style.md) [UIS.T2](../../aesthetics/ui-style.md) [UIS.T3](../../aesthetics/ui-style.md); Accessibility; Localization
- **Tool roles**: None — import/register only
- **Approval**: As hub
- **Serves**: Localization (`en`, `zh-Hant`, `ja`); Accessibility text size; all UX screens

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | UI family for UIS.T1–T3 | One family (or paired) covering Latin, Traditional Chinese, Japanese; tabular figures preferred for UIS.T3 | 1–2 files |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Classification | Humanist sans; weights for semibold (UIS.T1), regular (UIS.T2), medium (UIS.T3) |
| S2 | Scripts | Latin + zh-Hant + ja glyphs needed for shipped UI copy |
| S3 | License | Allows Web embedding / no-install browser game |
| S4 | Format | TTF/OTF/WOFF2 ([ADR-0005](../../adr/decisions/0005-asset-catalog-roots.md)) |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Kind total download | ≤ 2 MB compressed (sum of shipped font file sizes under this kind) | Load time; G1 |

## Style series

Full fields: [`fonts/style-series.md`](fonts/style-series.md).

### SS1 — primary

- **State**: active — see style-series.md for binding, anchors, aesthetics

#### Prompt policy

N/A — see [`fonts/style-series.md`](fonts/style-series.md).

## Recipes

Full recipe: [`fonts/recipes.md`](fonts/recipes.md).

### R1 — Third-party import

- **Post-processing**: subset if needed; see recipes.md for inputs/outputs

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Scripts | Spot-check UI strings in three locales | No tofu for shipped copy |
| K2 | Legibility | Smallest shipped size on phone-width | Accessibility |
| K3 | License | Catalog F12 | Web-embed allowed |
| K4 | Budget | Sum compressed byte sizes of all shipped font files for this kind | ≤ 2 MB |
| K5 | Spec S1 | Font file inspect | Humanist sans; UIS.T1–T3 weights present |
| K6 | Spec S4 | File extension | TTF / OTF / WOFF2 |
| K7 | Style vs pillars | Compare a new font by eye to the two `SS1` anchors | Shares their humanist-sans family character and weight/letterform feel; `K1`–`K6` still pass ([AES.P3](../../aesthetics/aesthetics.md); [UIS.T1](../../aesthetics/ui-style.md)–[UIS.T3](../../aesthetics/ui-style.md)) |

## Naming

- **Handle name**: `fonts/<family>-<weight>`
- **Path**: `fonts/<name>.woff2` (or `.ttf`) under `game_assets/`
