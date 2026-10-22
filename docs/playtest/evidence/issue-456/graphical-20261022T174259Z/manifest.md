# Manifest

- **Issue**: 456
- **Environment**: graphical
- **Build / session id**: `eec7d4a` (merged fix `a6dbfd9`, PR #464). Godot 4.7.2.stable.official.ed1daf0bf, macOS / Metal. Capture `TEL.3`: `sess-issue-456-accept`.
- **Coverage mode**: not a playtest protocol run — see below.
- **Screenshots**: present under `screenshots/`.

## Why this is not a full playtest protocol run

`specs/playtest/playtest.md` gates playtesting on deliverables that change playable behavior (the game in `game/`). #456 changes only `demos/shared-game/`, and [`docs/demos.md`](../../../../docs/demos.md#what-is-relaxed) makes playtesting optional for demos. The demo's own autodrive assertion suite (`_check_end_panel`) plus a graphical run is the equivalent evidence, so no `PTD-*` / `PTU-*` protocol is claimed here.

## Results

| Check (defect #456 acceptance criteria from review) | Result |
|------------------------------------------------------|--------|
| End panel stays inside the 720×1280 frame with 4 px+ margins | pass |
| End panel does not cover the mating position (rank 7 `f7`, rank 8) | pass |
| End panel draws above the piece/overlay board layers | pass |
| Result text stays inside the panel with clear margins | pass |
| Demo autodrive suite (`DEMO_AUTODRIVE=1`) | pass (headless and graphical) |

## Paths

- `notes.md`
- `logs/graphical-autodrive.log` — full console transcript of the graphical autodrive run (`[demo] PASS`, exit 0; `end panel [P: (41.0, 582.5), S: (638.0, 185.0)] inside the frame; margins 230/160; z 10`)
- `logs/headless-autodrive.log` — same suite headless (`[demo] PASS`, exit 0)
- `screenshots/01-shared-game-mate-end-panel.png` — mate line `h5f7#`; the judged state
- `screenshots/02-shared-game-exercise.png` — mid-game exercise frames, board unaffected
