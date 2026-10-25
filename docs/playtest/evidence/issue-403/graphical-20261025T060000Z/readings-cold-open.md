# Readings — cold open and a first legal move

Build: the **published** release `c5b8189` served by run `40118381611`. Every number is from
`https://waigore.github.io/simplechessv2/`; none from a local export.

## Why a readback, not a screenshot

`Page.captureScreenshot` can return a frame the compositor still holds. The probe is instead the
build's own canvas: `gl.readPixels` over a 96×208 patch, once per `requestAnimationFrame`, inside
the page. A frame is *painted* when the readback is non-zero — the cream mode-pick panel
(mean ≈ 240), not the near-black loading screen.

`scripts/cold_open_exact.mjs` installs the probe on the build's own document (it cannot survive
navigation) and stamps each frame from that document's `timeOrigin`, so the open is measured from
the moment the document began.

## Cold open to the first painted screen (mode pick)

Four clean runs on an idle machine, HTTP cache disabled.

| Run | First frame sampled | **First painted screen** | Frames probed | Over ≤ 3 s |
|---|---|---|---|---|
| `x1` | 2230 ms | **4394 ms** | 408 | yes |
| `x2` | 1996 ms | **3346 ms** | 661 | yes |
| `x3` | 1778 ms | **3039 ms** | 746 | yes |
| `x4` | 1377 ms | **3249 ms** | 774 | yes |

**4 of 4 paint after 3000 ms**, spread 3039–4394 ms: the fastest misses by 39 ms, the slowest by
1394 ms. `x1` also had the slowest engine start (`Godot Engine v4.7.2…` at 2.857 s vs 2.210 s in
`x3`), so both read one stall. The first *sampled* frame is when the rAF loop began, not when
pixels appeared: before that there was no `canvas` to read.

A control under the 250 ms-polling route harness gave **3208 ms**
(`screenshots/r2-01-first-painted.png`). It agrees and is not counted — that harness cannot
resolve the boundary.

**Not counted:** three runs on a machine pinned by leaked `cap402` Chromes (GPU helpers at ~420 %
CPU, load 33) gave 9.4/9.2/9.3 s. They measure the machine. Killing them restored load to ~4.

## First legal move

`Shared game` (195,172) → `Start` (120,312) → tap `e2` (214,632) → tap `e4` (214,554).

Header `White to move` → **`Black to move`**; `e2` empty, white pawn on **`e4`**
(`screenshots/mv1-09-move+5000.png`). Touch stamps (`mv1`): 9.53 s, 12.28 s, 17.83 s, 20.60 s.

**The published build reaches a playable board and accepts a real move.** Earlier "no move
reachable" notes in this session came from a wrong square map (DPR-2 pixels read as CSS) and are
withdrawn. Correct map at 390×844 CSS: `fileA = 59.5`, `row8 = 399.5`, `step = 38.75`
(`e2` = 214,632; `e4` = 214,554; `e1` centre ≈ 671). `probe_input.mjs` confirmed CDP touch,
pointer and mouse events all reach `CANVAS#canvas` at the tap point.
