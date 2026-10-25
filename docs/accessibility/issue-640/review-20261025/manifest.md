# Manifest — #640 accessibility review of rendered surfaces

**Path:** `docs/accessibility/issue-640/review-20261025/manifest.md`

No playtest protocol is in scope: this is an accessibility review of rendered surfaces,
judged by perception and palette review, never a `PTU-*` run.

- **Issue** — `640`.
- **Review run** — `accessibility review of rendered surfaces; no playtest protocol in scope`. The `Environment` and `Coverage mode` values below are borrowings, not gate values.
- **Environment** — `graphical` (`ENV.2`). Headless Chrome 144 (`--headless=new`, SwiftShader WebGL 2.0) at the shipped phone frame 390 × 844 CSS px, DPR 2, touch emulation.
- **Build / session id** — `main` `69a03d4`, read from the **published release URL** `https://waigore.github.io/simplechessv2/`, attributed to `Web release` run [40146630737](https://github.com/waigore/simplechessv2/actions/runs/40146630737). Served `index.pck` `200` at 9 572 540 B (asset-carrying), `game_assets/piece-sprites/k-white.png` `200`. **Board-rendered validation: passed** — board drawn, both squares in the spec hexes, thirty-two pieces in the shipped tones, 78-px square edge from its own paint, console free of preload/asset errors ([`logs/source-validation.md`](logs/source-validation.md)). No export fallback. **`no TEL.3 — release export emits no telemetry (#729)`**.
- **Coverage mode** — `critical-only`, scoped to the two claims.
- **Timing (`SIT.4` runs)** — `n/a, no SIT.4 timing in this run`.
- **Results** — one row per claim:

  | Claim | Element | Verdict |
  |---|---|---|
  | Piece type readable from shape alone | `PER.R1` (first two clauses) | **`pass`** — six of six named; King 102 px = 1/20.94 of a 9:16 frame |
  | Squares differ by lightness | `PAL.K1` | **`pass`** — protanopia Δ 0.5465, deuteranopia 0.5521, control 0.5495 (bar 0.25) |
  | Piece side not told by colour alone | `PAL.K2` (piece side) | **`fail`** — white `C4` contour on C1 1.28:1 / 1.25:1; black `C3` contour on C2 2.83:1 / 3.19:1 |

- **Paths** — [`notes.md`](notes.md), [`per-r1.md`](per-r1.md), [`pal-k1.md`](pal-k1.md), [`pal-k2.md`](pal-k2.md) and [`boundaries.md`](boundaries.md); `screenshots/` holds `silhouette-sheet.png`, `silhouette-naming.md`, `lightness-protanopia.png`, `lightness-deuteranopia.png`, `piece-contrast-protanopia.png`, `piece-contrast-deuteranopia.png`, the extra control captures `board-control.png` / `board-control-b.png` and the route captures `board-01…03`, plus `sheet.json` and `silhouette-sheet-labels.json`; `readings.json` and `capture.json` hold every measurement; `logs/` holds the transcript, key, render log, source validation and console log; the reproducer is `run.mjs`, `read.mjs`, `piece.mjs`, `render.mjs`, `label.mjs`, `measure.mjs`, `cdp.mjs`, `png.mjs`.
- **Defects** — `Defects: #883 and #885 filed on the two claims (the K2 carrier failure and the K2 figure's swapped side labels)`. **#883** — `PAL.K2` carrier failure (white contour on C1, black contour on C2) with drawn tones, crop paths and both simulations. **#885** — the `palette.html` figure's swapped side labels. No failing `PER.R1` row, no swatch mismatch, no unownable claim, nothing for overlay accents.
- **Not judged** — `Not judged — overlay accents (selection, refused place, legal destination, check): judged by #641 against PAL.K9; the mark-form/placement rule is owed by #649 (origin #192).`
- **Location** — no playtest folder is required ([`playtest.md`](../../../../specs/playtest/playtest.md) Gate; [`evidence.md`](../../../../specs/playtest/evidence.md) line 9); the separate root keeps an unenumerated `review-` prefix out of the governed playtest root. That exclusion is **this leaf's choice, not a gate rule**.
