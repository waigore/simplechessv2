# Notes — #879 method, cause and limits

## What was run

All four deliverables the review set ran on the deployed sha `69a03d4`
([manifest.md](manifest.md)):

1. ≥6 presses per button on the deployed sha, hit point and hold per arm → 6 + 6, **12/12**.
2. The same grid on a fresh `Web Release` export of that sha, same machine / browser /
   coordinates → **12/12**.
3. A plain mouse arm with no touch emulation, plus whether the gesture reaches the engine →
   **6/6**; the seam arm shows the engine received it and refused it (below).
4. Pack comparison → done, and it closes the question.

## Cause: the presses were in the seam between the two controls

The frame paints C1 at y **144.83–181.67** and C2 at y **185.83–223.00**
([readings.md](readings.md)); the issue's body reads the boxes as y 150–190 and 197–237. Under the
real boxes, every press the issue records as lost is **outside both controls**:

| Recorded failure | Where it really landed |
|---|---|
| (150,185), 2 presses, published — the 0/8 core | seam, 3.2 px below C1 and 0.8 px above C2 |
| (150,185), (195,185), (240,185) — export hold arms | seam |
| (60,185), (330,185) — export hold arms | outside the panel's x 87.3–302.3 |
| (195,170) — export hold arm | **inside C1**, the one arm this geometry predicts would advance |

Both readings are consistent with presses missing both controls, not with lost activation. The
export's second pass is not explained exactly — only one of its six points lies in a control here,
and which two advanced was not logged — so the export leg was re-run rather than argued from it.

The **audio gate** in that published session is not evidence of a lost activation: autoplay resume
follows any gesture, seam press included. The seam arm and the advancing arm after it recorded the
same `pointerdown`/`touchstart` pair.

## Why this is not #846 or #845

#846 is a hidden control **still emitting** `control_activated`; here a visible control emits
`pressed`. #845 is a wrong-target board mapping; mode pick has none, and every in-button press hit
the intended control.

## Pack comparison

The published `index.pck` and a fresh export of `69a03d4` are both 9 572 540 B and carry the **same
158 routes with the same sizes**; `index.html` and `index.wasm` are byte-identical. The packs
differ only from byte 9 294 153 — the trailing directory — so the file data matches and the
published tree is reproduced locally. `logs/pack-comparison.json`, `logs/*-pck-routes.txt`.

## Not done, and limits

- **No real phone.** Every reading is headless Chrome with CDP dispatch; a phone-specific delivery
  fault cannot be ruled out, though the seam explains every reading on record without one.
- **The seam is design, not a hit-test bug.** The 4.16 px gap is `VBoxContainer` separation;
  `specs/ux/controls.md` F1 makes activation follow the control under the pointer.
- Painted control height here is 36.8 CSS px — separate, **not judged**.
