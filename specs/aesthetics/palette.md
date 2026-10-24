# Palette

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../.agents/specs/rules/aesthetics/palette.md).

- **Reference sheet**: [`sheets/palette.html`](sheets/palette.html)
- **Serves**: P2, P3; Clear board; Accessibility; [PER.R1](../view/perception.md)–[PER.R8](../view/perception.md)

## Color rules

| ID | Rule | Applies to | Test | Serves |
|----|------|------------|------|--------|
| K1 | Squares differ by lightness, not hue alone | C1 vs C2 | Luminance Δ ≥ 0.25 | Accessibility; [PER.R2](../view/perception.md) |
| K2 | Piece side is not told by square color alone; tested unit is the piece silhouette (fill plus [SRF.O1](surface.md) outline) | C3, C4 on C1 and C2 | White: fill on C2 5.10:1, outline (C4) on C1 9.95:1; Black: fill on C1 9.95:1, outline (C3) on C2 5.10:1; each ≥ 3:1 both squares | Clear board; Accessibility |
| K3 | Overlay accents are not piece fills | C6, C7, C8, C11 vs C3, C4 | No overlay hex equals a piece fill | [PER.R1](../view/perception.md), [PER.R5](../view/perception.md) |
| K4 | Body text on panels | C9 on C10 | Contrast ratio ≥ 4.5:1 | Accessibility; Localization labels |
| K5 | Overlay marks read on both squares | C6, C7, C8 on C1 and C2 | Contrast ≥ 2:1 on each (measured 2.0:1) | [PER.R3](../view/perception.md)–[PER.R6](../view/perception.md), [PER.R8](../view/perception.md) |
| K6 | Legal-destination marks read on both squares | C11 on C1 and C2 | Contrast ≥ 2:1 on each (measured 2.0:1) | [PER.R4](../view/perception.md) |
| K7 | Disabled ink reads inactive yet distinct | C9 at 40% on C10 | Contrast ≥ 2:1 (2.3:1) | [`UIS.C5`](ui-style.md); Accessibility |
| K8 | Board coordinates read on the cafe margin | Coordinate ink on C5 | Contrast ≥ 4.5:1 ([PER.R7](../view/perception.md)); stated pair about 1.4:1; which swatch changes is TBD — which swatch changes? | Accessibility; [PER.R7](../view/perception.md) |
| K9 | Overlay accents are not told apart by hue alone | C6, C7, C8, C11 on C1 and C2 | No mark alone carries its meaning: selection and refused place also change piece or square state, and check has its own indicator and end cue; how they stay distinct without hue is TBD — what mark form and placement tell them apart? | Accessibility; [experience.md](../design/experience.md) Channels |

## Swatches and palette sets

`C1`–`C11` are in [`palette/swatches.md`](palette/swatches.md); `S1`–`S3`, each with its context and color limit, in [`palette/sets.md`](palette/sets.md).
