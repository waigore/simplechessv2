# Manifest — #879 mode-pick press re-measurement

- **Issue**: #879 (`type:defect`, `priority:high`). **Builds**: the **published** release
  `69a03d4` — GitHub Pages deployment `created` `2026-10-25T00:26:00Z`, sha
  `69a03d48edf6304e265cf2078112c42e4d022afd` — served at
  `https://waigore.github.io/simplechessv2/` (`index.pck` 9 572 540 B, `last-modified`
  00:26:08 GMT when the run started); and a fresh local **`Web Release`** export of the same
  sha, made with `python3 .github/scripts/web_export.py --preset "Web Release"` on Godot
  4.7.2.stable and served at `http://127.0.0.1:8631/`.
- **Environment**: macOS 27.0.1 / Apple M5; Chrome **156.0.8078.47** headless (`--headless=new`,
  `--use-angle=swiftshader`); 390×844 CSS, DPR 3; CDP touch and mouse dispatch; **no**
  `--autoplay-policy` flag, so the published leg keeps the real autoplay gate.
- **Coverage mode**: not a protocol row — a defect re-measurement at the bar
  `## Additional context` → "What the re-measurement must produce" sets.
- **Repeat count**: **6** arms per button on each touch leg; **3** per button on the mouse leg;
  **1** per boundary and seam point. Every arm is the first press of its own session.

## Results — 30 centre-grid presses and 4 boundary presses inside a painted control, 34 activations

| Leg | Shared game (C1) | Puzzle stream (C2) | Seam / outside panel |
|---|---|---|---|
| Published `69a03d4`, touch | **6/6** | **6/6** | 0/2 outside, 0/2 seam |
| Local `Web Release` of `69a03d4`, touch | **6/6** | **6/6** | 0/1 outside, 0/2 seam |
| Published `69a03d4`, plain mouse, no touch emulation | **3/3** | **3/3** | 0/1 seam |
| Published, boundary sweep | (195,170) 1/1 · (195,180) 1/1 | (195,217) 1/1 · (195,187) 1/1 | (150,185) 0/1 · (195,183) 0/1 |

An advance is a painted frame that differs from the frame taken immediately before that arm's
press, in the same session; the game's own `last_mode` document corroborates every one
(`shared` after C1, `puzzle` after C2). Per-arm hit point, hold, frame digests and the
page-level gesture log: [readings.md](readings.md); the boundary sweep is in
[boundary-and-totals.md](boundary-and-totals.md).

**No late placement pass:** 12 samples over 48 s after the cold open found one identical frame from
sample 1 (19.4 s) onward, so the boxes do not move after the screen is up
(`logs/published-frame-samples.json`).

## Verdict

**Not reproduced.** Every press **inside** either mode-pick control activates it, on both builds
and on the non-CDP path. The presses the issue records as lost sit in the **4.16 px seam between
the two controls** (y 181.67–185.83) or outside the panel — see [notes.md](notes.md). No code
change was made: the engine input path, the panel's `pressed` connection and the router behave as
[`specs/ux/controls.md`](../../../../../specs/ux/controls.md) B1 and F1 say they should, and the
packaged tree is reproducible from the sha.

## Defects

None filed. `#879` is the subject of this run, not a defect filed from it.

## Paths

`scripts/` (driver, arm grid, geometry probe, box reader, pack reader, as run) · `logs/`
(per-leg readings JSON incl. gesture logs, frame samples, pack comparison, console) ·
`screenshots/` (the mode-pick frame on each build, one advanced frame per control, the
unmoved seam frame) · method and limits: [notes.md](notes.md).
