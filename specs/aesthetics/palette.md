# Palette

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../.agents/specs/rules/aesthetics/palette.md).

- **Reference sheet**: [`sheets/palette.html`](sheets/palette.html)
- **Serves**: P2, P3; Clear board; Accessibility; [PER.R1](../view/perception.md)–[PER.R8](../view/perception.md); [experience.md](../design/experience.md) clarity and Channels

## Swatches and sets

Swatches `C1`–`C11` and palette sets `S1`–`S3` are in [`palette/swatches.md`](palette/swatches.md).

## Color rules

| ID | Rule | Applies to | Test | Serves |
|----|------|------------|------|--------|
| K1 | Squares differ by lightness, not hue alone | C1 vs C2 | Luminance difference ≥ 0.25; distinct under protanopia/deuteranopia simulation | Accessibility; [PER.R2](../view/perception.md) |
| K2 | Piece side is not told by square color alone; tested unit is the piece silhouette (fill plus the [SRF.O1](surface.md) outline) | C3, C4 on C1 and C2 | Each side reads ≥ 3:1 on both squares: ivory fill on C2 5.1:1, outline on C1 9.9:1; charcoal fill on C1 9.9:1, edge on C2 5.1:1; shape-led ([experience.md](../design/experience.md)) | Clear board; Accessibility |
| K3 | Overlay accents are not piece fills | C6, C7, C8, C11 vs C3, C4 | No overlay hex equals a piece fill; Advice teal unused as piece color | [PER.R1](../view/perception.md), [PER.R5](../view/perception.md) |
| K4 | Body text on panels | C9 on C10 | Contrast ratio ≥ 4.5:1 | Accessibility; Localization labels |
| K5 | Overlay marks read on both squares | C6, C7, C8 on C1 and C2 | Contrast ≥ 2:1 on each (measured 2.0:1) | [PER.R3](../view/perception.md), [PER.R5](../view/perception.md), [PER.R6](../view/perception.md), [PER.R8](../view/perception.md) |
| K6 | Legal-destination marks read on both squares | C11 on C1 and C2 | Contrast ≥ 2:1 on each (measured 2.0:1) | [PER.R4](../view/perception.md) |
| K7 | Disabled ink reads inactive yet distinct | C9 at 40% opacity on C10 | Contrast ≥ 2:1 (measured 2.3:1) | [`UIS.C5`](ui-style.md); Accessibility |
| K8 | Board coordinates read on the cafe margin | Coordinate ink on C5 | Contrast ratio ≥ 4.5:1 ([PER.R7](../view/perception.md)); the pair as stated measures about 1.4:1, and which swatch changes is TBD — which swatch changes? | Accessibility; [PER.R7](../view/perception.md) |
| K9 | Overlay accents are told apart without hue | C6, C7, C8, C11 on C1 and C2 | No mark is the only carrier of its meaning: selection and refused place also change piece or square state, and check has its own indicator and end cue ([feedback.md](../design/experience/feedback.md)); they share luminance, so how they stay distinct with hue removed is TBD — what mark form and placement tell them apart? | Accessibility; [experience.md](../design/experience.md) Channels |
