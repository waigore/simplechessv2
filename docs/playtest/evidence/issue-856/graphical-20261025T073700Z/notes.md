# Notes — #856 acceptance run

What was judged: `PTU-mode-pick` **S1** and **`P4`** on `ENV.2` Graphical — "cold open …
time `EX.loading` start to mode pick interactive …, then repeat on a warm open", "clears
within 3 s on both the cold and warm open". `quality.md` Load time / latency is the row:
*Board playable within 3 seconds of opening the game*, method *timed cold open to
`EX.loading` clearing (`SIT.4`, `PTU-mode-pick` S1)*.

Painted is not enough, so each open is read three ways:

- **`EX.loading` shows and its controls are unreachable.** `screenshots/*-s1-loading-600ms.png`
  is the engine's own loading bar with no mode control on screen; `drive.mjs` taps the
  mode-pick band at 300 ms during that state and the page is still on mode pick at the panel
  stamp.
- **Mode pick is painted.** First animation frame whose readback of the control band
  (CSS 95–295 × 147–222 at DPR 2) holds the panel's ink, plus `PerformancePaintTiming`
  first-contentful-paint for the browser-side stamp.
- **Mode pick is interactive, not merely drawn.** The drive taps Shared game at the panel
  stamp and the build routes to Shared game setup (`s2-shared-game`); a warm drive taps
  Puzzle stream and the build routes to the puzzle board (`s3-puzzle-stream`).

## Split of this folder

- [`results.md`](results.md) — the protocol verdict, the story row, and the per-run table.
- [`fix-effect.md`](fix-effect.md) — the base-export ↔ fix-export comparison for #877.
- [`renderer.md`](renderer.md) — the software-rasteriser cross-check and what this run does
  not settle. It is a cross-check, not the judging leg.

## Independence

This session wrote neither #856's implementation (PR #872 evidence, PR #877 the change) nor
either verification pass, and did not reuse their number tables: every reading here was
taken fresh, on this host, by `scripts/probe.mjs`, and the drive that produced the
screenshots is `scripts/drive.mjs`, not a script from the earlier folders.

What it does reuse: the `--use-angle=swiftshader` cross-check arm exists only to reproduce
the reading the defect was filed from, so it follows that reading's method (390×844 CSS,
DPR 2, cache off, one profile per run, per-frame canvas readback). See
[`renderer.md`](renderer.md).

## Not judged

- `PTU-mode-pick` S2–S6 and every other UX and Design protocol: out of this defect's
  deliverable. S2–S5 stay with the #400 sweep; S6 with #546.
- `SIT.6` legibility at phone width beyond the 390×844 frame the run already uses.
- The rest of the cold open (shell WebGL2 capability probe, wasm/pck download): measured by
  the earlier #856 folders, not re-derived here.
