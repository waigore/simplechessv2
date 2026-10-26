# The passing rows — what the shipped build paints and what carries each signal

Numbers are from [`readings.json`](readings.json), measured on `screenshots/`. The rows that are not
`pass` are in [`gaps.md`](gaps.md).

## Shared play

**Whose turn is active — pass.** The status region reads `White to move` / `Black to move`
(`UI-shared-play.R2`), a text label in `C9` on `C10` at 12.73:1. Nothing in it depends on hue.

**Which clock is running — pass.** The clock line reads `W 0:58 · B 1:00` and, 4 s later,
`W 0:54 · B 1:00` (`shared-turn-a.png`, `shared-turn-b.png`). The running clock is the one whose
numerals move; the `W`/`B` letters name it. Motion and letters, not colour.

**Selection — pass.** `PAL.K9`'s stated carrier: the ring on `e2`'s outer edge with the pawn still on
its square (`shared-selection.png`: `C6` on `e2`, 1314 px). The square changes state, and the change
survives simulation; the piece is neither moved nor lifted.

**Refused place — pass.** `e2` selected, place on `d7` (an enemy pawn it cannot take): a `C8` rim is
painted on `d7` alone while the ring on `e2` and the diamonds on `e3`/`e4` stay. The rim sits exactly
in `d7`'s box (312–389 × 831–908 image px, 2178 px changed against the already-selected board) and is
still a visible frame after both simulations. `PAL.K9`'s carrier is a change of square state; the rim
is one.

**Legal destinations, empty — pass.** Diamonds at the centre of `e3` and `e4` when `e2` is selected
(1568 `C11` px each), and on `f3`/`h3` for the `g1` knight. The diamond is the cue.

**Legal destinations, capture — pass.** With `e4` selected after `1.e4 f5`, the empty target `e5`
carries a diamond and the capture target `f5` carries a ring drawn around the opponent's piece.
Form plus placement: the capture ring encircles *their* piece, beside the edge ring on the mover, so
the pair is not separated by hue. (`PAL.K9` gives captures corner brackets and reserves the closed
ring for selection; #792 owns that renderer change and nothing about it is filed here.)

**Check — pass.** `2.Qh5+` puts a `Check` chip in the status region — the word in `C9` on `C10` with a
`C8` keyline — and a `C8` L-frame on the king's square `e8` (215 `C8` px). `PAL.K9`'s carrier is the
check's own indicator; the word is that indicator and survives hue removal. The keyline alone does not
(see [`contrast.md`](contrast.md)).
