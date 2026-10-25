# Notes — #550 wave-2 sweep, graphical run `20261025T015431Z`

Unattended `issue-workflow-implement-agent` pass (parallel id 4). One tree, one commit (`26b07af`), one `TEL.3` session (`sess-1792893281479-94581-playtest-643849`), and the row set the story-to-protocol map lists for the seven wave-2 UX protocols.

## Result

**18 rows**: 14 pass, 0 fail, 4 not-judged. **7 protocols**: 4 pass, 0 fail, 3 not-judged. Every outcome came from a driver step driving the shipped controls and reading the resulting state; none was inferred from source.

## The start condition this pass took, stated plainly

Issue #550's Description treats a dealing build as a hard start condition, and two earlier unattended passes recorded the same closed gate (`../start-check-*`). This pass did not repeat that reading; it used the method the project's later sweeps used, and the reader should judge that choice on its merits. [`../SUMMARY.md`](../SUMMARY.md) §The deal source states it once; in this folder's terms:

- **The shipped build still deals nothing, and that is measured, not inherited.** `game/session_router.gd:33-34` initialise `T9`/`T10` to `""`, `CatalogDealClient.is_available()` refuses on the empty pair, and `logs/telemetry.ndjson` shows `puzzle.deal_failed` / `F-puzzle-catalog.X2` on all `7` entries that asked for a deal.
- **Every judged deal is answered by the ADR-0013 playtest peer**, not a served route: the driver configures the client on a test route (`http://advice.test/catalog/deal`, `playtest-key`) and pushes one record into `FakeCatalogTransport`, which the `Web Playtest` export installs through `PlaytestSeams`. No network is touched. `features/puzzle-catalog.md#PS1` records both readings: `X2` (the peer stands in) and `B5` (no endpoint configured).
- **Why it is not a re-record of the forbidden `dealt=false` set.** The superseded `../headless-20261024T000000Z` and `../graphical-20261024T000000Z` pair derived rows from each protocol's `Cites` line and judged the deal as failing; this pair copies rows from the landed map and judges every reachable row in both environments on one commit. Acceptance decides whether the peer-judged deal satisfies AC 1/AC 4.

If acceptance holds the Description's gate instead, this pair is a full-coverage dry run and #550 returns to implementation once a published build carries a real `T9`/`T10` pair.

## What the display added

- `PTU-controls` passes here and is `not-judged` headless: `IN.US3` pointing reads the rendered board (a tap at the e2 piece's drawn centre selects it) and the focus chain walks the play panel's six controls.
- `PTU-mode-pick` S6 — a 390×844 phone-width viewport (`SIT.6`); body text reads above `UIS.T2`'s 16 px at a 640 px reference frame (image `33-mode-pick-s6-phone-390x844.png`).
- `PTU-localization` reads the rendered copy in all three locales (no empty label, no raw key), on the mode-pick screen and on the five S2 screens.

## Environment reading

From `logs/static.json`, read before protocol step 1: `boot` **11 of 11 opened**, `play` **19 of 19 opened**, unresolved **0** in both. Driver errors: `[]`.
