# Readings — cold open phases (#856)

Issue: the release build's cold open to mode pick is **3.0–4.4 s**, over the **≤ 3 s** bar
([`quality.md`](../../../../../specs/definition/quality.md), Load time). This run located the
cost; the fixes it measured are in [`trials.md`](trials.md). It records; it does not judge.

## Clocks

Every stamp is the **page's** `performance.now()`: the shell's WebGL2 capability probe span,
Resource Timing for `index.wasm` / `index.pck`, the engine banner, and the app's console lines
(the harness shims `console.log` at document start to prefix `NNNms`). They agree: banner
0–230 ms after the pack download ends, app boot lines 0.2–0.4 s later, first painted frame
0.1–0.5 s after boot. An earlier draft mixed the harness's `Runtime.consoleAPICalled` clock
(epoch-based) with page stamps and mis-read the same runs by ~1.2 s; it is discarded.

**Trap:** `--use-angle=swiftshader` (the #403 flag) makes the browser's fetch of a
`rel=preload` resource **invisible** to Resource Timing. Read preloads with
[`../scripts/cdp_aligned.mjs`](../scripts/cdp_aligned.mjs) (the #403 driver minus that flag).

## Environment

Headless Chrome, 390×844 CSS / DPR 2, touch emulation, cache disabled. Host: 10 cores, load
25–28 (ten parallel agent worktrees); absolute times run long and only arms minutes apart are
compared.

## Phases

| Phase | Where it comes from | Cost seen here |
|---|---|---|
| Navigation + shell script | `index.html`, `index.js` (70 KB gzip) | 100–400 ms |
| **Capability probe** | `Engine.getMissingFeatures()` → creates a WebGL2 context | **0.04–3.6 s** (warm 0.04–0.1 s; 1–3.6 s while the GPU process initialises) |
| **Engine download** | `index.wasm` 39.5 MB (10.2 MB gzip); `index.pck` 9.57 MB (9.37 MB gzip) | 0.7–1.7 s |
| **App boot** | Boot group, persist, mode pick shown | 0.25–0.40 s |
| Ambient preload + first bed cue | the mode-pick frame | 0.25–0.4 s (load ~10 ms; the cue starts the audio device) |

The pck is **78 % imported audio that never plays on cold open**: the two ambient beds are
~2.4 MB each as `.oggvorbisstr` (6.3 MB), and `AST.G3` keeps them off the cold open;
`game_assets/` is 7.1 MB staged loose.

**The bar is met when the GPU process is warm and missed while it initialises**: the probe took
40 ms and the screen painted at 1.78 s in one run; 3.6 s and 7.7 s in another, same build and
machine. The published 3.0–4.4 s record is that spread.
