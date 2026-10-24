# Headless notes — #331

Acceptance re-run on `origin/main` at `ff87566`, in a clean worktree. The two earlier runs (`headless-20261023T032243Z`, build `b8a1e81`, and `headless-20261023T162407Z`, build `16b34ab`) are left in place per the retention rule; this run is what the acceptance cites.

## Why a third run

The 2026-10-23T162407Z run was recorded before PR #620 (`a56be38`) joined the deal to the catalog service and before #591 moved `deal()` to the `SCH-puzzle-catalog` F1–F13 shape. It still tells the truth about `CMP-puzzle-session` R1, but the deal path it exercised is not the one on `main`. This run re-judges both cited protocols on the current build and adds an independent probe of every acceptance criterion.

## Scope

`CMP-puzzle-session` R1 (selection on a small array, the deal writes, first-move presentation, mate-in-one arming, the two deal failures) and `PuzzleStream` (the production deal source: one record read, one record dealt). Sequence judging past the deal, the four outcomes, Elo updates and the commit belong to the stream leaf (#332); the puzzle-play screen is #333.

## What was checked

- The suite `python3 .github/scripts/gdscript_tests.py test` — 28 headless unit tests, including `PuzzleSessionTest`, `PuzzleSessionMateTest` and `PuzzleStreamTest`.
- An acceptance probe (temporary, under `game/`, deleted before this folder was written; the tree is clean at `ff87566` per `logs/lint.log`) drove the component directly:
  - one 5-move record validated by `CatalogWireReader`: first move applied, `requiredSequence` = the four later moves in order, `puzzleId`/`puzzleElo`/`solvingSide`/`sequenceIndex` written, presented position = post-first-move position;
  - `MATE_FEN` with and without the `mateIn1` theme: the recorded mate accepted as `END.W1` with the recorded list unchanged, a legal non-mating move a Wrong move, an unmarked record not armed;
  - X1 (one-move record) and X2 (no record, and a record that fails wire validation): nothing dealt, `GS.playerElo` unchanged;
  - the test-only `DIF.Y1` selector: in-window non-recent pick, the `CFG.ELO_BAND_WIDEN` widen, and `CFG.ELO_MATCH_RANGE` = 100.
- Headless smoke: boots to `TEL.4` `mode-pick`, `TEL.5` `pass`.

## Limits

- **Coverage was not measured in this run.** `gdscript_tests.py coverage` refuses to run without `gdtoolkit` in the environment, and this runner has neither the pip package nor `gdformat` on the `python3` path it invokes (only standalone `gdlint`/`gdformat` binaries are present). `gdformat --check game` (62 files unchanged) and `gdlint game` (no problems) both ran. CI `Coverage` was green on every merged PR for this issue, most recently 85.8% against the 80% threshold on #620.
- No graphical run applies: the component is not on any screen yet, and both cited protocols are `ENV.1` Headless only.
- `PTD-difficulty` S3 and `PTD-puzzle-stream` S2–S6 are the Shared-game and stream leaves, not this issue.

## Observation (not this issue, not a fail)

While probing `CMP-chess-rules` on a throwaway script, `legal_targets` returned no targets for a king in check whose escape square is attacked only by an enemy king: with `k7/1R6/1N6/8/8/7N/8/1R4K1 b`, the black king's only move is to capture the rook on `b7`, which the knight on `b6` guards, yet `attacks("white", "b7")` is false while `attacks("black", "b7")` is true — the attack test looks like it answers "does an enemy piece attack this square" rather than "does the given side attack this square" for king-adjacent squares. En passant generation is also absent. Neither affects any #331 criterion — the deal applies only the record's opening move — but they are `CMP-chess-rules` correctness questions that already have a verify note; worth a defect if untracked.
