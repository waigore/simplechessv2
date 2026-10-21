# Manifest

- **Issue**: 57
- **Environment**: graphical
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`7cad9d1` on `main`; same build as headless-20261021T173200Z). Display: macOS / Metal (editor display playtest path per `specs/technical/verification.md` S2).
- **Coverage mode**: full (wave-1 scoped — same scope as headless twin)
- **Screenshots**: present under `screenshots/`.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-mode-pick S1 / S3 / S4 (graphical) | pass |
| PTU-mode-pick S2 | n/a — Wave 2 |
| PTU-shared-setup (graphical) | pass |
| PTU-navigation Shared transitions (graphical) | pass |
| PTU-controls entry chrome (graphical) | pass (rendered focus/hover chrome visible) |
| PTU-controls board paths | n/a — #58 |
| PTU-exceptions S3 quit confirm (graphical) | pass |
| PTU-exceptions S1 / S2 | n/a — #58 |

## Paths

- `notes.md`
- `logs/graphical-capture.log`
- `screenshots/01-mode-pick-s1.png`
- `screenshots/02-mode-pick-locale-zh.png`
- `screenshots/03-mode-pick-quit-confirm.png`
- `screenshots/04-shared-setup.png`
- `screenshots/05-shared-setup-blitz.png`
- `screenshots/06-shared-play-stub.png`
