# Builds under test

Two builds were read. They are **never merged and never compared as one build**: every
row in `manifest.md` names the build it read.

## 1. Published (preferred)

| Field | Value |
|---|---|
| URL | `https://waigore.github.io/simplechessv2/` |
| Commit | `c5b8189` — "Keep the PER.R6 Check word on one line (#767) (#817)" |
| Attributing `Web release` run | **`40118381611`** (`completed/success`, 2026-10-24T17:56:09Z, `Deploy to Pages` green) |
| Source of attribution | `gh run list --workflow="Web release" --branch main` — newest successful run on `main` whose commit is at or after #647's asset-root repair |
| `TEL.3` session id | none — the release export strips telemetry (`I3`/`G2`), so the published build emits no session id. Recorded as absent by design, not as a missing capture. |

Rows read on this build: Load time (board-playable half), Performance, Reliability
(recovery half), Save durability, Accessibility (board observation), Localization attempt.

## 2. Fallback — local `Web Release` export of `0019e75`

| Field | Value |
|---|---|
| Commit | `0019e75` — "Keep the advice marks to PAL.K9 edge brackets (#828)" |
| Path | `build/web/` (served at `http://127.0.0.1:8765/`) |
| Command | `python3 .github/scripts/web_export.py --preset "Web Release"` |
| Why used | The board-touch defect (#845) was reproduced here while diagnosing; `0019e75` is four commits **ahead** of the published `c5b8189` (`952c658`, `4f133e8`, `c937b9e`, `0019e75`) and is not itself published. This reading only supports the diagnosis; the shipped claim rests on the published build. |

Rows read on this build: board-touch mapping diagnosis (supporting #845) only.

## Environment

- macOS arm64, Chrome (headless `--headless=new`), SwiftShader WebGL
  (`--use-angle=swiftshader --enable-unsafe-swiftshader`), no GPU.
- Viewport 390×844 CSS px, `deviceScaleFactor` 2 (canvas backing 780×1688), touch
  emulation on, `--window-size=390,844`.
- Project video config as shipped: `game/project.godot` →
  `viewport_width=1280`, `viewport_height=720`, `stretch/mode="canvas_items"`,
  `stretch/aspect="expand"`.
- The machine was also running the capture scripts themselves; timings are therefore
  lower bounds on a quiet device, not device-representative figures.

## Repeat count

| Reading | Repeats |
|---|---|
| Cold open to mode pick | 3 (cache disabled per run) |
| Move frame window | 2 (move committed in both) |
| Save durability / forced failed write | 1 sequence |
| Renderer-crash reopen | 1 sequence |
| Board touch mapping | 2 (published) + 1 (fallback) |

## Drivers

Dependency-free CDP drivers kept with the run so the readings can be repeated from a
clean checkout: `drive.mjs` (browser + input + screenshots), `locator.mjs` (finds
controls and the board grid in a screenshot instead of hard-coding points),
`pnglib.mjs` (PNG decoder), `rungate.mjs` (the published-build blocks),
`ymap.mjs` and `confirmmove.mjs` (the rank sweep and the move-confirmation probe).
