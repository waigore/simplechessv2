# Manifest

- **Issue**: 57
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`7cad9d1` on `main`; entry spine PRs #290 + #295). Headless smoke `TEL.3`: `sess-1792603972073-83360-playtest`.
- **Coverage mode**: full (wave-1 scoped — see notes)
- **Screenshots**: waiting on graphical run of the same build (`../graphical-20261021T173200Z/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-mode-pick S1 (Shared game) | pass |
| PTU-mode-pick S2 (Puzzle stream) | n/a — Wave 2; `UI-mode-pick.C2` absent by AC |
| PTU-mode-pick S3 (Last mode affordance) | pass (in-memory; durability #61) |
| PTU-mode-pick S4 (Switch locale) | pass |
| PTU-shared-setup S1–S3 | pass |
| PTU-navigation Shared `NAV.T1`/`T3`/`T4`/`T5` | pass |
| PTU-navigation Puzzle entries | n/a — Wave 2 |
| PTU-controls board select/move/deselect/drag | n/a — shared-play board is #58 |
| PTU-controls entry `B1`/`B4`–`B7` (touch, focus, `IN.point`) | pass (`entry_spine_test`) |
| PTU-exceptions S1 (offline Advice) | n/a — needs shared-play Advice UI (#58) |
| PTU-exceptions S2 (illegal move) | n/a — needs shared-play board (#58) |
| PTU-exceptions S3 (quit confirm cancel) | pass |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/headless-smoke.log`
- `logs/ptu-entry-spine.log`
