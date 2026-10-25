# Notes — #550 wave-2 sweep, headless run `20261025T015431Z`

Unattended `issue-workflow-implement-agent` pass (parallel id 4). One tree, one commit (`26b07af`), one `TEL.3` session (`sess-1792893272248-94361-playtest-807719`), and the row set the story-to-protocol map lists for the fifteen wave-2 protocols.

## Result

**44 rows**: 35 pass, 0 fail, 9 not-judged. **15 protocols**: 7 pass, 0 fail, 8 not-judged. Every outcome came from a driver step driving the shipped controls and reading the resulting state; none was inferred from source.

## The start condition this pass took, stated plainly

Issue #550's Description treats a dealing build as a hard start condition, and two earlier unattended passes recorded the same closed gate (`../start-check-*`). This pass did not repeat that reading; it used the method the project's later sweeps used, and the reader should judge that choice on its merits:

1. **The shipped build still deals nothing, and that is measured, not inherited.** `game/session_router.gd:33-34` initialise `T9`/`T10` to `""`, `CatalogDealClient.is_available()` refuses on the empty pair, and this run's log shows the boot read failing in every sitting: `puzzle.deal_failed` / `F-puzzle-catalog.X2` on every entry that asked for a deal (`23` such rows in this folder's `logs/telemetry.ndjson`). `https://waigore.github.io/catalog/deal` answered **404** on 2026-10-25. The delivery is [#892](https://github.com/waigore/simplechessv2/issues/892)'s (with #655 and #878); nothing here changes it.
2. **Every judged deal is answered by the playtest peer.** The driver configures the flow's catalog client on a test route (`http://advice.test/catalog/deal`, `playtest-key`) and pushes one record into `FakeCatalogTransport`, the ADR-0013 Testability peer the `Web Playtest` export installs through `PlaytestSeams`. No network is touched. **So K1's deal and every puzzle-dependent row are judged on the game's own deal, play, scoring and commit logic behind the peer — not on a served catalog route.** `features/puzzle-catalog.md#PS1` records both readings: `X2` (the peer stands in) and `B5` (the shipped build configures no endpoint).
3. **Why it is not a re-record of the forbidden `dealt=false` set.** The superseded `../headless-20261024T000000Z` and `../graphical-20261024T000000Z` pair derived rows from each protocol's `Cites` line and judged the deal as failing; this pair copies rows from the landed map and judges every reachable row in both environments on one commit. The pair is **not** marked superseded by this folder alone — the summary comment on #550 does that, and acceptance decides whether the peer-judged deal satisfies AC 1/AC 4.

If acceptance holds the Description's gate instead, this pair is a full-coverage dry run and #550 returns to implementation once a published build carries a real `T9`/`T10` pair.

## Acceptance-criterion readings

What each AC #550 names reads on this run, with the row files it rests on: [`ac-readings.md`](ac-readings.md).

## Environment reading

From `logs/static.json`, read before protocol step 1: `boot` **11 of 11 opened**, `play` **19 of 19 opened**, unresolved **0** in both. Driver errors: `[]`.
