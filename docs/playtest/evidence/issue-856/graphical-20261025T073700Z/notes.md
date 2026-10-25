# Notes — #856 acceptance run

## Independence

This session wrote neither #856's implementation (PR #872 evidence, PR #877 the change)
nor either verification pass, and did not reuse their number tables: every reading here was
taken fresh, on this host, by `scripts/probe.mjs`, and the drive that produced the
screenshots is `scripts/drive.mjs`, not a script from the earlier folders.

What it does reuse: the `--use-angle=swiftshader` cross-check arm exists only to reproduce
the reading the defect was filed from, so it follows that reading's method (390×844 CSS,
DPR 2, cache off, one profile per run, per-frame canvas readback).

## What was judged

`PTU-mode-pick` **S1** and **`P4`** on `ENV.2` Graphical — "cold open … time `EX.loading`
start to mode pick interactive …, then repeat on a warm open", "clears within 3 s on both the
cold and warm open". `quality.md` Load time / latency is the row: *Board playable within 3
seconds of opening the game*, method *timed cold open to `EX.loading` clearing
(`SIT.4`, `PTU-mode-pick` S1)*.

Three things are read on each open:

- **`EX.loading` shows and its controls are unreachable.** `screenshots/*-s1-loading-600ms.png`
  is the engine's own loading bar with no mode control on screen; `drive.mjs` taps the
  mode-pick band at 300 ms during that state and the page is still on mode pick at the panel
  stamp.
- **Mode pick is painted.** First animation frame whose readback of the control band
  (CSS 95–295 × 147–222 at DPR 2) holds the panel's ink, plus `PerformancePaintTiming`
  first-contentful-paint for the browser-side stamp. The two agree to within a few ms on
  the published and base arms.
- **Mode pick is interactive, not merely drawn.** The drive taps the Shared game control at
  the panel stamp and the build routes to Shared game setup (`s2-shared-game`); a warm drive
  taps Puzzle stream and the build routes to the puzzle board (`s3-puzzle-stream`).

## The reading, and the one that differs

On the hardware-accelerated renderer — the path a player's browser uses — the shipped
release opens mode pick at **1.81–2.04 s cold (4/4)** and 1.25 s warm, and the build carrying
#877 opens it at **0.84–1.05 s cold (4/4)** and 0.65 s warm. The bar holds on every run.

Under `--use-angle=swiftshader` the same builds take 3.9–9.7 s (published) and 5.2–5.6 s
(fix export). That is the arm the defect was filed from, and it is reproduced here — but its
first WebGL2 context alone costs 0.25–5.5 s, i.e. more than the whole hardware cold open,
and the host load during those runs (17–24, against 5–11 for the hardware runs) makes the
published and fix arms non-comparable against each other. A software rasteriser is not the
environment a player opens the game in, `SIT.4` samples timing "on Graphical, where a browser
renders", and nothing in the playtest method names a software rasteriser; so this run judges
`P4` on `ENV.2` and records `ENV.3` as a cross-check.

**What this run does not settle:** whether the project also wants the bar held on software
rasterisation. That question is #402's Load time row and #403's ADR-0001 / ADR-0003 rows,
both `status:pending-verification`, and it is theirs to decide; this folder neither adopts
nor contradicts their `fail` verdicts, it records what the same builds do on the other
renderer. If software rasterisation is to govern, the remaining lever is the ~6.3 MB of
packed ambient beds (ADR-0014), not `game/`.

## The fix's own effect, measured on equal transfers

Published (with the Pages transfer) and the two localhost exports are not directly
comparable, so the fix is read as base-export ↔ fix-export — same commit's bytes, same
localhost server, same host, minutes apart:

| Arm (`69a03d4` code) | cold mode pick | warm |
|---|---|---|
| base (no #877) | 1442 / 1225 / 1257 / 1222 ms | 901 ms |
| fix (`79d5780`, #877) | 844 / 883 / 1032 / 1053 ms | 653 ms |

0.17–0.60 s earlier on every pair, with the two arms differing only in
`_start_music_after_paint`. The direction matches #877's own A/B (1.83/1.81/2.06 → 1.32/1.33/1.58)
and the verification pass's decode of it.

The published page still serves `69a03d4`, because `Web release` has not republished since
#877 merged; the next release run publishes the ordering that measures 0.2–0.6 s earlier.

## Screenshots

`pub-*` and `fix-*` are the same five states from each build: loading at 600 ms, mode pick,
warm mode pick, Shared game setup after the mode tap, and the puzzle board after the warm
mode tap. Both builds are the same scene; the pages differ only by #877 and by how they are
served.

## Not judged

- `PTU-mode-pick` S2–S6 and every other UX and Design protocol: out of this defect's
  deliverable. S2–S5 stay with the #400 sweep; S6 with #546.
- `SIT.6` legibility at phone width beyond the 390×844 frame the run already uses.
- The rest of the cold open (shell WebGL2 capability probe, wasm/pck download): measured by
  the earlier #856 folders, not re-derived here.
