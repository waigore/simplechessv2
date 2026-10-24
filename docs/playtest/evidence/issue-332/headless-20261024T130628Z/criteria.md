# Acceptance criteria — #332

Judged headlessly on `origin/main` `a5b35ae`; protocol rows are in [manifest.md](manifest.md), judgement in [notes.md](notes.md).

| Criterion | Result | Evidence |
|---|---|---|
| Matching Solving-side move advances the sequence; an even-step required reply plays at once for the other side | pass | `S2` row; `_check_sequences` (`logs/gdscript-tests.log`) asserts `advance=2`, `reply.from=g1`, `reply_applied` |
| A Wrong move resets to its start, sets `wrong_move_seen`, deals nothing, retryable until L4/L5/L6 | pass | `S7` row — same `puzzleId`, `sequence_index` 0, no deal, second wrong move accepted |
| `END.W1` only on a clean completion; `L4` after a wrong move; `L5` on reveal; `L6` on abandon; never together; each continues the stream | pass | `S2`, `S10`, `S8` rows; `_check_one_ending_per_attempt` (the property that failed verification twice) |
| Elo once per outcome per `DIF.Y1`; S=1 on W1, S=0 otherwise; first-time `CFG.ELO_START`; no cap; Puzzle Elo fixed | pass | `S2` (1000.0 → 1010.0), `S10` (1000.0 → 990.0), `DIF S1`/`S2`, `_check_elo_*` in the test log |
| No path sets `GS.playerElo` by hand | pass | `_apply_outcome` is the only assignment besides `restore()` (`game/puzzle_session.gd`) |
| On W1 `recentSolved` appends and trims to `CFG.ELO_RECENT_WINDOW`; document stays version `1`, slots F2/F4, snapshot ids only | pass | `PRG S1`/`S2` rows (23 solves → newest 20, `p3`…`p22`); commit-shape checks in the test log |
| A failed commit keeps the prior durable document, keeps in-memory values, raises the save-failure signal; stream continues | pass | acceptance probe in the scenario run: forced write failure → signal raised once, committed Elo unchanged, in-memory Elo kept |
| Leave returns to mode-pick, keeps Elo, does not score the open puzzle; re-entry deals at the committed Elo and `recentSolved` | pass | `S9` row; `PRG S1 reopen restores Elo`/`recentSolved` |
| Advice is never enabled in Puzzle stream | pass | `play_state()` reports `advice: none` before and after a move; the class has no advice write path |
| No clock runs and no shared-game ending can fire; `GS.V1`/`GS.H1` hold | pass | `play_state()` carries no clock field; no shared-ending path in the class |
| `PTD-puzzle-stream`, `PTD-difficulty`, `PTD-progression` and the `PTD-game-state` puzzle cases pass headless | pass | the three verdicts in `manifest.md`; `logs/gdscript-tests.log` |
