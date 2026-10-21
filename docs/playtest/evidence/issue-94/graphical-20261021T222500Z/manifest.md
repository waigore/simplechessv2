# Manifest

- **Issue**: 94
- **Environment**: graphical
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (see `logs/build-id.txt`; same tree as headless-20261021T222500Z). Display: macOS / Metal (editor display playtest path). Capture `TEL.3`: `sess-1792621574561-11265-playtest` (re-run for layout fix).
- **Coverage mode**: full (shared-play choice states after S4 chrome fix)
- **Screenshots**: present under `screenshots/`.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-shared-play (graphical) play + choice states | pass |
| PTU-controls (graphical) S2 deselect / B9 clear | pass |
| PTU-exceptions (graphical) S5 reject flash + S4 promote + S6 draw | pass |
| END.D2 via Accept → shared-result | pass |
| S4 chrome vs R1 (no promote row into board) | pass |

## Paths

- `notes.md`
- `logs/graphical-capture.log`
- `logs/build-id.txt`
- `screenshots/01-shared-play-s1.png`
- `screenshots/02-selection-legal.png`
- `screenshots/03-deselect-cleared.png`
- `screenshots/04-b9-empty-deselect.png`
- `screenshots/05-reject-flash-s5.png`
- `screenshots/06-promote-s4.png`
- `screenshots/07-draw-offer-s6.png`
- `screenshots/08-draw-accepted-result.png`
