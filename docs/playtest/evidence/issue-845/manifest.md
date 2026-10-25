# Manifest — #845 board taps on the release Web build

- **Issue**: #845 — Release Web: board taps hit one rank above the square under the finger
- **Environment**: `graphical`. Headless Chrome 144 (`--headless=new`, SwiftShader WebGL 2.0), frame 390×844 CSS px, DPR 2 (780×1688 backing buffer), touch emulation over CDP. The release export carries no playtest seams (`CMP-playtest-seams` R3), so there is no `TEL.3` session id.
- **Build under test**: branch `defect/845-pointer-path-through-gui-input` (base `origin/main` `6e9cb7e`), exported with `python3 .github/scripts/web_export.py --preset "Web Release"` and served by `python3 -m http.server`. Local export, not the published URL: the branch is unpublished while its PR is open (procedures `Prep` fallback).
- **Coverage mode**: not a story-row run. Defect support for `CMP-presentation` R2, not a coverage or acceptance run.
- **Timing (`SIT.4`)**: not cited. One coordinate run, repeated; it measures squares, not timing.

## Results

Each reading is machine-read from the run's own screenshots (`board.mjs`, `readback.mjs`).

| Check | Method | Outcome |
|---|---|---|
| Painted board grid | dark-square bounds of `screenshots/filing-board.png` | x 39–351, y 376.5–688.5; square 39 CSS px |
| The filing's coordinate (219, 654) | touch there | **e1** — 654 lies inside e1's painted box y 649.5–688.5, so e1 is the square under the finger |
| Tap the painted e2 centre (214.5, 630), then e4 (214.5, 552) | select, then move | **e2–e4 commits**; ring on e2, header `Black to move`, pawn painted on e4 |
| Same for d2–d4, b1–c3, g1–f3 | one fresh session each | **all three commit** on the tapped square; header flips to Black |

The reported symptom — a tap selects one rank above the finger — **did not reproduce**. Details and the confirmed cause: [notes.md](notes.md).

## Paths

- [notes.md](notes.md) — confirmed cause, the readings, and what this run does not prove
- `readings.json` — the filing tap's ring box and square, the four pairs' taps, rings, header side and painted ink
- `screenshots/` — `step-mode-pick.png`, `filing-board.png`, `filing-after-219-654.png`, `<pair>-board.png`, `<pair>-a.png` (after the select tap), `<pair>-b.png` (after the move tap)
- `logs/verify-console.log` — page console. The `WebGL: INVALID_OPERATION` and GPU-stall lines are SwiftShader warnings; no script error appears.
- `verify.mjs`, `cdp.mjs`, `board.mjs`, `png.mjs`, `readback.mjs` — the reproducer (Node 22+, no packages): `node verify.mjs <url> <runDir>`. It exits non-zero if the filing tap rings anything but e1 or any pair fails to commit.
