# Touch mapping — why #845 does not reproduce

#402's `Load time` fails partly on **#845** (*board taps hit one rank above the finger*). This
record contradicts its premise:

- #845 taps CSS `(219, 654)`. Rank 1 spans ≈ y 651–690, so **654 is inside e1** — the tap selected
  the square it landed on. #402's own `board-01-tap-visible-e2-selects-e1.png` rings the **e1
  king**, centre ≈ 670, matching this map and not "654 is e2".
- The sweep selecting only at y 620–680 is what a **correct** map gives at the start position:
  only ranks 1–2 carry pieces, so taps on empty e4/e5 select nothing.
- The `e2`→`e4` tap at 632→554 **landed**.

The cold-open verdict is unaffected (it fails on time either way). **#845 should be rechecked
against this map before it gates touch play.**
