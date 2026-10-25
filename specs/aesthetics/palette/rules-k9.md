# Palette K9 marks

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../../.agents/specs/rules/aesthetics/palette.md).

Split from [`rules.md`](rules.md), which keeps the K9 rule, the hue sentence, and the layer split. Swatches: [`swatches.md`](swatches.md).

## Mark table

Every state carries a row; `kept` says what stays visible next to it.

| State | Accent | Form | Placement | Kept |
|-------|--------|------|-----------|------|
| Selection ([PER.R3](../../view/perception.md)) | [C6](swatches.md) | Closed ring | Square's outer edge, filling that rule's frame | Piece held |
| Empty destination ([PER.R4](../../view/perception.md)) | [C11](swatches.md) | Disk | Square centre | None |
| Capture destination ([PER.R4](../../view/perception.md)) | [C11](swatches.md) | Corner brackets | Two strokes per corner, inside | None |
| Refused place ([PER.R8](../../view/perception.md)) | [C8](swatches.md) | Hatching | Fill, inside the ring | 0.3 s C8 flash, [PHY.M5](../../view/physics.md) return |
| Check ([PER.R6](../../view/perception.md)) | [C8](swatches.md) | L-frame | Two opposite corners | Check word, [X4](../sound.md) |
| Advice ([PER.R5](../../view/perception.md)) | [C7](swatches.md) | Edge brackets | One per edge midpoint, corners open | Advice chrome, eval |
| From-square ([PER.R9](../../view/perception.md)) | [C7](swatches.md) | Soft band | Square edge opposite the ring: blurred, no hard stroke | Ring; piece held |
| To-square ([PER.R9](../../view/perception.md)) | [C10](swatches.md) | Corner ticks | An L in each corner facing the from-square | Moved piece; selection, capture, check |

Last move is one state on two squares: a soft band on the from-square, corner ticks on the to-square. Only the to-square takes a crisp edge, so the pair says which end is which without hue. The band shares the ring's edge but is soft, open, and never encloses.

## Per-rule

Ring ≥ 90% of the body stays visible. Disk πr² ≥ 1/4 square, as do the capture brackets. Advice brackets stay ≤ 10% of the body. Refusal hatching rides the flash.

`PER.R9`: the band is C7, tested by K5 — 2.00:1 on both squares — and soft enough to read as a field, not a stroke. The ticks sit in the outer 0.10 of the to-square — 0.04 wide, 0.60 long on the edge facing the from-square, each L arm 0.10 — so they cover ≤ 10% of the body and cross no other stroke. The piece keeps its full silhouette. They follow the move, not the board, so they point the same way after [CAM-board.M2](../../view/cameras/board.md) flips it.

## Stroke floor

Strokes keep [`UIS.I1`](../ui-style.md)'s **1.5 screen px** minimum. At 360 × 640 (36 px a square, [PRJ.P1](../../view/projection.md)) the `0.06` ring is **2.16 px** and the `0.10` bracket **3.6 px**; the `0.04` tick is **1.44 px**, under the floor, so its C9 keyline carries it.

## Look

Both marks drawn on both square colors in [`../sheets/palette.html`](../sheets/palette.html).
