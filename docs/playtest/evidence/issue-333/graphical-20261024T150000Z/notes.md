# Notes — #333 graphical acceptance run

## Independence

This session wrote none of #333's code. The run was a fresh graphical `godot` session on
`origin/main` `39fb372` in this issue's own worktree, driving the shipped scene.

## How the run drove the screen

- **Mode pick and the journey** were driven through the real controls: the
  `PuzzleStream` button (`C2`), `session_router.handle_control("mode-pick", "C2")`, then
  `C5` → `ConfirmStream` / `CancelStream` on the puzzle-play panel.
- **Moves** went through `session_router.handle_input_commit()`, the same entry a board
  gesture reaches.
- **The puzzle record** was injected with `flow.session.deal([...])` (`DBG.3`), because the
  seams build's `FakeCatalogTransport` returns no outcome by default and the screen
  correctly renders its no-deal state. `game/puzzle_play_test.gd` deals the same fixtures.

## What the logic checks showed (all pass)

`logs/graphical-run.log` has 23 `CHECK PASS` lines and `FAILURES=[]`:

- `C2` exists with the `mode-pick.puzzle` copy and enters `puzzle-play` (`NAV.T2`), setting
  last mode to puzzle (`PRG.M1`).
- R2 shows `Elo 1000`; S1 is the deal state.
- A select then the mating place shows `cue_solved`; a refused place enters S5 with no wrong
  cue; confirming Abandon shows `cue_abandon`; a last-rank place enters S4 and committing
  `queen` succeeds (the R2 cue then reads `cue_solved`).
- `C5` raises S2; Cancel stays on puzzle-play, returns to S1, keeps the puzzle open, and does
  not change Elo; Confirm leaves to mode-pick.

Logic is right. The screen does not **render** right, which is exactly what a UX protocol
judges and what a headless run cannot see. Three defects, all reproduced a second time in a
separate probe session after a 30-frame wait, so none is a capture-timing artifact. Reasoning
per defect: `rendering.md`.

## Carried from verification

Verification passed #333 on code on 2026-10-24 and named the graphical re-run as acceptance
work. That re-run is this folder, and it is the gate that found these three rendering
failures — they were not observable from code or headless state alone.

## Not judged here

- `SIT.4` frame-time sampling (`PTU-puzzle-play` S4 / P3) and mode-pick load timing (`S1`).
- The network deal path: the record was injected, not fetched.
