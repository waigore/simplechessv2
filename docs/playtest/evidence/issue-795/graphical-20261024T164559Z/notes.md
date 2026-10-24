# Notes — #795 S4 promotion names

## What the defect was

`puzzle_play_panel.gd` wrote the four C6 names (`queen`, `rook`, `bishop`, `knight`) onto the
off-strip focus sentinels and left `PromotionRow` an empty `HBoxContainer` with no visible
child. The only text an actor saw in S4 was `Choose promotion`; the chooser itself was four
unnamed sprites on the last-rank square.

## What changed

- `PromotionRow` now holds one `Label` per C6 option (`PromoteName{Queen,Rook,Bishop,Knight}`),
  in `PuzzleSession.PROMOTE_ORDER`. `_apply_copy` already writes the same
  `StringTable.puzzle_play(kind, locale)` to both the sentinel and the name, so the sentinels
  keep their focus order and the names carry the copy the actor reads.
- The names are UIS.T2 (`UiChrome.style_label`) with `AUTOWRAP_OFF`. `style_label` turns
  word-wrap on for body copy, and a name that wrapped split mid-word (`Que/en`) — seen and
  fixed during this run, not shipped.
- R2 is a tall wrap-free strip (S1 pays 168 px because of its layout), so S4 reserves one more
  T2 line: `chrome_reserved_px(scale, "S4")` adds `s4_name_row_px`. `Presentation` starts R1 at
  `maxf(shared reserve, panel.reserve)` so the names never cover a square (`PRJ.A1`).

## Why the reserve is a second term, not a bigger constant

The names leave the strip by 2 px at 1.125 if the added line is multiplied by the text ratio a
second time: `UiChrome` sizes labels from the frame height, while the caller's `text_scale` is
a different number in a headless runner. The line keeps its own term and the strip's other
children keep the existing 168 px.

## Not reproduced: the "before" state on the fixed branch

The `#795` numbers in the issue (labels in an 18 px strip at y≈425) and the #333 rendering
report both come from `origin/main` `39fb372`, where the R2 row itself is broken: `PlayerElo`
and `ResultCue` wrap to `1×405` (#794), so the strip's children stack far below the strip and
nothing reads. R2 is `48 px` on this branch, so S4 starts clean and only the added names show
the change. The "before" frame is therefore #333's, not a re-shot one.

## How it was driven

`probe/zz_accept795_rects.gd` (copied into `game/` only for the run, then removed): `C2` through
`session_router.handle_control`, the dealt record through `flow.session.deal`, then
`handle_input_commit("g7", "g8", "")` for the last-rank place. It prints the strip, the board,
and every name's rect, then saves the frame. Run at 1280×720 and 720×1280 (`logs/s4-rects.log`).

## Not judged here

- The promotion commit itself (S6 logic), which this change does not touch.
- `PTU-puzzle-play` P3 frame time (`SIT.4`): no sample taken.
