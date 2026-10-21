# Manifest

- **Issue**: 94
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`task/94-shared-play-choices-fix` worktree; verification-fix pass over #358). Shared-play test `TEL.3`: `sess-1792618760451-71016-playtest`. Graphical twin: `sess-1792618860774-71986-playtest`.
- **Coverage mode**: full (in-scope protocols named by #94 AC: `PTU-shared-play`, `PTU-controls`, `PTU-exceptions`, plus design `PTD-shared-game` / `PTD-end-conditions` via session suite).
- **Screenshots**: waiting on graphical run of the same build (`../graphical-20261021T213840Z/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-controls.S2 / B8 / B9 clear selection (no cue) | pass |
| PTU-controls.S5 / B11 bad-drop clear | pass |
| PTU-exceptions.S2 / EX.rejected / S5 / PER.R8 | pass |
| EX.promote / S4 enter, deselect, C6 commit (no auto-queen) | pass |
| Promotion overlay sprites stay on destination (last-rank) | pass |
| EX.draw-offer / S6 C5→C7/C8/C9 + lapse / END.D2 | pass |
| Design PTD-shared-game + end-conditions (session suite) | pass |
| Unit tests / Coverage | pass |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/shared-play-test.log`
- `logs/shared-game-session-test.log`
- `logs/headless-smoke.log`
- `logs/build-id.txt`
