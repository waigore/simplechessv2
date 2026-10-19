# Asset Kind: Fonts

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Fonts
- **Source types**: Third-party; human-made
- **Style**: P3; [UI.T1 T2 T3](../../aesthetics/ui-style.md); Accessibility; Localization
- **Tool roles**: None — import/register only
- **Approval**: As hub
- **Serves**: Localization (`en`, `zh-Hant`, `ja`); Accessibility text size; all UX screens

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | UI family for T1–T3 | One family (or paired) covering Latin, Traditional Chinese, Japanese; tabular figures preferred for T3 | 1–2 files |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Classification | Humanist sans; weights for semibold (T1), regular (T2), medium (T3) |
| S2 | Scripts | Latin + zh-Hant + ja glyphs needed for shipped UI copy |
| S3 | License | Allows Web embedding / no-install browser game |
| S4 | Format | TTF/OTF/WOFF2 ([ADR-0005](../../adr/decisions/0005-asset-catalog-roots.md)) |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Kind total download | ≤ 2 MB compressed preferred | Load time; G1 |

## Style series

### SS1 — primary

- **State**: active
- **Modality**: visual
- **Enforce**: soft
- **Style anchors**: `01a15215-15bd-7e3f-a3f8-ffcb1333a0ab` (`fonts/noto-sans`), `01a15215-15bd-77a5-b804-9ea4d95880a4` (`fonts/noto-sans-cjk`)
- **Style binding**: None — third-party soft exemplars (not Recraft)
- **Aesthetics**: P3; UI.T1–T3
- **Built from**: the two anchors above on 2026-10-19 (Noto Sans OFL; PO-confirmed)
- **Refresh when**: UI type roles or locale set change

#### Prompt policy

- **Compose**: N/A — no AI generate recipe
- **Master**: N/A — third-party fonts; no prompt
- **Negative**: N/A — third-party fonts; no prompt

## Recipes

### R1 — Third-party import

- **Source type**: Third-party
- **Tool role**: N/A — human-made / import
- **Inputs**: License proof; font files
- **Prompt template (bootstrap)**: N/A — human-made
- **Prompt template (series)**: N/A — human-made
- **Settings**: N/A — human-made
- **Seed policy**: N/A — human-made
- **Post-processing**: Subset if needed; keep license file reference in catalog
- **Outputs**: V1 font file(s) under naming path

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Scripts | Spot-check UI strings in three locales | No tofu for shipped copy |
| K2 | Legibility | Smallest shipped size on phone-width | Accessibility |
| K3 | License | Catalog F12 | Web-embed allowed |
| K4 | Budget | Total size | ≤ ~2 MB or justified exception in review |
| K5 | Spec S1 | Font file inspect | Humanist sans; T1–T3 weights present |
| K6 | Spec S4 | File extension | TTF / OTF / WOFF2 |

## Naming

- **Handle name**: `fonts/<family>-<weight>`
- **Path**: `fonts/<name>.woff2` (or `.ttf`) under `game_assets/`
