# Palette K9 forms: per-rule detail

Authoring rules: [`.agents/specs/rules/aesthetics/palette.md`](../../../.agents/specs/rules/aesthetics/palette.md).

Split from [`rules.md`](rules.md) to keep that file under 500 words. The `K9` mark table and layer split are there.

## Per-rule

`PER.R3`: the ring never covers the body, so ≥ 90% stays visible. `PER.R4`: disk πr² ≥ 1/4 square (r ≥ 0.282); capture brackets 2 × 8 × w × l ≥ 1/4 square. `PER.R5`: Advice brackets stay in the [SPC.E1](../../view/spatial-model.md) box, ≤ 10% of the body. `PER.R8`: hatching rides the C8 flash; selection and legal marks return after 0.3 s.

`PER.R9`: the ticks sit in the outer 0.10 of a square — a `0.04` back tick and two `0.10` corner Ls — so they cover ≤ 10% of the piece on the to-square and never touch the capture, edge-bracket, or L-frame strokes. They follow the move, not the board, so they point the same way after [CAM-board.M2](../../view/cameras/board.md) flips it, and they never need the piece body cleared.

## Stroke floor

The forms hold by construction, not by a pixel floor. Strokes keep [`UIS.I1`](../ui-style.md)'s **1.5 screen px** minimum; at 360 × 640 (360 px over 10 units, [PRJ.P1](../../view/projection.md)) 1 unit = 36 px, so the `0.06` ring is **2.16 px**, the `0.10` bracket **3.6 px**, and the `0.04` tick **1.44 px** — under the floor, so the C9 keyline around it, not the cream stroke, carries it.

## Look

The tick pairs are drawn on both square colors in [`../sheets/palette.html`](../sheets/palette.html), under its `PAL.K9` last-move section.
