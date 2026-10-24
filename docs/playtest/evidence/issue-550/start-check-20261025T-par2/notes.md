# Notes — #550 start-condition check, 2026-10-25 (implement pass, parallel id 2)

- **Issue**: #550 — Run the wave-2 playtest sweep: puzzle-stream and puzzle-session protocols on one
  playtest build (`type:task`, `status:pending-implementation`, milestone *Wave 2 — Adaptive Puzzle
  stream*).
- **Build under test**: none. The sweep did not start.
- **Measured on**: `origin/main` **`2e34ee7`** ("Record the #655 re-run on ce8a156 (impl9)"), in a
  clean worktree with no working-tree edits, Godot `4.7.2.stable.official.ed1daf0bf`.
- **Repeat count**: 1 import, 1 probe leg (two deal attempts on the shipped path).

## The start condition, as the issue states it

#550's Description makes the deal path a hard start condition rather than a run-time discovery:

> Until #655 lands, this run does not start; it does not re-record the same `dealt=false` result as
> a new evidence set.

`PTD-puzzle-stream` K1 needs a dealt puzzle. Without it, K2's reset, `END.L4`'s completion deal, the
`difficulty` and `progression` rows, and the `game-state` puzzle fields have nothing to judge.

## Measured this pass, not inherited

- **The deal path still refuses at `B5` before it reaches the transport.** The unchanged #655 probe
  (`docs/playtest/evidence/issue-655/review-20261024T131647Z/probe/x655_confirm_probe.gd`) run on
  this commit prints, twice on the shipped path:

  ```
  WARNING: puzzle stream: deal read failed (status)
       [0] refused (res://puzzle_stream.gd:97)
       [1] request (res://puzzle_stream.gd:47)
       [2] enter (res://puzzle_play_flow.gd:44)
       [3] _enter_puzzle_play (res://session_router.gd:756)
  ```

  with `TEL.3` `sess-1792865493568-44001-playtest-208249`. Full stdout in
  [`logs/x655-probe.log`](logs/x655-probe.log). The reason is `status`, not a transport, status-code,
  or body failure — the read never leaves the client, so the `Web Playtest` export's simulated peer
  cannot substitute for a real catalog route.
- **Nothing on the shipped path supplies `T9`/`T10`.** `git grep -n "advice_endpoint\|advice_api_key"
  -- game/` returns only `session_router.gd:33-34` (initialised to `""`), `:483` (the Advice client
  `configure`), `:552` (Advice availability), `:756` (the puzzle hand-off) — plus the test seam
  `game/advice_ui_test.gd:40-41`. `game/project.godot` and `game/main.tscn` carry no such value.
  This is the state #655 files and the state `specs/technical/configuration.md` B5 still describes.
- **#655 has not landed.** It is open, `status:pending-verification`, and its own latest verification
  was a fail because the record it was moved on was an unmerged PR. Its branch record also states no
  `game/` or `specs/` change is owed there: the values are #479's and #648's to deliver, and #648's
  delivery decision is still unlanded on this commit.

## Why no sweep was written

A sweep written now would take one of two forbidden shapes: re-record the `dealt=false` set that the
Description explicitly refuses, or publish `not-judged` verdicts for every puzzle-dependent row while
the already-superseded pair says the same thing. `specs/playtest/evidence.md` allows `not-judged` for
a row *no step could reach in the environment it ran in*; that is not a licence to run a sweep whose
start condition is documented as broken. #550 also confines this task's writes to
`docs/playtest/evidence/issue-550/`, so the cause cannot be repaired here.

## What lets the sweep start

1. A build where the first catalog read resolves — that is, #655's done-condition landing a
   `T9`/`T10` delivery on a `Web Playtest` export (`F-puzzle-catalog.X2` holding is not enough; the
   sweep's AC 4 needs a playable K2 reset and `END.L4` deal).
2. Then this run's two folders, `headless-<run-id>/` and `graphical-<run-id>/`, with rows copied from
   `protocols-design.md` / `protocols-ux.md`, written beside `../headless-20261024T000000Z/` and
   `../graphical-20261024T000000Z/`, with that pair marked superseded in the summary.

No dependency edge is added by this pass: #550's native `blocked_by` set was read as `[655]` on
2026-10-25, and this check confirms #655 is still the right and sufficient edge. Its body's
`Blocked by:` line is already corrected to that same set by the earlier pass.
