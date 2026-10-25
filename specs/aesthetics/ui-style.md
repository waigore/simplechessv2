# Interface Style

Authoring rules: [`.agents/specs/rules/aesthetics/ui-style.md`](../../.agents/specs/rules/aesthetics/ui-style.md).

- **Serves**: P3; Cafe calm; Accessibility; Localization (`en`, `zh-Hant`, `ja`); [experience.md](../design/experience.md)

## Typography

| ID | Type role | Classification | Weight and case | Size |
|----|-----------|----------------|-----------------|------|
| T1 | Title | Humanist sans | Semibold; sentence case | 1/18 of frame height (≈ 36 screen px at the 640 px reference frame height) |
| T2 | Body / labels | Humanist sans | Regular; sentence case | ≥ 16 screen px at a 640 px reference frame height (smallest shipped size; legible on a phone-width layout — Accessibility) |
| T3 | In-play numbers (clocks, Elo, eval) | Humanist sans / tabular | Medium; lining figures | ≥ T2; tabular figures preferred |

All three roles (T1–T3) must render scripts Latin, Traditional Chinese, and Japanese ([quality.md](../definition/quality.md) Localization).

Named typefaces are assets ([specs/assets/](../assets/assets.md)).

## Iconography

| ID | Icon class | Grid | Line or fill | Stroke | Corners | Perspective |
|----|------------|------|--------------|--------|---------|-------------|
| I1 | Mode and control | 24×24 screen px at the 640 px reference frame height | Flat fill preferred | 1.5 screen px when stroked | Soft round | Flat |

## Panels

| ID | Surface | Border and corners | Fill | In-world or apart |
|----|---------|--------------------|------|-------------------|
| F1 | Panel / button | 1 screen px [PAL.C5](palette.md)-family border at 28% opacity; 8 screen px radius (12 screen px on panels) | Flat [PAL.C10](palette.md) at 100% opacity | Apart from the board |
| F2 | Tooltip / status chip | 1 screen px [PAL.C5](palette.md)-family border at 20% opacity; 8 screen px radius | Flat [PAL.C10](palette.md) at 80% opacity | Apart |

## Color roles

| ID | Role | Swatch | Contrast rule |
|----|------|--------|---------------|
| C1 | Background / surface | [PAL.C10](palette.md) | — |
| C2 | Text | [PAL.C9](palette.md) | [PAL.K4](palette.md) |
| C3 | Accent / focus | [PAL.C6](palette.md) | Distinct from piece fills ([PAL.K3](palette.md)) |
| C4 | Danger | [PAL.C8](palette.md) | Distinct from piece fills ([PAL.K3](palette.md)) |
| C5 | Disabled | [PAL.C9](palette.md) at 40% opacity on [PAL.C10](palette.md) | [PAL.K7](palette.md) |
| C6 | On-board mark surface | [PAL.C10](palette.md) at 100% opacity with a [PAL.C9](palette.md) keyline at 1.5 screen px ([`UIS.I1`](#iconography)) | Keeps every stroke mark distinguishable with hue removed ([PAL.K9](palette/rules.md)): check's L-frame, Advice's brackets, and the last-move corner ticks ([PER.R9](../view/perception.md)). The ring, the soft band, and refusal's hatching draw on the square itself; one cream foreground per square. Tick geometry is in [PAL.K9](palette/rules-k9.md); the layer split is there and in [PAL.S2](palette/sets.md) |

## Interface motion

| ID | Motion class | Duration (s) | Easing |
|----|--------------|--------------|--------|
| M1 | Screen / panel transition | 0.15–0.25 | Ease-out |
| M2 | Focus / selection change | ≤ 0.15 | Ease-out |
| M3 | Value change (clock, Elo) | ≤ 0.2 | Ease-out; no bounce |
