# Notes

## How the measurements were taken

- Peaks and levels: `ffmpeg -af volumedetect` on `audio_runtime/<id>.ogg`; spectral centroid from a 256-sample FFT track at 44.1 kHz.
- Piece sizes: the drawn figure per square in the exercise screenshot (board origin 72,352 px; 72 px per unit), counting pixels that are neither square color nor an overlay color.
- Bevel and coordinates: column and row colour profiles through the board edges, plus the per-square ink count for the a–h row and the 1–8 column.

## What changed in the demo

- `demos/shared-game/board_view.gd` — body-fitted piece scale (`D11`), wooden bevel (`D12`), coordinate lip (`D13`); the old cream `main.gd` labels were removed.
- `demos/shared-game/main.gd` — removed `_setup_coords` / `_coord_label` (coordinates now belong to the board plane).
- `demos/shared-game/README.md` — scope, style, decisions, run steps, and known limitations corrected against what the build does (autodrive line length, castling/en-passant claims, screenshot path).

## Limits of this run

- The reference run is the autodrive; no human played a game in this session. Tap and drag use the same input path as the scripted moves.
- Item 2 of #427 needs an asset regeneration, which is outside this session's tool set.
