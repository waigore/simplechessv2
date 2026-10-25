# Manifest — #845 board taps on the release Web build

- **Issue**: #845 — Release Web: board taps hit one rank above the square under the finger
- **Environment**: graphical. Headless Chrome 144 (`--headless=new`, SwiftShader WebGL 2.0), frame 390×844 CSS px, DPR 2 (780×1688 backing buffer), touch emulation over CDP. The release export carries no playtest seams (`CMP-playtest-seams` R3), so there is no `TEL.3` session id.
- **Build under test**: `39aeaf8` on `defect/845-board-tap-offset-v2` (base `origin/main` `491554e`), exported with `python3 .github/scripts/web_export.py --preset "Web Release"` into `build/web/` and served by `python3 -m http.server`. Local export, not the published URL: the branch is unpublished while its PR is open (procedures `Prep` fallback).
- **Coverage mode**: not a story-row run. This is defect support for `CMP-presentation` R2, not a coverage or acceptance run.
- **Timing (`SIT.4`)**: not cited. One coordinate run of three taps, repeated by hand; the run measures squares, not timing.

## Results

| Check | Method | Outcome |
|---|---|---|
| Tap the painted e2 pawn | touch at the e2 centre measured from the build's own screenshot (214.5, 630 CSS) | **pass** — selection ring on e2 |
| Tap the painted e4 square with e2 selected | touch at the e4 centre (214.5, 552 CSS) | **pass** — e2–e4 commits; header reads `Black to move`, pawn painted on e4 |
| The filing's e2 coordinate (219, 654 CSS) | touch there | **e1** — 654 lies inside e1's painted square (649.5–688.5), so e1 is the square under the finger |
| The reported symptom — a tap selects one rank above the finger | the two painted taps above | **not reproduced** |

The same three taps on unmodified `origin/main` `30faab7` gave the same squares and byte-identical screenshots (control readings and hashes: [`control-main-30faab7/`](control-main-30faab7/)). The shipped conversion already mapped taps to the painted square before this branch's code change.

## What was measured

The painted board, read from `screenshots/board-00-before.png` (device px ÷ DPR 2):

```
grid  left 39   right 351   top 376.5   bottom 688.5   square 39   (CSS px)
e2 centre (214.5, 630)    e4 centre (214.5, 552)    e1 spans y 649.5–688.5
```

Cause and the limit of the reading: [notes.md](notes.md).

## Paths

- [notes.md](notes.md) — confirmed cause, the readings, and what this run does not prove
- [readings.json](readings.json) — each tap's coordinate, the measured grid, and the square its ring named
- `screenshots/` — `board-00-before.png`, `board-01-tap-219-654.png`, `board-02-tap-painted-e2.png`, `board-03-tap-painted-e4.png`, `board-04-after.png`
- `logs/run-console.log` — page console. The `WebGL: INVALID_OPERATION` and GPU-stall lines are SwiftShader renderer warnings; no script error or exception appears.
- `control-main-30faab7/` — the same taps on unmodified `main`, with its readings and screenshot hashes
- `drive.mjs`, `cdp.mjs`, `board.mjs`, `png.mjs` — the reproducer (Node 22+, no packages). Run `node drive.mjs <url> <runDir>`; the grid and each ring are read from the run's own screenshots.

## Defects

- None filed from this run. It closes the reproduction question for #845.
