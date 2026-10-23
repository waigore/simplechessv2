# Manifest

- **Issue**: 426
- **Environment**: graphical
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`1949553` — merged PR #461). Display: macOS / Metal (OpenGL Compatibility). Capture `TEL.3`: `sess-1792686764589-25871-playtest`.
- **Coverage mode**: full (in-scope protocols for the #426 playable deliverable: `PTU-mode-pick`, `PTU-shared-play`; the same journey returns to mode pick via `PTU-shared-result` → Stop)
- **Screenshots**: present under `screenshots/`.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-mode-pick (graphical) cold-open silent (`EX.loading`) | pass |
| PTU-mode-pick (graphical) Ambient loaded + `BED_M1` started when mode pick becomes ready | pass |
| PTU-shared-play (graphical) bed continues through Shared setup and Shared play; play group loaded on first entry | pass |
| PTU-mode-pick (graphical) bed continues after result → Stop → mode pick for the sitting (M1 → M2 → M1) | pass |

Design level: no `PTD-*` design protocol is in scope — #426 changes the Ambient load/start point and its statements, not game rules or a design story.

## Judgement against `SND.M1`

`SND.M1` covers "All play **and mode pick**". The graphical run confirms the bed is audible/started at mode pick ready, not deferred to Shared play, and continues across play and the return to mode pick. Cold open (`EX.loading`) stays silent, matching `EX.loading` and `FAIL.T6` (load gate only, out of scope).

## Paths

- `notes.md`
- `logs/graphical-capture.log`
- `logs/unit-tests.log` — `python3 .github/scripts/gdscript_tests.py test` on the same build (15 passed)
- `screenshots/01-cold-open-loading-silent.png` — cold open, no Ambient group, no music
- `screenshots/02-mode-pick-ready-ambient-started.png` — mode pick ready; `ambient_loaded=true`, `music_started=true`, `bed_index=0` (M1)
- `screenshots/03-shared-setup-bed-continues.png` — Shared setup; bed still playing
- `screenshots/04-shared-play-bed-continues.png` — Shared play; play group loaded, bed still playing
- `screenshots/05-mode-pick-return-bed-continues.png` — returned to mode pick; `ambient_loaded=true`, `music_started=true`
