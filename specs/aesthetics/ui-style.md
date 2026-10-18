# Interface Style

Authoring rules: [`.agents/specs/rules/aesthetics/ui-style.md`](../../.agents/specs/rules/aesthetics/ui-style.md).

- **Serves**: P3; Cafe calm; Accessibility; Localization (`en`, `zh-Hant`, `ja`); [experience.md](../design/experience.md)

## Typography

| ID | Type role | Classification | Weight and case | Size |
|----|-----------|----------------|-----------------|------|
| T1 | Title | Humanist sans | Semibold; sentence case | About 1/18 of frame height |
| T2 | Body / labels | Humanist sans | Regular; sentence case | ≥ 16 screen px at a 640 px reference frame height (smallest shipped size; legible on a phone-width layout — Accessibility); scripts Latin, Traditional Chinese, Japanese |
| T3 | In-play numbers (clocks, Elo, eval) | Humanist sans / tabular | Medium; lining figures | ≥ T2; tabular figures preferred |

Named typefaces are assets ([specs/assets/](../assets/assets.md)).

## Iconography

| ID | Icon class | Grid | Line or fill | Stroke | Corners | Perspective |
|----|------------|------|--------------|--------|---------|-------------|
| I1 | Mode and control | 24×24 art units | Flat fill preferred | 1.5 art units when stroked | Soft round | Flat |

## Panels

| ID | Surface | Border and corners | Fill | In-world or apart |
|----|---------|--------------------|------|-------------------|
| F1 | Panel / button | Thin warm border ([PAL.C5](palette.md) family); soft radius | Flat [PAL.C10](palette.md) | Apart from the board |
| F2 | Tooltip / status chip | Same family as F1, lighter weight | Flat [PAL.C10](palette.md) at higher opacity | Apart |

## Color roles

| ID | Role | Swatch | Contrast rule |
|----|------|--------|---------------|
| C1 | Background / surface | [PAL.C10](palette.md) | — |
| C2 | Text | [PAL.C9](palette.md) | [PAL.K4](palette.md) |
| C3 | Accent / focus | [PAL.C6](palette.md) | Distinct from piece fills ([PAL.K3](palette.md)) |
| C4 | Danger | [PAL.C8](palette.md) | Distinct from piece fills ([PAL.K3](palette.md)) |
| C5 | Disabled | [PAL.C9](palette.md) at ~40% opacity on [PAL.C10](palette.md) | Still legible as inactive |

## Interface motion

| ID | Motion class | Duration (s) | Easing |
|----|--------------|--------------|--------|
| M1 | Screen / panel transition | 0.15–0.25 | Ease-out |
| M2 | Focus / selection change | ≤ 0.15 | Ease-out |
| M3 | Value change (clock, Elo) | ≤ 0.2 | Ease-out; no bounce |
