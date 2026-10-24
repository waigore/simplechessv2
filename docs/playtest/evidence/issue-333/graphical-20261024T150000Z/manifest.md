# Manifest

- **Issue**: 333 — Build the puzzle play screen, mode-pick entry, and stream journey
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, macOS Metal
  display (Apple M5, Compatibility renderer), shipped playtest scene `game/main.tscn`, frame
  1280×720.
- **Build / session id**: `origin/main` `39fb372`, run in this issue's own clean worktree.
  `TEL.3` session `sess-1792853944191-57591-playtest-567360` (`logs/graphical-run.log`).
- **Coverage mode**: partial — the six protocols this task owns:
  `PTU-puzzle-play`, `PTU-puzzle-session`, `PTU-mode-pick`, `PTU-navigation`,
  `PTU-controls`, `PTU-exceptions`. Rows that belong to #400's sweep are `not-judged` here.
- **Timing (`SIT.4`)**: **not judged**. `PTU-puzzle-play` S4 asks for a timed move; this run
  drove moves but took no frame-time sample, so P3 is `not-judged` and no timing report is
  claimed. `PTU-mode-pick` S1 load timing is #400's sweep.
- **Deal source**: the seams build's catalog peer answers no read by default, so the play
  legs enter the mate-in-one and promotion scenarios through `DBG.3` (a dealt record injected
  into the live session) exactly as `game/puzzle_play_test.gd` does. Entry, leave, and the
  journey legs run on the real `C2` / `C5` / confirm path. This is a limitation: the network
  deal path itself is not exercised here.
- **Screenshots**: all under `screenshots/`, from this build.

## Results

| Story / step | Outcome | Notes |
|--------------|---------|-------|
| `PTU-mode-pick` S1/S3/S4 (`UI-mode-pick.US1`) | **pass** | C2 "Puzzle stream" present and enters the stream; `· Last` marker renders after leaving. `screenshots/mode-pick-s1.png`, `mode-pick-after-leave.png` |
| `PTU-mode-pick` S1 load timing (`SIT.4`), S6 | not-judged | #400 sweep |
| `PTU-puzzle-session` S1–S3 (`J-puzzle-session`) | **pass** | Enter from mode-pick, Leave → confirm → mode-pick, Cancel stays with the puzzle open and unscored. `logs/graphical-run.log` |
| `PTU-puzzle-play` S1 (`US1`) | **fail** | Board and R3 actions render, but R2 is unreadable and C4 is missing — see F3 defects |
| `PTU-puzzle-play` S5 (`US2`) | **fail** | `cue_solved` / `cue_abandon` fire and carry the right copy, but the cue paints as a vertical letter column (#794); the S2 confirm dialog paints nothing (#793) |
| `PTU-puzzle-play` S6–S8 (`US3`) | **fail** | Promotion commits the chosen piece and refusal enters S5, but the S4 chooser's Q/R/B/N labels are clipped to an 18 px strip (#795) |
| `PTU-puzzle-play` P3 (`SIT.4` frame time) | not-judged | No frame-time sample taken |
| `PTU-navigation` S1–S3 (`NAV.US1`/`US2`) | **pass** | `C2` → puzzle-play, `C5` confirm → mode-pick, cancel stays put; no dead end (C5 always offered from S1) |
| `PTU-controls` S1/S2/S5–S6 (`IN.US1`–`US3`) | **fail** | Tap move, select, and refused place behave; the S2 dialog's own controls are not visible (#793) so they cannot be operated by pointer |
| `PTU-exceptions` S2/S3 (`EX.US1`) | **fail** | No crash and refusal feedback is correct, but interrupting the leave confirm cannot be done visually — #793 |

## Defects

- **#793** — S2 confirm dialog paints nothing; **#794** — R2 text wraps per letter;
  **#795** — S4 promotion labels clipped. Detail in `notes.md`.

## Paths

- `notes.md`, `logs/`, `screenshots/` (12 captures), `probe/` (throwaway harnesses)
