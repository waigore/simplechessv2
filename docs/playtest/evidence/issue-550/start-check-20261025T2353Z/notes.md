# Notes — #550 start-condition check, 2026-10-25T23:53Z (implement pass, parallel id 2)

- **Issue**: #550 (`type:task`, `status:pending-implementation`, milestone *Wave 2 — Adaptive Puzzle stream*).
- **Build under test**: none. The sweep did not start.
- **Measured on**: `origin/main` **`05521ca`**, detached worktree, no working-tree edits,
  Godot `4.7.2.stable.official.ed1daf0bf`.
- **Repeat count**: 1 import, 1 probe run (two deal attempts on the shipped path). The import was
  run from `game/`; it changed no project file (the only working-tree entry is this new folder).

## The start condition

#550's Description makes a dealing build a hard start condition, not a run-time discovery:

> The sweep starts when #878's pair reaches a published build and `PTD-puzzle-stream` K1 deals a
> playable puzzle — not before, and not by re-recording the `dealt=false` result.

`PTD-puzzle-stream` K1 needs a dealt puzzle. Without it, K2's reset, `END.L4`'s completion deal, the
`difficulty` and `progression` rows, and the `game-state` puzzle fields have nothing to judge.

## Measured this pass, not inherited

- **The client still refuses at `B5`.** `CatalogDealClient.is_available()` is
  `not endpoint.is_empty() and not api_key.is_empty()`
  (`game/catalog_deal_client.gd:39-40`). The unchanged #655 probe, driven through a real
  `SessionRouter` on this commit, reports:

  ```
  X655 B5 endpoint=<> key_set=false is_available=false
  X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<unconfigured>
  WARNING: puzzle stream: deal read failed (unconfigured)
       [0] refused (res://puzzle_stream.gd:100)
       [1] request (res://puzzle_stream.gd:47)
       [2] enter (res://puzzle_play_flow.gd:44)
       [3] _enter_puzzle_play (res://session_router.gd:756)
  ```

  `TEL.3` `sess-1792916348901-2503363-playtest-1969382`. Full stdout in
  [`logs/x655-probe.log`](logs/x655-probe.log). This is the same observable as the prior pass, whose
  reason string read `status`; the refusal branch is unchanged and still fires before any transport.
- **Nothing shipped supplies `T9`/`T10`.** `game/session_router.gd` still initialises
  `advice_endpoint := ""` and `advice_api_key := ""`; no shipped path calls
  `CatalogDealClient.configure` — only `puzzle_play_flow.gd:40` (fed those empty values) and the
  test seam.
- **The route is still absent.** `https://waigore.github.io/catalog/deal` answered `404` on
  2026-10-25.
- **The delivery owner has not landed.** [#878](https://github.com/waigore/simplechessv2/issues/878)
  is open in `status:pending-review` (not yet implemented), and
  [#892](https://github.com/waigore/simplechessv2/issues/892) is open in
  `status:pending-refinement`. Neither has delivered a `T9`/`T10` pair to a published build.

## Why no sweep was written

#550 confines this task's writes to `docs/playtest/evidence/issue-550/` and forbids re-recording the
`dealt=false` set, so a sweep now could only take a forbidden shape:

- re-record the `dealt=false` result the Description refuses, or
- publish `not-judged` verdicts for every puzzle-dependent row — the same content the superseded
  `20261024T000000Z` pair already carries, and not a sweep `specs/playtest/evidence.md` licenses
  while the documented start condition is closed.

Filing a `type:defect` for the deal path would also duplicate an existing owner: the cause is
[#655](https://github.com/waigore/simplechessv2/issues/655) (superseded, work moved to #892/#878).
No behavior was changed by this pass.

## What lets the sweep start

1. A published build where the first catalog read resolves — #878's `T9`/`T10` pair reaching the
   `Web Playtest` export so `PTD-puzzle-stream` K1 deals a playable puzzle.
2. Then `headless-<run-id>/` and `graphical-<run-id>/` beside the existing pairs, rows copied from
   `specs/playtest/traceability/story-protocol/protocols-design.md` and `protocols-ux.md`, with the
   `20261024T000000Z` pair marked superseded in the summary.
