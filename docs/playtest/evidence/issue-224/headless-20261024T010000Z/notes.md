# Notes — #224, `PTD-progression`, headless

## What was judged

`PTD-progression` S1–S4 on the shipped `main.tscn` through `SessionRouter` and `PersistStore`. The three filed fixes were each exercised against the behavior they name:

1. **Cites includes `PRG.P3`** (recent-solved cap). S1's persistence check and S2's window check both drove `GS.recentSolved` through the shipped store: the ID is appended with each solve, the list persists across a cold open, and it trims to `CFG.ELO_RECENT_WINDOW` with the newest kept last and the oldest dropped.
2. **`Z1–Z3` re-scoped to Puzzle-stream completion.** S4 no longer treats `Z*` as a Shared-game progression claim: Shared entry advances neither `PRG.A1` nor `GS.recentSolved`, which is the `PRG.F1` fact, and the completion rules gain nothing from it.
3. **No blanket Headless screenshot waiver.** This run therefore leaves its screenshot paths waiting in `manifest.md` rather than claiming exemption.

## Blockers

- **No deal on this build.** `PRG.A1` commit-after-result and `PRG.P3` append-with-`END.W1` (`PRG.M1`) need a dealt puzzle. The catalog endpoint/key (`configuration.md` B3, `T9`/`T10`) are unset here, so the stream deals nothing and those two rows are `not-judged`, matching the #550 run's record. No defect filed: it is a deployment value, tracked by #655/#648.

## Non-blocking marks

- The probe writes the persist document directly through the shipped `PersistStore` (`commit`, then a reader built on the same backend to simulate a reopen). That is the same seam `game/persist_store_test.gd` uses; it exercises the production code path, not a mock of it.
- `spec_lint` on the branch: 1 error, 1 warning, neither attributable. The error is an untracked working-tree file (`docs/playtest/evidence/issue-528/accept-528-comment.md`) from another session; the warning is the pre-existing `specs/view/glossary.md` duplicate definition. `specs/playtest/` lints clean.

## Verdict

`not-judged` for the protocol as a whole — two S1 rows await a dealt puzzle. Every other cited story passes, and nothing in the three filed fixes failed.
