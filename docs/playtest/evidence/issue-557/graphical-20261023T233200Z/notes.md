# Notes — #557 durability legs, run `graphical-20261023T233200Z`

## What was judged

Nothing. The run reached the shipped build and could not judge any of the three legs, because the build never leaves `EX.loading`.

## Blocker

The shipped release's boot group cannot resolve its assets. On a clean cold open the console shows `ERROR: Error opening file 'game_assets/…'` for the boot files and then `ERROR: Preload boot left 9 approved IDs unresolved`; `game/asset_resolver.gd` returns without emitting `boot_ready`, so `SessionRouter` stays in `STAGE_LOADING` and the canvas keeps rendering "Loading…".

This is the same root cause recorded by **#630** (shipped path) and **#662** (wave-1 mirror). It is also why this task's `#510` precondition (a published URL) was necessary but not sufficient: the URL answers `200`, and the build it serves still does not reach mode pick.

## What the legs need

1. A build whose boot group resolves, so mode pick renders and `puzzle-play` can be entered.
2. A `SEQ-puzzle-result-commit` S1–S4 result, so a committed `player_elo` / `last_mode` / `recent_solved` exists to survive.
3. Then the three legs as specified, with the faulted-session leg driving the build's own `PersistStore._web_set` round-trip through the `localStorage.setItem` wrapper — not the storage layer directly, which is what a seeded mechanism check would exercise and which is why no such check is reported as a leg.

## Marks

- **Non-blocking, recorded**: the released bundle carries the asset *paths* in its `index.pck` manifest text (`251 904` bytes) while the asset files answer `404`; that is #647's route work and not this task's to judge.
- **Not filed**: no `type:defect` against **#35**. This task files for a failing leg; a leg that never ran is `not-judged`, and the blocking defect is already #630 / #662.
- **Determinism**: the clean-origin cold open reproduced the same 9-unresolved-ID line that #630's independent rerun recorded on this build.
