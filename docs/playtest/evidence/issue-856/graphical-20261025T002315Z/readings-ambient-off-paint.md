# Readings — Ambient load moved off the mode-pick frame (#856)

Issue: the release build's first painted screen arrives after the **≤ 3 s** Load time bar
([`quality.md`](../../../../../specs/definition/quality.md)). The run at
[`../graphical-20261024T224751Z/`](../graphical-20261024T224751Z/readings-cold-open-layers.md) put
the seconds in layers and named the game-code share as *"Ambient preload + first bed cue | the
mode-pick frame | 0.25–0.4 s"*. This run measures that layer when it moves off the mode-pick frame.

## Instrument

Page `performance.now()` throughout, as in the parent record: the per-frame `gl.readPixels` paint
probe, Resource Timing, and the app's console lines (the harness shims `console.log` at document
start to prefix `NNNms`). Two arms, both local `Web Release` exports
(`.github/scripts/web_export.py`, Godot 4.7.2) served by `python3 -m http.server`: base =
`origin/main` `ceb2919`, after = branch `defect/856-cold-open-ambient-after-paint`. Both carry the
same two `print()` calls and no timing logic
([`logs/measurement-print.patch`](logs/measurement-print.patch)), so the arms differ only in the
`start_music()` ordering.

Runners, both in [`../scripts/`](../scripts/): `cold_open_aligned.mjs` (hardware GL, `runs` in one
browser) resolves the layer; `cold_open_layers.mjs` (the #403 runner, `--use-angle=swiftshader`,
one browser per run) is the instrument the defect was filed on. Host: 10 cores, load 44–67 for the
series (ten parallel agent worktrees), so only arms taken back to back are compared.

## Headline

**First painted screen, base vs branch, back to back: 1827 / 1811 / 2058 ms → 1324 / 1329 /
1576 ms — 0.42 s earlier, every after run below every base run.** The moved work is the Ambient
group plus the first bed cue: `ambient − mode-pick` in the base arm is **472–513 ms** across six
runs, matching the 0.25–0.4 s the parent record attributed to this layer. The earlier pair here
reads the same way (base mean 1849 ms → after mean 1400 ms).

**One frame of deferral is not enough**: the paint still landed after the ambient stamp, because a
single-threaded Web build still has the suspended work inside the mode-pick frame's present window.
Two frames pass — one draws mode pick, the next presents it — and the paint precedes the ambient
stamp in every run.

## What this does and does not move

- **Does**: the painted mode pick carries ~0.4 s less work in front of it on every cold open.
- **Does not**: the rest of the cold open. The parent record's layers are untouched — the shell's WebGL2
  capability probe (0.04–3.6 s), `index.wasm` (39,514,754 bytes, 10.2 MB gzip on Pages) and
  `index.pck` (9,573,496 bytes here, 9,568,028 on Pages). ~6.3 MB of that pack is still the two
  ambient beds, which `AST.G3` keeps off the cold open: they now load *after* the paint, not
  outside the pack. Serving them loose is an `ADR-0014` decision, not a defect fix, and this run
  did not attempt it. Which instrument governs the row is still open; see [`notes.md`](notes.md).

Tables: [`arms.md`](arms.md), [`arms-swiftshader.md`](arms-swiftshader.md).
