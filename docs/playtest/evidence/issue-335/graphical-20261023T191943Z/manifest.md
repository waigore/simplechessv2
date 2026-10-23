# Evidence manifest — issue #335, demo run (graphical)

| Field | Value |
|-------|-------|
| Issue | #335 (epic #35, wave 1 demo follow-on) |
| Environment | graphical (`DEMO_AUTODRIVE=1`), 720×1280 window |
| Build / session id | branch `task/335-demo-puzzle-stream` off `origin/main` `ab5b144`; `demos/puzzle-stream/`; Godot `4.7.2.stable.official.ed1daf0bf` |
| Coverage mode | demo (`docs/demos.md`: unit tests and playtesting are optional) |

A graphical run needs `DEMO_AUTODRIVE=1`; without it the window idles on mode pick for a
human. `DEMO_SHOT_DIR` makes the autodrive save each captured frame.

## Results

| Unit | Cited spec elements | Outcome |
|------|---------------------|---------|
| Mode pick offers Puzzle stream / Quit, calm and unstyled-button free | `NAV.T2`, `AES.P1`, `AES.P3` | pass — see `screenshots/demo-puzzle-stream-mode-pick.png` |
| Puzzle play: board, Elo region above, action bar below, all clear of the board | `UI-puzzle-play.R1`, `R3`, `L-puzzle-stream.K1` | pass — see `screenshots/demo-puzzle-stream-puzzle-play.png` |
| Quiet mahogany palette, wooden bevel, rose only for check/refusal | `AES.P3`, `SRF.M1`, `PAL.C2`/`C5`/`C8` | pass |
| Same scripted cases as the headless run | as `headless-*/manifest.md` | pass — `[demo] PASS` |

No failures.

## Paths

| Artifact | Path |
|----------|------|
| Autodrive log | `logs/autodrive.log` |
| Mode-pick screenshot | `screenshots/demo-puzzle-stream-mode-pick.png` |
| Puzzle-play screenshot | `screenshots/demo-puzzle-stream-puzzle-play.png` |
