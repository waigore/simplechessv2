# Notes — #557 graphical run `20261023T230618Z`

## What was judged

The three legs the issue defines — quit/reload, crash, faulted session — plus the two `quality.md` claims they support (Reliability's recovery half, Save durability), on the published release build `a68640a`.

## Verdict

All three legs are **`not-judged`**, so both quality claims are **`not-judged`**. Nothing in this run supports a pass: no mode pick was ever rendered, no puzzle was ever dealt, no result commit ever ran, and no persistence document was ever written.

## Judgement text per leg

### Leg 1 — quit/reload

The leg needs a `SEQ-puzzle-result-commit` S1–S4 commit before the close so the committed values have something to survive. Reaching that commit needs `puzzle-play`, which needs mode pick. The build stays on `EX.loading` for the full 30 s settle, so the leg stops before it has a value. The document reads `null` both before the close and after the reopen, so the close/reopen comparison the leg is for — committed-before against observed-after — has no committed side to compare. `not-judged`. **Not a fail:** no durability behavior ran and misbehaved.

### Leg 2 — crash

The leg needs a mid-session Last-mode selection that was never committed, then a kill with no quit path. Mode pick is what carries that selection (`game/mode_pick_panel.gd`), and it never rendered, so there was no uncommitted value to abandon. The renderer was killed through CDP `Page.crash` (not the in-game quit) and the reopen read the document as `null`. The crash half of the leg was performed; the comparison half had nothing to compare. `not-judged`.

### Leg 3 — faulted session

The `localStorage.setItem` wrapper the issue names was installed for `simplechessv2.persist.v1` to throw on write, the prior document was read, then the leg tried to produce a commit to trip it. No commit path is reachable on this build, so the wrapper received no call, `PersistStore._web_set` ran no round-trip check, `EX.save-failure` (`puzzle-play` S3) never appeared, and the `G2`/`I2` prior-document-intact comparison had no write to reject. The wrapper was restored before the reopen. `not-judged`.

There is a second, independent reason this leg cannot pass even after #630: the commit it needs is a puzzle-result commit, and the shipped path sets neither `T9` nor `T10` (`game/session_router.gd:33-34`), so `CatalogDealClient.is_available()` is false and no puzzle is ever dealt (#648 / #479 own that answer; #655 measured it).

## Defects

- **#630** is the sole cause of the three legs stopping before their comparison. Filed already; it is native-blocking #402 today. Per `specs/playtest/evidence.md:40`, a `not-judged` row is not a protocol fail and files no per-row defect, and #630 is exactly the screen-wide cause that would be filed anyway. This run does **not** file a duplicate.
- **#648 / #479** (with #655 as the measured instance) block the same legs on the shipped path for a second reason after #630 clears: no catalog route reaches the client, so no puzzle is dealt and no result is committed. Also already tracked; not re-filed.
- Nothing was fixed inside this task, per its "nothing is fixed inside this task" rule.

## Blockers, read on the day of the run (2026-10-23T23:06Z)

| Item | State at run time | Effect on this run |
|---|---|---|
| #510 published URL | **cleared** — `https://waigore.github.io/simplechessv2/` answers HTTP 200, deploying `a68640a` | the shipped build exists; the run is not waiting |
| #333 puzzle screen and mode-pick entry | `status:pending-verification`; `puzzle-play` screen and C2 entry are on `main` | the screen this task needs exists; the build cannot reach it because of #630 |
| #630 shipped release stuck on loading | open, `blocked_by` #647 | every leg `not-judged`; the screen-wide cause |
| #648 / #479 catalog `T9`/`T10` | `status:pending-clarification` | no puzzle dealt → no commit → legs 1 and 2 unobservable, leg 3 untriggerable |

## What this run is evidence of

This is a real shipped-build reading, taken on the published release the wave-4 gate measures against, and it is the reading the gate needs to record: on `a68640a` the durability requirements of `quality.md` cannot be judged because no board is reachable. It is the same build #402's record measured (`issue-402/graphical-20261024T011500Z`); the `not-judged` outcomes agree, and this run adds per-leg document and screen reads for the durability rows specifically.

## Not done deliberately

- **No local `Web Release` export substituted into the record.** The issue forbids it and `specs/playtest/evidence/README.md:16` says so: the seam build and the release build never stand in for one another.
- **No change to `specs/`, `game/`, `asset_catalog/` or `game_assets/`.**
- **No guessed pass.** A leg that could not reach its comparison is `not-judged`, never `pass`.
- **No fabricated session id.** The release export carries no `TEL.3` id (ADR-0004 `G2`), so `manifest.md` records the deployed commit as the build identifier and says why.
- **No re-filing of #648 / #479.** They are the live owners of the catalog-route answer and its delivery mechanism; filing another duplicate would split one answer across three issues, which is what #655 was written to avoid.
