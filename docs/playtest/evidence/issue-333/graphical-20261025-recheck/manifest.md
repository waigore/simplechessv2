# Manifest

- **Issue**: 333 — Build the puzzle play screen, mode-pick entry, and stream journey
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, macOS Metal
  display (Apple M5, Compatibility renderer), shipped playtest scene `game/main.tscn`, frame
  1280×720.
- **Build / session id**: `origin/main` `1cd132b`. `TEL.3` session
  `sess-1792872307807-94680-playtest-395158` (`logs/graphical-run.log`).
- **Why this run**: the previous run (`graphical-20261024T150000Z`, `39fb372`) failed three
  protocols on #793, #794, #795 and left `SIT.4` not-judged. All three are fixed and
  accepted on `main` since (#820, #802, #810); this run repeats those protocols and takes
  the timing sample.
- **Coverage mode**: partial — this task's six protocols, below. #400's sweep rows are
  `not-judged`.
- **Timing (`SIT.4`)**: judged — three repeats through the shipped `O10` seam, five
  samples per move (`logs/graphical-run.log`, `TIME_REPORTS=`).
- **Deal source**: the seams catalog peer answers no read, so the play legs inject the
  mate-in-one and promotion records through `DBG.3`, as `game/puzzle_play_test.gd` does.
  Entry, leave, and the journey legs run on the real `C2` / `C5` / confirm path.
- **Screenshots**: all under `screenshots/`, from this build.

## Results

| Story / step | Outcome | Notes |
|--------------|---------|-------|
| `PTU-mode-pick` S1/S3/S4 (`UI-mode-pick.US1`) | **pass** | C2 "Puzzle stream" from `mode-pick.puzzle`, 272×49, enters the stream (`NAV.T2`); `· Last` on return. |
| `PTU-mode-pick` S1 load timing (`SIT.4`), S6 | not-judged | #400 sweep |
| `PTU-puzzle-session` S1–S3 (`J-puzzle-session`) | **pass** | Enter from mode-pick, Leave → `leave_confirm` → mode-pick, Cancel stays with the puzzle open and unscored (Elo unchanged). `logs/graphical-checks.log` |
| `PTU-puzzle-play` S1 (`US1`) | **pass** | R2 `Elo 1000` on one line (127×48, text fits), R3 Reveal/Abandon/Leave paint; #794 closed. `screenshots/puzzle-play-s1.png` |
| `PTU-puzzle-play` S4/P3 (`SIT.4`) | **pass** | Window closes on the judged move; per-move max 2.31–5.65 ms, 5 samples, 3 repeats; device/build recorded above. `logs/graphical-run.log` |
| `PTU-puzzle-play` S5 (`US2`) | **pass** | `cue_solved` = "Solved" one line; the S2 prompt paints (37 963 px changed vs closed, 669 colours); Abandon confirm paints; `cue_abandon` shown. `screenshots/puzzle-play-s2-*.png`, `puzzle-play-solved.png`, `puzzle-play-abandoned.png` |
| `PTU-puzzle-play` S6–S8 (`US3`) | **pass** | Promotion choice shows Queen/Rook/Bishop/Knight as visible, unclipped labels, each paints (374/306/427/416 px); C6 queen commits; refusal → S5 `Refused place` with no wrong cue. `screenshots/puzzle-play-s4-promotion.png`, `puzzle-play-s5-refused.png` |
| `PTU-navigation` S1–S3 (`NAV.US1`/`US2`) | **pass** | `C2` → puzzle-play, `C5` confirm → mode-pick, cancel stays put. |
| `PTU-controls` S1/S2/S5–S6 (`IN.US1`–`US3`) | **pass** | Select/refused place behave; C3/C4/C5 = 408×49, prompt buttons ≥ 44 px; the S2 prompt paints, so it is operable by pointer. |
| `PTU-exceptions` S2/S3 (`EX.US1`) | **pass** | Leave confirm visible and interruptible; refusal is S5, not a wrong move; a store write failure raises S3 (`save_failed`, C5 usable, Dismiss → S1). `screenshots/puzzle-play-s3-save-failure.png` |

## Defects

- None re-opened. #793, #794, #795 hold on this build.

## R1 orientation

White to solve → seat bottom (0°) read on deal. The Black → 180° leg is covered by
`game/puzzle_play_test.gd`; the seams build refused every Black-to-solve fixture tried
(`notes.md`).

## Paths

- `notes.md`, `logs/`, `screenshots/` (14), `probe/` (throwaway harness)
