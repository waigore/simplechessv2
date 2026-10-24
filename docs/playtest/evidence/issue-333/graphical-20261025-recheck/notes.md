# Notes — #333 graphical re-check

## Independence

This session has not written #333's code. The run is a fresh graphical `godot` session on
`origin/main` `1cd132b`, driving the shipped scene; the branch it ships is this evidence
only.

## How the run drove the screen

- **Mode pick and the journey** through the real controls: the `PuzzleStream` button
  (`C2`), `session_router.handle_control(...)` for `C5` / `confirm` / `cancel`, and the
  panel's `ConfirmStream` / `CancelStream` / `DismissSave` buttons.
- **Moves** through `handle_input_commit()` (a board gesture) and
  `handle_promotion_commit("queen")` for C6.
- **The puzzle record** through `flow.session.deal([...])` (`DBG.3`), as
  `game/puzzle_play_test.gd` does; the seams build answers no catalog read by default.
- **Save failure** through the shipped test hook `PersistStore.force_write_failure`, so the
  failure comes from the store's own `write_failed`, not from a hand-emitted signal.
- **Timing** through the shipped `O10` seam: `start_measurement("frame_times")`, one select
  plus one judged place, `measure("frame_times")`, three times.

## What the checks showed

`logs/graphical-checks.log`: **57 `CHECK PASS`, 0 `CHECK FAIL`, `FAILURES=[]`**.

Re-measured for the three defects:

- **#793** — the S2 prompt changed 37 963 px of the board inside its own rect and the
  region went from 121 colours (board cream) to 669; the Abandon prompt the same; S3
  changed 33 542 px. Closed because a prompt now paints, not because its node says
  `visible`.
- **#794** — `Elo 1000` measures 127×48 with the text inside it; `Solved` measures 99×48.
  The 1×405 / 1×48 columns are gone.
- **#795** — the four S4 names are non-empty, unclipped labels (57×27, 43×27, 58×27,
  56×27) and each paints its own ink into the strip (374/306/427/416 px).

## `SIT.4` frame time

Three repeats, five samples each, on the puzzle-play move path:

| Repeat | Samples | Max ms |
|--------|---------|--------|
| 1 | 5 | 1.19–5.65 |
| 2 | 5 | 1.85–2.31 |
| 3 | 5 | 1.19–2.78 |

Device: Apple M5, macOS Metal, Compatibility renderer, Godot 4.7.2. Build id: `1cd132b`
plus this evidence branch. Repeat count: 3. This is a native macOS window, not a browser
(`SIT.4`'s quality target names the web build); the browser side of `PTU-puzzle-play` S4
belongs to the web playtest sweep.

## Limitation recorded honestly

- **Black-to-solve orientation** was not reproduced. `solving_side` is set from the position
  after the record's opening move, and the seams build refused every Black-to-solve fixture
  tried here (`deal()` returned `no_record`; `path` rejected the move list), so only the
  White → 0° leg ran (`screenshots/puzzle-play-orientation-white.png`). The Black → 180°
  leg is covered by `game/puzzle_play_test.gd` and was not re-observed graphically.
- **Network deal path** not exercised (the record is injected).
- **Playtest seam controls** (the grey panel at the left edge) are visible because this is
  the seams build; they are not part of the shipped release scene.

## What this run does not decide

It does not move #333's status. It records the graphical protocols the acceptance failure
in `graphical-20261024T150000Z` asked for, on a build with all three fixes.
