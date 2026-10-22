# Manifest

- **Issue**: 432
- **Environment**: graphical (`ENV.2`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`f943fb3` on `main`; deliverable merged as `95386d5`, PR #489). Display: macOS / Metal (OpenGL Compatibility). Capture `TEL.3`: `sess-1792707142333-15265-playtest`.
- **Coverage mode**: full, intersected with issue scope: `PTU-shared-result` (UX). No Design protocol needs a graphical run.
- **Screenshots**: present under `screenshots/`.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-shared-result S1 (graphical) — draw ending reaches the result screen | pass |
| PTU-shared-result S1 outcome vehicle — `result_draw` copy, no end cue (`cue_delta=0`) | pass |

Design level: `PTD-end-conditions` is headless-only; judgement is in `../headless-20261023T061200Z/`.

## Paths

- `notes.md`
- `logs/graphical-capture.log`
- `logs/unit-tests.log`
- `screenshots/01-shared-result-draw.png` — shared-result after accept-draw (`END.D2`)
