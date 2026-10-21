# Manifest

- **Issue**: 58
- **Environment**: graphical
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`fff626b`; same build as headless-20261021T200916Z). Display: macOS / Metal (editor display playtest path per `specs/technical/verification.md` S2). Capture `TEL.3`: `sess-1792613378781-62127-playtest`.
- **Coverage mode**: full (same in-scope set as headless twin)
- **Screenshots**: present under `screenshots/`.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-shared-play (graphical) play + resign confirm | pass |
| PTU-controls (graphical) selection / place judged states | pass |
| PTU-exceptions (graphical) resign `EX.confirm` | pass |
| CAM-board.M2 Top seat + Blitz clocks R2 | pass |
| F-move-advice.R2 Advice toggle stub (no eval UI) | pass |

## Paths

- `notes.md`
- `logs/graphical-capture.log`
- `screenshots/01-shared-play-bottom.png`
- `screenshots/02-shared-play-selection-legal.png`
- `screenshots/03-shared-play-after-place.png`
- `screenshots/04-resign-confirm-s2.png`
- `screenshots/05-shared-play-top-blitz.png`
- `screenshots/06-advice-toggle-stub.png`
