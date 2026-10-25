# The three rows that are not `pass`

The passing rows are in [`rows.md`](rows.md). Readings cited here are in [`readings.json`](readings.json).

## Shared play — last move: `fail` → #888

After `1.e4` the board differs from the pre-move board only by the pawn's square: no mark on `e2`,
none on `e4`. `readings.json` → `last_move_window` reports `C6` = `C7` = `C11` = 0 accent pixels on
the board in nine captures from `+0 ms` through `+1.2 s` to settled, and each of those boards is
pixel-identical to the settled one — so no transient mark was missed.

This is not `not-judged`: the board is present and readable, and a transient cue would have been
caught inside the sampled window. The cue is simply absent, which the table scores `fail`.

The signal is also unowned: no `PAL.K9` mark covers the last move and no spec in `specs/` names one
(`grep -ri "last move" specs/` finds nothing). #888 records both halves — the build paints nothing,
and #34 must place a form or stop promising the signal — and is attached under #34. It is not a
duplicate of #192 (swatch luminance), #649 (the decided `K8`/`K9` rules), or #792 (rendering the
already-decided `K9` forms, which has no last-move entry).

## Shared play — advice best-move mark and eval: `not-judged` (#505, `PER.R5`)

With `Advice On` (the release default, shown in `shared-setup-blitz.png`) the shipped client paints no
best-move mark and no eval: `shared-advice.png` is identical to a board with no advice at all. The
published release carries no advice endpoint, so the mark surface is absent rather than hue-only, and
nothing colour-only is excused by this verdict. #505 owns the posture that keeps a vendor backend out
of the release; `PER.R5` and `F-move-advice` `R4` are the rules the row would be read against on a
build that ships the route.

## Puzzle play — player's side with both colours on the board: `not-judged` (#655, `PER.R1`)

The puzzle screen opens (`Elo 1000`, Reveal and Abandon disabled, `Leave stream` live) but the board
never leaves the start position across 8 s and 4 s more, and the page console logs `puzzle stream:
deal read failed (status)`. With no puzzle dealt there is no side on the board, so the row cannot be
read. #655 owns the deal failure; #640 owns the shape half of `PER.R1`, and `PAL.K2`-adjacent side
reading is the rule this row would be judged against.
