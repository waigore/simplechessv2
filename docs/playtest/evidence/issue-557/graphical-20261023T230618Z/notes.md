# Notes — #557 graphical run `20261023T230618Z`

## What was judged

The three legs the issue defines (quit/reload, crash, faulted session) plus the two `quality.md` claims they support (Reliability's recovery half, Save durability), on the published release build `a68640a`. Judgement text is in `legs.md`; readings are in `readings.md`.

## Verdict

All three legs and both quality claims are **`not-judged`**. Nothing here supports a pass: no mode pick was ever rendered, no puzzle was ever dealt, no result commit ran, and no persistence document was ever written.

## Defects

- **#630** is the sole cause of the legs stopping before their comparison: the build never leaves `EX.loading`. Already open and native-blocking #402. Per `specs/playtest/evidence.md:40`, a `not-judged` row files no per-row defect, and #630 is exactly the screen-wide cause that would be filed anyway, so this run files no duplicate.
- **#648 / #479** (with #655 as the measured instance) block the same legs for a second reason after #630 clears: no catalog route reaches the client, so no puzzle is dealt and no result is committed. Already tracked; not re-filed.
- Nothing was fixed inside this task, per its "nothing is fixed inside this task" rule.

## Blockers, read on the day of the run (2026-10-23T23:06Z)

| Item | State at run time | Effect on this run |
|---|---|---|
| #510 published URL | **cleared** — HTTP 200, deploying `a68640a` | the shipped build exists; the run is not waiting |
| #333 puzzle screen and mode-pick entry | `status:pending-verification`; `puzzle-play` and the C2 entry are on `main` | the screen exists; the build cannot reach it because of #630 |
| #630 shipped release stuck on loading | open, `blocked_by` #647 | every leg `not-judged` |
| #648 / #479 catalog `T9`/`T10` | `status:pending-clarification` | no puzzle dealt → no commit → legs 1–2 unobservable, leg 3 untriggerable |

## What this run is evidence of

A real shipped-build reading on the release the wave-4 gate measures: on `a68640a` the durability requirements of `quality.md` cannot be judged because no board is reachable. It is the same build #402's record measured (`issue-402/graphical-20261024T011500Z`); the `not-judged` outcomes agree, and this run adds per-leg document and screen reads for the durability rows.

## Not done deliberately

- **No local `Web Release` export substituted into the record** — the seam build and the release build never stand in for one another.
- **No change to `specs/`, `game/`, `asset_catalog/` or `game_assets/`.**
- **No guessed pass** — a leg that could not reach its comparison is `not-judged`, never `pass`.
- **No fabricated session id** — the release export carries no `TEL.3` id (ADR-0004 `G2`), so the deployed commit is the build identifier.
- **No re-filing of #648 / #479** — a duplicate would split one answer across three issues, which is what #655 was written to avoid.
