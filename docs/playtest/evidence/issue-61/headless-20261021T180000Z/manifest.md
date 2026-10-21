# Manifest

- **Issue**: 61
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`4baccec` on `main`; PR #299 `096f019`). Headless smoke `TEL.3`: `sess-1792605530328-11464-playtest`.
- **Coverage mode**: full (wave-1 scoped — see notes)
- **Screenshots**: waiting on graphical run of the same build (`../graphical-20261021T180000Z/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| PTD-game-state S1–S4 (play / puzzle fields) | n/a — shared-play board #58; puzzle stream Wave 2 |
| PTD-game-state S5 / P2 (Last mode persist + failed write) | pass (`persist_store_test`; Wave-2 Elo / recent-solved commit N/A) |
| PTD-mode-and-config S1 (Last mode highlight if persisted) | pass |
| PTD-mode-and-config S2–S5 | n/a — Shared CFG / Puzzle path beyond this issue’s Last-mode slice |
| PTU-mode-pick S1 (Shared) | pass (commit path) |
| PTU-mode-pick S2 (Puzzle stream) | n/a — Wave 2; `C2` absent |
| PTU-mode-pick S3 (Last mode affordance) | pass (durable via `CMP-persist-store`) |
| PTU-mode-pick S4 (locale) | n/a — already accepted on #57 |
| PTU-exceptions S1 (offline Advice) | n/a — needs shared-play Advice UI (#58) |
| PTU-exceptions S2 (illegal move) | n/a — needs shared-play board (#58) |
| PTU-exceptions S3 (quit confirm) | n/a — already accepted on #57 |
| PTU-exceptions `EX.save-failure` (mode-pick S4) | pass (`entry_spine_test` + `persist_store_test` forced failure) |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/headless-smoke.log`
- `logs/ptd-persist-store.log`
- `logs/ptu-entry-spine.log`
