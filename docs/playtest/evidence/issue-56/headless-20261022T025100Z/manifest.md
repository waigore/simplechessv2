# Manifest

- **Issue**: 56
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`e080596` on this worktree; board deliverables from merged PR #307 `4b9f52e` + PR #311 `27021fc`). Headless smoke `TEL.3`: `sess-1792608919665-74585-playtest`.
- **Coverage mode**: full (in-scope for #56 — see notes). View stories (`PER` / `PHY` / `CAM` / `PRJ`) are out of the playtest set; judged via headless unit checks and AC table.
- **Screenshots**: waiting on graphical run of the same build (`../graphical-20261022T025100Z/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| PTU-shared-session S1 (mode-pick → setup → Start → shared-play) | pass |
| PTU-shared-play S4 (coordinates / board affordances on R1) | pass |
| PTU-shared-play S1 / S2 / S3 (seat operate / resign) | n/a — board input + resign on #58 |
| PTU-controls S1–S5 board paths | n/a — bindings #58 / #94; this task draws only |
| CAM-board.M2 seat flip (Top → π) | pass (presentation; not a Design protocol) |
| PER.R3 / R4 marks via O2 | pass (presentation; not a Design protocol) |
| `board_presentation_test` geometry / seat / viewport / timing | pass |
| Design PTD-* | n/a — deliverable does not change rules outcomes |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/headless-smoke.log`
- `logs/board-presentation-test.log`
- `logs/ptu-entry-spine.log`
- `logs/ptu-shared-play-board.log`
