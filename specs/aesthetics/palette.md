# Palette

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../.agents/specs/rules/aesthetics/palette.md).

- **Sheet**: [`sheets/palette.html`](sheets/palette.html)
- **Serves**: P2, P3; Clear board; Accessibility; [PER.R1](../view/perception.md)–[PER.R7](../view/perception.md); [experience.md](../design/experience.md) clarity

## Swatches

| ID | Name | Hex | Role | Used for |
|----|------|-----|------|----------|
| C1 | Light square | `#E8D5B5` | ground | Light squares ([E-pieces.I35](../design/entities/pieces/common.md)) |
| C2 | Dark square | `#8B5A3C` | ground | Dark squares (mahogany) |
| C3 | Ivory piece | `#F5F0E6` | player accent | White pieces |
| C4 | Charcoal piece | `#2C2A28` | player accent | Black pieces |
| C5 | Table wood | `#5C3A2A` | ground | Cafe / table backdrop ([SPC.L1](../view/spatial-model.md)) |
| C6 | Select gold | `#B8940C` | accent | Selection highlight ([PER.R3](../view/perception.md)) |
| C7 | Advice teal | `#53A2BE` | accent | Advice marks ([PER.R5](../view/perception.md)); reserved — not piece fill |
| C8 | Check rose | `#C28A86` | hazard | Check / danger cues ([PER.R6](../view/perception.md)) |
| C9 | Ink | `#2C2A28` | outline / text | UI text and labels |
| C10 | Cream panel | `#F7F1E8` | sky / surface | UI panels and soft fills |
| C11 | Legal sage | `#6EA746` | accent | Legal-destination marks ([PER.R4](../view/perception.md)) |

## Palette sets

| ID | Context | Swatches | Color limit |
|----|---------|----------|-------------|
| S1 | Board and table | C1, C2, C3, C4, C5 | 5 |
| S2 | Overlays | C6, C7, C8, C11 | 4 |
| S3 | Interface | C9, C10, C6 | 3 |

## Color rules

| ID | Rule | Applies to | Test | Serves |
|----|------|------------|------|--------|
| K1 | Light and dark squares differ by lightness, not hue alone | C1 vs C2 | Relative luminance difference ≥ 0.25; still distinct under protanopia / deuteranopia simulation | Accessibility; [PER.R2](../view/perception.md) |
| K2 | Piece side is not told by square color alone; tested unit is the piece silhouette (fill plus the [SRF.O1](surface.md) outline) | C3, C4 on C1 and C2 | Each side reads ≥ 3:1 on both squares via fill or outline: ivory fill on C2 5.1:1, its near-C4 outline on C1 9.9:1; charcoal fill on C1 9.9:1, its near-C3 light edge on C2 5.1:1; types shape-led ([experience.md](../design/experience.md) channels) | Clear board; Accessibility |
| K3 | Overlay accents are not piece fills | C6, C7, C8, C11 vs C3, C4 | No overlay hex equals a piece fill; Advice teal unused as piece color | [PER.R1](../view/perception.md), [PER.R5](../view/perception.md) |
| K4 | Body text on panels | C9 on C10 | Contrast ratio ≥ 4.5:1 | Accessibility; Localization labels |
| K5 | Overlay marks read on both squares | C6, C7, C8 on C1 and C2 | Contrast ≥ 2:1 on each (measured 2.0:1) | [PER.R3](../view/perception.md), [PER.R5](../view/perception.md), [PER.R6](../view/perception.md) |
| K6 | Legal-destination marks read on both squares | C11 on C1 and C2 | Contrast ≥ 2:1 on each (measured 2.0:1) | [PER.R4](../view/perception.md) |
