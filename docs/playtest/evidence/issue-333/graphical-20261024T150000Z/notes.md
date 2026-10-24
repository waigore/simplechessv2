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
separate probe session after a 30-frame wait, so none is a capture-timing artifact.

## Defect 1 — the S2 confirm dialog paints nothing (#793)

`StreamConfirm` (and `SaveFailure`) are `visible=true`, laid out at
`(500, 220) 280×136`, with a real `StyleBoxFlat` and a visible 232×27 message label
(`logs/graphical-rects.log`). The rendered frame at that rect is byte-identical to the frame
with the dialog closed — 15 unique colours, all board pixels. A pixel probe on
`screenshots/puzzle-play-s2-leave-confirm.png` vs `puzzle-play-s2-cancelled.png` at
`(640, 244)` and `(560, 290)` returns `(232, 213, 181)` (board cream) in both, and the dialog
centre `(640, 290)` is board cream too.

Consequence: the player is asked to confirm Leave / Reveal / Abandon with an invisible prompt.
`C5` still works because the run activated the button node directly, which is not what a
player can do.

## Defect 2 — R2 wraps to one letter per line (#794)

`PlayerElo` measures `1×405` and `ResultCue` `1×48` inside a `1248×405` row
(`logs/graphical-rects.log`). `puzzle_play_panel.gd:178-185` styles both with
`UiChrome.style_label(label, true)`, and `UiChrome.style_label` (`ui_chrome.gd:147`) sets
`autowrap_mode = TextServer.AUTOWRAP_WORD_SMART` for every label without a horizontal
alignment. The text is 127 px wide at 32 px, so it wraps to one character per line.

Visible in every puzzle-play screenshot: "E / l / o / 1", and beside it "S / o / l / v / e / d"
or "A / b / a / n / d / o / n / e / d". `US2` requires these regions to be read (`AC4`), and
`cue_abandon` / `cue_solved` are unreadable.

## Defect 3 — the S4 promotion labels are a clipped 18 px strip (#795)

On S4 the chooser sprites and the board highlight render correctly, but the Q/R/B/N copy
labels are drawn in the 18 px `PuzzleStatus` strip at y≈425 and are clipped/smeared
(`screenshots/puzzle-play-s4-promotion.png`). The `PromotionRow` holds only the four
invisible 44 px sentinels (`puzzle_play_panel.gd:205-209`, `:397`), so the chooser has no
visible per-piece label; `US3` asks the actor to commit a named piece.

## Carried from verification

Verification passed #333 on code on 2026-10-24 and named the graphical re-run as acceptance
work. That re-run is this folder, and it is the gate that found these three rendering
failures — they were not observable from code or headless state alone.

## Not judged here

- `SIT.4` frame-time sampling (`PTU-puzzle-play` S4 / P3) and mode-pick load timing (`S1`).
- The network deal path: the record was injected, not fetched.
