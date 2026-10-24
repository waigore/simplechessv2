# Paths — issue #616, graphical acceptance run (re-recorded for #742)

Index: [`manifest.md`](manifest.md).

## Screenshots (19)

Rendered framebuffer of the judged state, per frame size. Every file is listed; none is waiting.

| 1280×720 | 1600×900 | 390×844 (`SIT.6`) |
|---|---|---|
| `screenshots/w1280-01-mode-pick.png` | `screenshots/w1600-01-mode-pick.png` | `screenshots/phone-01-mode-pick.png` |
| `screenshots/w1280-02-shared-setup.png` | `screenshots/w1600-02-shared-setup.png` | `screenshots/phone-02-shared-setup.png` |
| `screenshots/w1280-03-resign-confirm.png` | `screenshots/w1600-03-resign-confirm.png` | `screenshots/phone-03-resign-confirm.png` |
| `screenshots/w1280-04-shared-result.png` | `screenshots/w1600-04-shared-result.png` | `screenshots/phone-04-shared-result.png` |
| `screenshots/w1280-05-stream-confirm.png` | `screenshots/w1600-05-stream-confirm.png` | `screenshots/phone-05-stream-confirm.png` |
| `screenshots/w1280-06-save-failure.png` | `screenshots/w1600-06-save-failure.png` | `screenshots/phone-06-save-failure.png` |

`screenshots/caps-frame-3239.png` — the liveness capture, taken on the last frame of the phone pass.
It is the mode-pick state, so it is identical to `phone-01`; [`checks.md`](checks.md) *Images* explains
why the drive produces that pair.

## Run artifacts

- Drive: [`drive_graphical.gd`](drive_graphical.gd)
- Runner: [`run_graphical.sh`](run_graphical.sh)
- Index: [`manifest.md`](manifest.md)
- What was run: [`run.md`](run.md)
- Checkable claims: [`checks.md`](checks.md)
- Rendered pixels: [`images.md`](images.md)
- Build and CI checks: [`build-checks.md`](build-checks.md)
- Corrections to #742: [`corrections.md`](corrections.md)
- Notes: [`notes.md`](notes.md)
- Protocols: [`protocols.md`](protocols.md)

## Logs

| File | Content |
|---|---|
| `logs/graphical-drive.log` | Full drive log: environment line, 18 geometry rows, overflow and text lines, 19 `shot` lines, `RESULT fails=0` |
| `logs/unit-tests.log` | `gdscript_tests.py test` |
| `logs/coverage.log` | `gdscript_tests.py coverage` |
| `logs/lint.log` | `gdlint game` |
| `logs/format-check.log` | `gdformat --check game` |
| `logs/spec-lint.log` | `spec_lint.py` |
