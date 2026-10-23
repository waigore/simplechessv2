# Headless notes — #331

Re-ran the deal evidence on `main` at `16b34ab`. The earlier run (`headless-20261023T032243Z`, build `b8a1e81`) is left in place per the retention rule; this run supersedes it for acceptance because two of its cited facts no longer hold:

- It cited `_check_mate_in_one_mark` as the R4–R5 evidence, but that check deals `START_FEN`, where no mate exists. The verify pass of 2026-10-23 rejected it on exactly that ground. PR #526 `84cb848` added `_check_mate_in_one_accepts_recorded_mate`, `_check_mate_in_one_rejects_non_mating`, `_check_illegal_move_is_not_a_wrong_move`, and `_check_unmarked_record_is_not_armed`, and put `MATE_FEN` to use.
- It predates the R1 catalog read (PR #591 `d55836e`, #528), which changed the record shape `deal()` consumes from Lichess export keys to `SCH-puzzle-catalog` F1–F13. The deal is now exercised against a record `CatalogWireReader` validated, which is the production shape.

## Scope

`CMP-puzzle-session` R1 only: selection, the deal writes, first-move presentation, mate-in-one arming, and the two deal failures. Sequence judging past the deal, the four outcomes, Elo updates, and the commit are the stream leaf's; the screen is #333's.

## What was checked

- `DIF.Y1` selection inside ±`CFG.ELO_MATCH_RANGE` of `GS.playerElo`, preferring ids outside the last `CFG.ELO_RECENT_WINDOW` of `GS.recentSolved`.
- The `CFG.ELO_BAND_WIDEN` widen step, the allow-recent relax, and a far record still dealing rather than failing.
- First UCI move applied before presenting; `GS.solvingSide` from the presented position; `GS.requiredSequence` holding only the later moves; `GS.sequenceIndex` beginning at 0.
- `F-puzzle-catalog` R4–R5 on `MATE_FEN`: the marked record wins on its recorded mate with `END.W1` and a scored solve; a legal non-mating move is a Wrong move that resets the puzzle to the position the deal presented; a non-mating illegal move is a rejection, not a Wrong move; an unmarked record is not armed.
- `F-puzzle-catalog` X1 (one-move record) and X2 (no record / failed read) both deal nothing, keep `GS.puzzleId` none, and leave `GS.playerElo` unchanged.
- The deal consumes one `SCH-puzzle-catalog` record that `CatalogWireReader` validated, so no snapshot is parsed and no catalog bytes are bundled in the client.

## Limits

- The suite is the test file's own assertions; this run did not add probes beyond the ones already merged.
- No graphical run applies: the component is not on any screen yet. The headless smoke confirms the game still boots and reaches mode pick with the component compiled in.
- `PTD-difficulty` S3 and `PTD-puzzle-stream` S2–S6 are the Shared-game and stream leaves, not this issue.
