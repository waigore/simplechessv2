# Manifest

- **Issue**: 795 — Puzzle-play S4 promotion chooser shows no readable Q/R/B/N labels
- **Environment**: headless (`ENV.1`) — Godot `4.7.2.stable.official.ed1daf0bf`, macOS (Apple
  M5), shipped playtest scene `game/main.tscn`
- **Build**: `origin/main` `0019e75`, carrying the fix from PR #810 (`e1f558d`)
- **Coverage mode**: partial — one defect, one step. `PTU-puzzle-play` S4/S6 (C6) only; the
  #333 run owns the whole screen.
- **Deal source**: `DBG.3` — a dealt record injected into the live session, as
  `game/puzzle_play_test.gd` does. Entry is the real `mode-pick` C2 control; locale changes use
  the real `mode-pick` C4 control.
- **Companion graphical run**: `../graphical-20261024T164559Z/` (implementer, the same fix on PR
  #810) carries the required graphical screenshots for this defect. This folder is the
  independent headless judgement.

## Results

| Row | Outcome | Notes |
|-----|---------|-------|
| `PTU-puzzle-play` S6 — each C6 option carries its visible name (`US3.1`, `US3.4`, `US3.8`, `US3.9`) | **pass** | `Queen`, `Rook`, `Bishop`, `Knight` in `en`, `zh-Hant`, `ja`; piece names are locale-invariant by the copy table |
| `PTU-puzzle-play` S6 — names are legible, not clipped (`UIS.T2`) | **pass** | 18 px font, each box equals its minimum size (43–58 × 27 px) |
| `PTU-puzzle-play` S6 — a name covers no square (`PRJ.A1`) | **pass** | every name inside R2, no board intersection |
| `PTU-puzzle-play` S6 — each option commits the piece it names | **pass** | all four sprite taps commit, S4 → S1 |
| `PTU-puzzle-play` S1–S3, S5, S7, S8 | not-judged | Out of scope for this defect; covered by #333's run and `game/puzzle_play_test.gd` |
| `PTU-puzzle-play` P3 frame time (`SIT.4`) | not-judged | No sample taken |
| `PTU-puzzle-play` S6 — reflow at another frame (`SIT.6`) | not-judged | Headless run is single-size; graphical folder measures 1280×720 and 720×1280 |

## Screenshots

None in this folder — headless run, no display (`evidence.md`: a headless run omits
`screenshots/`; this is no fail). The graphical companion folder holds
`screenshots/s4-after-1280x720.png` and `screenshots/s4-after-720x1280.png`.

## Defects

None. No new defect found in the S4 chooser.

## Paths

- `notes.md`, `logs/headless-run.log`, `probe/zz_accept795_headless.gd`
