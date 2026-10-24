# Palette color rules K8–K9

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../../.agents/specs/rules/aesthetics/palette.md).

Rules `K8`–`K9` of [`palette.md`](../palette.md), split out to keep it under 500 words; `K1`–`K7` stay there. Swatches: [`swatches.md`](swatches.md).

## K8 — coordinates read on the cafe margin

| Field | Value |
|-------|-------|
| Applies to | [PAL.C9](swatches.md) ink on the [PAL.C10](swatches.md) chip, over [PAL.C5](swatches.md) wood |
| Test | Contrast ≥ 4.5:1 ([PER.R7](../../view/perception.md)); **C9 on C10 12.73:1** |
| Chip on the wood | C10 on C5 **8.93:1**, so the chip reads on the margin |
| Not tested | Bare C9 on C5 **1.43:1** |

The tested pair is the ink on its chip, not the bare wood: the chip is the letter's background, so no swatch changes. Ratios are WCAG relative-luminance ratios of the two sRGB hex values as drawn ([method](../surface.md)).

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

**Hue removed.** Six stroke forms: closed ring, solid disk, four corner pairs, parallel fill, corner L, edge-midpoint brackets. Selection is the only closed ring; capture differs from it in **form**, not radius.

**Layer split.** Selection draws on the square; the other five on a full-opacity C10 foreground keylined in C9 at 1.5 screen px ([`UIS.I1`](../ui-style.md)). The keyline separates, not fill or hue: accents measure 2.01:1 on C1 and C2 and C8 on C10 2.57:1, while C9 on C10 is **12.73:1** and C9 on C3 **12.59:1**. An empty square is always C1 or C2 inside [SPC.B1](../../view/spatial-model.md), so an ivory square refuses as hatching on a keylined cream foreground.

**Stroke floor.** The forms hold by construction, not by a pixel floor. Strokes keep [`UIS.I1`](../ui-style.md)'s **1.5 screen px** minimum; at 360 × 640 (360 px over 10 units, [PRJ.P1](../../view/projection.md)) 1 unit = 36 px, so the `0.06` ring is **2.16 px** and the `0.10` bracket **3.6 px**.

**Per-rule.** `PER.R3`: the ring never covers the body, so ≥ 90% stays visible. `PER.R4`: disk πr² ≥ 1/4 square (r ≥ 0.282); brackets 2 × 8 × w × l ≥ 1/4 square. `PER.R5`: brackets stay in the [SPC.E1](../../view/spatial-model.md) box, ≤ 10% of the body. `PER.R8`: hatching rides the C8 flash; selection and legal marks return after 0.3 s.
