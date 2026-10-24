# Notes — #550 start-condition check, 2026-10-25 (implement pass, parallel id 2)

- **Issue**: #550 — Run the wave-2 playtest sweep: puzzle-stream and puzzle-session protocols on one playtest build (`type:task`, `status:pending-implementation`, milestone *Wave 2 — Adaptive Puzzle stream*).
- **Build under test**: none. The run did not start.
- **Environment read on**: clean worktree of `origin/main` **`1890c29`** ("Record the #334 acceptance headless run (#803)"); Godot `4.7.2.stable.official.ed1daf0bf`.
- **Repeat count**: 1 probe leg, 1 import.

## The start condition

#550's Description makes the deal path a hard start condition, not a run-time discovery:

> Until #655 lands, this run does not start; it does not re-record the same `dealt=false` result as
> a new evidence set.

`PTD-puzzle-stream` K1 needs a dealt puzzle. Without it, K2's reset, `END.L4`'s completion deal, the
`difficulty` and `progression` rows, and the `game-state` puzzle fields have nothing to judge — which
is exactly what the superseded `../headless-20261024T000000Z/` recorded.

## Measured this pass, not inherited

- **Native `blocked_by`** for #550 → `[655]`, `blocking` → `[]`. Matches the body's `Blocked by: #655`
  line; the AC 8 equality holds.
- **The deal path still refuses at `B5`.** The unchanged #655 probe
  (`docs/playtest/evidence/issue-655/review-20261024T131647Z/probe/x655_confirm_probe.gd`) run on
  this worktree prints, twice on the shipped path:

  ```
  WARNING: puzzle stream: deal read failed (status)
       [0] refused (res://puzzle_stream.gd:97)
       [1] request (res://puzzle_stream.gd:47)
       [2] enter (res://puzzle_play_flow.gd:44)
       [3] _enter_puzzle_play (res://session_router.gd:756)
  ```

  with `TEL.4` `J-puzzle-session.S1` and then the confirm/leave legs on `TEL.3`
  `sess-1792861765537-21243-playtest-191200`. Full stdout in [`logs/x655-probe.log`](logs/x655-probe.log).
- **Nothing on the shipped path supplies `T9`/`T10`.** `git grep -n "advice_endpoint\|advice_api_key"
  origin/main -- game/` returns `session_router.gd:33-34` (initialised to `""`), `:483` (Advice
  client `configure`), `:552` (Advice availability) and `:756` (the puzzle hand-off) — plus the test
  seam `game/advice_ui_test.gd:40-41`. `CatalogDealClient` refuses before the transport, so the
  `Web Playtest` export's simulated peer cannot substitute.
- **The blockers behind it are unlanded.** #655 is open (`status:pending-verification`); #648 is open,
  `status:pending-implementation`, and still owes its one `specs/` release-status sentence. PR #806
  (#479) and PR #808 (#655 re-run) are open, not merged. #808's own `finding-479.md` records that
  #479's deliverable is the *exclusion* of client-side delivery from `specs/`, so no issue on the
  tracker currently produces a published client carrying a real `T9`/`T10` pair.

## Why no sweep was written

A sweep now would either re-record the forbidden `dealt=false` set or publish verdicts no step
reached. `not-judged` is allowed by `specs/playtest/evidence.md` for a row *no step could reach in
the environment it ran in*; it is not licence to run a sweep whose start condition is documented as
broken. AC 10 also forbids this task changing anything outside this directory to repair the cause.

## What lets the sweep start

1. A build (or a `specs/` statement) where the first catalog read resolves — that is #648 / #655
   landing a deploy-path delivery of `T9`/`T10`, or #648 committing the *catalog disabled* reading,
   which would need #550's scope restated before a run could judge it.
2. Then: rows copied from `protocols-design.md` / `protocols-ux.md`, `headless-<run-id>/` and
   `graphical-<run-id>/` written beside `../headless-20261024T000000Z/` and
   `../graphical-20261024T000000Z/`, that pair marked superseded in the summary.
