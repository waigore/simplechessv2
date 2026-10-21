# Manifest

- **Issue**: 61
- **Environment**: graphical
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`4baccec` on `main`; same build as headless-20261021T180000Z). Display: macOS / Metal (editor display playtest path per `specs/technical/verification.md` S2).
- **Coverage mode**: full (wave-1 scoped — same scope as headless twin)
- **Screenshots**: present under `screenshots/`.

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-mode-pick S1 / S3 (Last mode commit + affordance) | pass |
| PTU-mode-pick S2 | n/a — Wave 2 |
| PTU-exceptions `EX.save-failure` (mode-pick S4 + dismiss) | pass |
| PTU-exceptions S1 / S2 | n/a — #58 |
| PTU-exceptions S3 quit confirm | n/a — accepted on #57 |

## Paths

- `notes.md`
- `logs/graphical-capture.log`
- `screenshots/01-mode-pick-last-mode-none.png`
- `screenshots/02-after-commit-shared-setup.png`
- `screenshots/03-mode-pick-last-mode-shared.png`
- `screenshots/04-ex-save-failure.png`
- `screenshots/05-dismiss-save-failure-s1.png`
