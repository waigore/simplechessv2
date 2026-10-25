# Screen findings — #334 graphical run

## B1 — `shared-play` has no `queen` row on its panel (`S2` / `P4`)

`shared-play`'s Copy table names no `locale` row and `shared-play-controls.md` gives C1–C10 with no locale switch, so the panel never renders `queen` — it is the S4 chooser's C6 option (`shared-play-states.md` S4). The rendered panel is `White to move | Advice On | Resign | Offer draw`, and the same four rows in `zh-Hant` and `ja` (`04-shared-play-en.png`); the copy that is on the panel resolves correctly. The row the protocol names for `S2`/`S3` is only reachable through S4.

## B2 — the promotion chooser does not open on a last-rank pawn place (`S3` / `P5`)

Driving a legal pawn place onto the last rank (`d2–d4`, `e7–e6`, `d4–d5`, `d7–d6`, `d5–d6` onto the black pawn) is accepted and the move lands, but the panel stays S1 and no S4 chooser appears (`06-shared-play-promote-*.png`). `SharedGameSession.place()` is what raises S4, and `ChessRules._needs_promotion()` / `_promotes()` derive the rank from `_rank_index() - 48`, which on the dealt board does not mark a rank-1 destination as a promotion. The four piece rows are therefore never rendered, so `P5` cannot pass.

## B3 — the dealt Shared board is not the standard set

At run start the White pawns stand on the `a`-file where a standard set has `e`, White has its king on `e1` and queen on `d1`, Black its king on `f8` and queen on `g8`. Moves are legal against that placement, so this is how `game/` builds the Shared game, not a probe error; it leaves `S3`'s "enter Shared play and read the `queen` row" ambiguous to drive.

## B4 — the headless twin's regional-indicator finding does not reproduce

`共用對局` renders in full (`02-mode-pick-zh-Hant.png`) and the Copy table carries no flag pair.
