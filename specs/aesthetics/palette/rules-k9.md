# Palette K9 forms: per-rule detail

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../../.agents/specs/rules/aesthetics/palette.md).

Split from [`rules.md`](rules.md) to keep that file under 500 words. The `K9` mark table and layer split are there.

## Per-rule

`PER.R3`: the ring never covers the body, so ≥ 90% stays visible. `PER.R4`: the disk radius is 0.282 square (`πr²` ≥ 1/4 square); each capture corner stroked 0.06 square wide by 0.10 long also clears 1/4 of the square. `PER.R5`: Advice brackets stay in the [SPC.E1](../../view/spatial-model.md) box, ≤ 10% of the body. `PER.R8`: hatching rides the C8 flash; selection and legal marks return after 0.3 s.

`PER.R9`: the ticks sit in the outer 0.10 of a square, measured in square fractions — the from-square's back tick is 0.04 wide by 0.60 long, inset 0.04 on the edge facing the to-square; the to-square carries two corner Ls, each 0.10 wide by 0.20 long along each of its two arms, in the two corners facing the from-square. The busiest square draws 0.06 of its area (two Ls; the back tick draws 0.024), so each sits inside the ≤ 10% bound with room to spare, and no tick crosses another form's stroke path where they share a square: the corner Ls read by their corner placement, which no other form uses, and the back tick is an edge segment no other form draws. They follow the move, not the board, so they point the same way after [CAM-board.M2](../../view/cameras/board.md) flips it, and they never need the piece body cleared — the ticks sit around it, not through it, so the moved piece keeps its full [SPC.E1](../../view/spatial-model.md) silhouette. The reading is the keyline, not the cream: C9 on C1 is **9.95:1** and on C2 **2.47:1**, while the C10 tick itself is **1.28:1** on C1.

## Stroke floor

The forms hold by construction, not by a pixel floor. Strokes keep [`UIS.I1`](../ui-style.md)'s **1.5 screen px** minimum; at 360 × 640 (360 px over 10 units, [PRJ.P1](../../view/projection.md)) 1 unit = 36 px and one square is 36 px, so the `0.06` ring is **2.16 px**, the `0.10` bracket **3.6 px**, and the `0.04` tick **1.44 px** — under the floor, so the C9 keyline around it, not the cream stroke, carries it.

## Look

The tick pairs are drawn on both square colors in [`../sheets/palette.html`](../sheets/palette.html), under its `PAL.K9` last-move section.
