# Palette color rules K8–K9

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../../.agents/specs/rules/aesthetics/palette.md).

Rules `K8`–`K9` of [`palette.md`](../palette.md); `K1`–`K7` stay there. Swatches: [`swatches.md`](swatches.md). `K9`'s mark table, per-rule notes, and stroke floor: [`rules-k9.md`](rules-k9.md).

## K8 — coordinates read on the cafe margin

| Field | Value |
|-------|-------|
| Applies to | [PAL.C9](swatches.md) ink on the [PAL.C10](swatches.md) chip, over [PAL.C5](swatches.md) wood |
| Test | Contrast ≥ 4.5:1 ([PER.R7](../../view/perception.md)); **C9 on C10 12.73:1** |
| Chip on the wood | C10 on C5 **8.93:1**, so the chip reads |
| Not tested | Bare C9 on C5 **1.43:1** |

The tested pair is the ink on its chip, not the bare wood: no swatch changes. Ratios are WCAG relative-luminance ratios of the two sRGB hex values as drawn ([method](../surface.md)).

## K9 — overlays without hue

Marks differ by **form**, then placement — never by hue. Selection is the only closed ring; capture differs in **form**, not radius. The table is in [`rules-k9.md`](rules-k9.md).

**Hue removed.** Eight mark forms: closed ring, solid disk, four corner pairs, parallel fill, corner L, edge-midpoint brackets, soft band, and the cream ticks. The band and the ticks are the two not built from an accent swatch.

**Layer split.** Selection's ring, the last-move band, and refusal's hatching draw on the square: the ring and band are fields it carries, and hatching is [C8](swatches.md) over the square's own fill. Check's L-frame, Advice's brackets, and the last-move ticks draw on a full-opacity C10 foreground keylined in C9 at 1.5 screen px ([`UIS.C6`](../ui-style.md)). The keyline separates, not fill or hue: accents measure 2.01:1 on C1 and C2, the cream tick 1.28:1 on C1, while C9 on C10 is **12.73:1**.

**One layer.** A square draws one C10 foreground: check, Advice, or the ticks, never two cream strokes at once. Refusal needs none — hatching is a fill. No swatch added; C10 and C9 are in [S2](sets.md). Per-rule bounds are in [`rules-k9.md`](rules-k9.md).
