# Notes — #333 prompt-fill run

## Independence

This session wrote none of #333's code. The run is a fresh graphical session on a clean
`origin/main` `8e7237d` checkout, exported to Web and driven in a browser through the
shipped scene. The branch carries this evidence only.

## How the screen was driven

- **Mode pick → puzzle-play**: a real touch at the painted `Puzzle stream` (C2) row.
- **Prompt**: a real touch on the painted `Leave stream` (C5) button, reaching
  `PuzzleSession.request_confirm`, which sets `S2`.
- **Cancel / Confirm**: real touches on the painted buttons.
- **Measurement**: `Page.captureScreenshot` at DPR 1, decoded pixel by pixel
  (`probe/png.mjs`), reading the prompt's own rect
  (`Presentation.place_centered_over_board(box, 220)` → 500–780 × 220–360) and four rows
  through it (top edge 240, message 262, buttons 306, body 345).

## What was measured

Every Leave leg: the frame right after the tap, then the frame after 900 ms.
`readings.json` holds per-leg numbers; `manifest.md` summarises them.

- The rect is `#F7F1E8` (`UiChrome.COLOR_BG`) across its body. The 1 257 px that are not
  the panel colour are AA edges at the rounded corners — the same count in all four legs,
  so they are the panel's geometry, not board paint.
- **No board band.** Four rows were scanned for runs wider than 4 px of the board's square
  colours (`#E8D5B5`, `#8B5A3C`). None appeared. On the S1 capture the same x-span is 100 %
  board square, so the check is live.
- **Contrast** of the prompt's copy over its own fill is 6.39:1 (`COLOR_MUTED` on
  `COLOR_BG`), above `PAL.K4`'s 4.5:1.

## Why only Leave was raised

`puzzle_play_flow.gd` deals on journey entry and the seams peer answers no read, so
`has_open_puzzle()` is false on S1 here. `PuzzlePlayPanel.control_available` disables C1–C4
without an open puzzle, which is why `02-puzzle-play-s1.png` shows Reveal and Abandon muted.

The fill measured is one node, `StreamConfirm`, shared by all three prompts: the message
label and the `ConfirmStream` / `CancelStream` row are built once and only their text
changes with `confirm_kind`. The fill finding therefore covers the component; the Reveal and
Abandon *copy* legs were not observed and stay with #400's sweep.

## How the disputed capture could differ

The verification reproduced its reading by re-running `graphical-20261025-recheck`'s probe,
and that probe's notes say its play legs inject a record through `DBG.3`. This run takes no
such step, so its S1 has no open puzzle: the two sessions raised the prompt over different
screen states. I did not reproduce the tiled capture, so I can state what the shipped code
paints from a clean entry and nothing about that session's pixels.

## Limitations

- `PTU-puzzle-play` S1–S8, `SIT.4` frame time, the S2 Reveal/Abandon copy legs, the S1
  orientation reading and `PTU-puzzle-session` deal/advance are not re-judged here.
- Browser with SwiftShader, not the macOS native window earlier graphical runs used. The
  fill is a compositing property, which is what the browser renderer exercises.
- No timing sample was taken.
