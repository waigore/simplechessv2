# Palette Swatches and Sets

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../../.agents/specs/rules/aesthetics/palette.md).

Part of [`palette.md`](../palette.md).

## Swatches

| ID | Name | Hex | Role | Used for |
|----|------|-----|------|----------|
| C1 | Light square | `#E8D5B5` | ground | Light squares ([E-pieces.I35](../../design/entities/pieces/common.md)) |
| C2 | Dark square | `#8B5A3C` | ground | Dark squares (mahogany) |
| C3 | Ivory piece | `#F5F0E6` | player accent | White pieces |
| C4 | Charcoal piece | `#2C2A28` | player accent | Black pieces |
| C5 | Table wood | `#5C3A2A` | ground | Cafe backdrop ([SPC.L1](../../view/spatial-model.md)) |
| C6 | Select gold | `#B8940C` | accent | Selection highlight ([PER.R3](../../view/perception.md)) |
| C7 | Advice teal | `#53A2BE` | accent | Advice marks ([PER.R5](../../view/perception.md)); reserved — not piece fill; advice-ready feedback ([feedback.md](../../design/experience/feedback.md)) |
| C8 | Check rose | `#C28A86` | hazard | Check and refused-place cues ([PER.R6](../../view/perception.md), [PER.R8](../../view/perception.md)) |
| C9 | Ink | `#2C2A28` | outline / text | UI text and labels; board coordinates on the [SPC.L1](../../view/spatial-model.md) margin |
| C10 | Cream panel | `#F7F1E8` | sky / surface | UI panels and soft fills |
| C11 | Legal sage | `#6EA746` | accent | Legal-destination marks ([PER.R4](../../view/perception.md)) |

## Palette sets

| ID | Context | Swatches | Color limit |
|----|---------|----------|-------------|
| S1 | Board and table ([SPC.L1](../../view/spatial-model.md), [SPC.L2](../../view/spatial-model.md), [PER.R2](../../view/perception.md)) | C1, C2, C3, C4, C5 | 5 |
| S2 | Overlays ([SPC.L4](../../view/spatial-model.md), [PER.R3](../../view/perception.md)–[PER.R8](../../view/perception.md)) | C6, C7, C8, C11 | 4 |
| S3 | Interface ([`UIS.C1`](../ui-style.md)–[`UIS.C5`](../ui-style.md)) | C9, C10, C6 | 3 |
