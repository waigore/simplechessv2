# Notes — #332 acceptance headless run

## What was judged

Acceptance of #332 against its acceptance criteria, by replaying the in-scope Design protocol scenarios of `PTD-puzzle-stream` (K2–K4, E1), `PTD-difficulty` (DIF.Y1 stream cases) and `PTD-progression` (P1–P3, M1, F1, Z1) headlessly on the merged `main`, plus the issue's own Acceptance-criteria list.

Everything ran in a clean detached worktree at `origin/main` `a5b35ae` because the shared checkout carries uncommitted work from another run.

## Build and drift

The delivering PRs #533, #632 and #737 are all merged and ancestors of `a5b35ae`. The only later change touching the two delivering files is the unrelated upstream template sync #779 (`a5b35ae`), which changes no `game/` code. The session is therefore judged at the code the verifier passed at `40ec44e`/`eea5b2b`.

## Acceptance criteria, one by one

| Criterion | Result | Evidence |
|---|---|---|
| Matching Solving-side move advances the sequence; an even-step required reply plays at once for the other side | pass | `S2` row; `_check_sequences` (`logs/gdscript-tests.log`) asserts `advance=2`, `reply.from=g1`, `reply_applied` |
| A Wrong move resets to its start, sets `wrong_move_seen`/`wrongMoveOnPuzzle`, blocks W1, deals nothing, retryable until L4/L5/L6 | pass | `S7` row — same `puzzleId`, `sequence_index` 0, no deal, second wrong move accepted |
| `END.W1` only on a clean completion; `L4` after a wrong move; `L5` on reveal; `L6` on abandon; never together; each continues the stream | pass | `S2`, `S10`, `S8` rows; `_check_one_ending_per_attempt` (the property that failed verification twice) |
| Elo once per outcome per `DIF.Y1`; S=1 on W1, S=0 otherwise; first-time `CFG.ELO_START`; no cap; Puzzle Elo fixed | pass | `S2` (1000.0 → 1010.0), `S10` (1000.0 → 990.0), `DIF S1`/`S2`, `_check_elo_*` in the test log |
| No path sets `GS.playerElo` by hand | pass | `_apply_outcome` is the only assignment besides `restore()` (`game/puzzle_session.gd`) |
| On W1 `recentSolved` appends and trims to `CFG.ELO_RECENT_WINDOW`; document stays version `1`, slots F2/F4, snapshot ids only | pass | `PRG S1`/`S2` rows (23 solves → newest 20, `p3`…`p22`); commit-shape checks in the test log |
| A failed commit keeps the prior durable document, keeps in-memory values, raises the save-failure signal; stream continues | pass | acceptance probe in the scenario run: forced write failure → signal raised once, committed Elo unchanged, in-memory Elo kept |
| Leave returns to mode-pick, keeps Elo, does not score the open puzzle; re-entry deals at the committed Elo and `recentSolved` | pass | `S9` row; `PRG S1 reopen restores Elo`/`recentSolved` |
| Advice is never enabled in Puzzle stream | pass | `play_state()` reports `advice: none` before and after a move; the class has no advice write path |
| No clock runs and no shared-game ending can fire; `GS.V1`/`GS.H1` hold | pass | `play_state()` carries no clock field; no shared-ending path in the class |
| `PTD-puzzle-stream`, `PTD-difficulty`, `PTD-progression` and the `PTD-game-state` puzzle cases pass headless | pass | the three verdicts in `manifest.md`; `logs/gdscript-tests.log` |

## Notes on judgement

- The three earlier verification rounds — two failures on "one ending per attempt", then a pass — were checked rather than trusted. I re-ran the failing probe myself outside the unit suite: after `END.W1`, `reveal()`, `abandon()`, C3 and C4 are all refused with `{"ok": false, "reason": "settled"}`, and the in-memory and committed Elo are unchanged. The same holds after `END.L4`.
- The scenario probe is a throwaway script run against the worktree and then deleted; it is not part of the tree. Its console output is the `logs/scenario-run.log` artifact, so the run is reproducible from that file plus the in-repo unit tests.
- Coverage is measured without `gdtoolkit` on the default interpreter, so this run used a temporary venv with `gdtoolkit==4.5.0`. The threshold was met comfortably (86.4% vs 80).
- Non-blocking observations carried from review, none of which affects an acceptance criterion:
  - After `reveal()`/`abandon()` the following `advance()` drops the attempt, so `play_state().outcome` reads `none` while `last_result.end_reason` still holds `END.L5`/`END.L6`. The ending is reported once and no criterion depends on `outcome` after the stream continues.
  - `_is_settled()`'s comment claims every ending path asks the guard, while `_settle()` does not; behaviour is safe because a completed sequence leaves the opponent to move.
  - The mate-in-one test split duplicates three fixtures across two test files to stay under the gdlint line cap.
- `GS.V1`, `GS.V3`, `GS.H1`, `END.P1` and `SCH-puzzle-attempt` still resolve unevenly in `specs/`; as in earlier rounds the criteria were judged by their prose (`specs/design/end-conditions.md` P1, `L-puzzle-stream` K3). Project-wide spec gap, not a #332 shortfall.
