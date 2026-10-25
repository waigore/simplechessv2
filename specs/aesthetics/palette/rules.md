# Palette color rules K8–K9

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../../.agents/specs/rules/aesthetics/palette.md).

Rules `K8`–`K9` of [`palette.md`](../palette.md); `K1`–`K7` stay there. Swatches: [`swatches.md`](swatches.md). `K9`'s per-form detail and stroke floor: [`rules-k9.md`](rules-k9.md).

## K8 — coordinates read on the cafe margin

| Field | Value |
|-------|-------|
| Applies to | [PAL.C9](swatches.md) ink on the [PAL.C10](swatches.md) chip, over [PAL.C5](swatches.md) wood |
| Test | Contrast ≥ 4.5:1 ([PER.R7](../../view/perception.md)); **C9 on C10 12.73:1** |
| Chip on the wood | C10 on C5 **8.93:1**, so the chip reads |
| Not tested | Bare C9 on C5 **1.43:1** |

The tested pair is the ink on its chip, not the bare wood: no swatch changes. Ratios are WCAG relative-luminance ratios of the two sRGB hex values as drawn ([method](../surface.md)).

## K9 — overlays without hue

Marks differ by **form and placement**, never by hue, radius, or stroke width.

| State | Accent | Form | Placement | Kept |
|-------|--------|------|-----------|------|
| Selection ([PER.R3](../../view/perception.md)) | [C6](swatches.md) | Ring | Square's outer edge, filling the `PER.R3` frame | Highlight ≥ 2:1; piece held |
| Empty destination ([PER.R4](../../view/perception.md)) | [C11](swatches.md) | Disk | Square centre | None; mark carries itself |
| Capture destination ([PER.R4](../../view/perception.md)) | [C11](swatches.md) | Corner brackets | Two strokes per corner, inside the square | None |
| Refused place ([PER.R8](../../view/perception.md)) | [C8](swatches.md) | Hatching | Square fill, inside the selection ring | 0.3 s C8 flash; [PHY.M5](../../view/physics.md) return |
| Check ([PER.R6](../../view/perception.md)) | [C8](swatches.md) | L-frame | Opposite corners, off diagonals | Check word ([`UI-shared-play.R2`](../../ux/screens/shared-play.md)), [X4](../sound.md) |
| Advice ([PER.R5](../../view/perception.md)) | [C7](swatches.md) | Edge brackets | One stroke per edge midpoint, corners open | Advice chrome, eval text |
| Last move — from ([PER.R9](../../view/perception.md)) | [C10](swatches.md) | Back tick | One stroke inset on the edge facing the to-square | Both squares of the move |
| Last move — to ([PER.R9](../../view/perception.md)) | [C10](swatches.md) | Corner ticks | An L in each corner facing the from-square | The moved piece |

Last move is one state on two squares — a back tick on from, two corner ticks on to — so the pair reads as a move without hue.

**Hue removed.** Seven mark forms — closed ring, solid disk, four corner pairs, parallel fill, corner L, edge-midpoint brackets, C10 ticks — all but the ticks built from an accent swatch. Selection is the only closed ring; capture differs in **form**, not radius.

**Layer split.** Selection draws on the square; the other six on a full-opacity C10 foreground keylined in C9 at 1.5 screen px ([`UIS.C6`](../ui-style.md)). The keyline separates: accents are 2.01:1 on C1 and C2, C8 on C10 2.57:1, C9 on C10 **12.73:1**.

**One layer.** A square never draws two cream layers: refused, check, last-move, and Advice marks share one C10 foreground. No swatch added; C10 and C9 are in [S2](sets.md).

**Board cases.** An empty square is always C1 or C2 inside [SPC.B1](../../view/spatial-model.md), so cream-on-cream refusal and last-move ticks are separated by the C9 keyline alone.
