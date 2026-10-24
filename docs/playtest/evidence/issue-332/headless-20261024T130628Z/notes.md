# Notes — #332 acceptance headless run

## What was judged

Acceptance of #332 against its acceptance criteria, by replaying the in-scope Design protocol scenarios of `PTD-puzzle-stream` (K2–K4, E1), `PTD-difficulty` (DIF.Y1 stream cases) and `PTD-progression` (P1–P3, M1, F1, Z1) headlessly on the merged `main`, plus the issue's own criteria list.

Everything ran in a clean detached worktree at `origin/main` `a5b35ae` because the shared checkout carries uncommitted work from another run.

## Build and drift

The delivering PRs #533, #632 and #737 are all merged and ancestors of `a5b35ae`. The only later change touching the two delivering files is the unrelated upstream template sync #779 (`a5b35ae`), which changes no `game/` code. The session is therefore judged at the code the verifier passed at `40ec44e`/`eea5b2b`.

## Acceptance criteria

The protocol rows are in [protocols.md](protocols.md) and the criterion-by-criterion table in [criteria.md](criteria.md); every row passes.

## Scope

All five selected protocols (`PTD-puzzle-stream`, `PTD-difficulty`, `PTD-progression`, plus the `PTD-game-state` and `END` cases cited by the issue) are Design protocols, so Headless is the only required environment. No UX protocol is in scope: #332 owns no screen — the puzzle-play screen, mode-pick entry and journey are #333, and the `UI-puzzle-play` S1–S5 surface is judged once that screen exists.

## Notes on judgement

- The three earlier verification rounds — two failures on "one ending per attempt", then a pass — were checked rather than trusted. I re-ran the failing probe myself outside the unit suite: after `END.W1`, `reveal()`, `abandon()`, C3 and C4 are all refused with `{"ok": false, "reason": "settled"}`, and the in-memory and committed Elo are unchanged. The same holds after `END.L4`.
- The scenario probe is a throwaway script run against the worktree and then deleted; it is not part of the tree. Its console output is the `logs/scenario-run.log` artifact, so the run is reproducible from that file plus the in-repo unit tests.
- Coverage is measured without `gdtoolkit` on the default interpreter, so this run used a temporary venv with `gdtoolkit==4.5.0`. The threshold was met comfortably (86.4% vs 80).
- Non-blocking observations carried from review, none of which affects an acceptance criterion:
  - After `reveal()`/`abandon()` the following `advance()` drops the attempt, so `play_state().outcome` reads `none` while `last_result.end_reason` still holds `END.L5`/`END.L6`.
  - `_is_settled()`'s comment claims every ending path asks the guard, while `_settle()` does not; behaviour is safe because a completed sequence leaves the opponent to move.
  - The mate-in-one test split duplicates three fixtures across two test files to stay under the gdlint line cap.
- `GS.V1`, `GS.V3`, `GS.H1`, `END.P1` and `SCH-puzzle-attempt` still resolve unevenly in `specs/`; judged by their prose (`specs/design/end-conditions.md` P1, `L-puzzle-stream` K3). Project-wide spec gap, not a #332 shortfall.
