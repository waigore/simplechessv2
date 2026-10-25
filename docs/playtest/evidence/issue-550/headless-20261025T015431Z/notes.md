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

## AC 4 — the K2 reset and the `END.L4` path

`loops/puzzle-stream.md#PS1` carries both, from the #549-corrected `PTD-puzzle-stream`:

- **K2** — `a7a5` against an owed `a7a6` resets the same puzzle to its start: same `puzzleId` (`w400k`), `sequenceIndex` back to `0`, `outcome` empty (`END.W1` not awarded), results count unchanged, no next deal owed, and the wrong-move cue/`puzzle.wrong` telemetry row raised. Retry is allowed.
- **K3 after the reset** — the same puzzle then completes with `END.L4`, the score is `S = 0` (Elo falls), and exactly one next deal follows.

The cell text of each of those rows is in [`rows-puzzle-stream.md`](rows-puzzle-stream.md).

## AC 6 — the states the epic scope names

- `UI-mode-pick.US1.9` (the `C4` switch into the stream) and every other `US1` scenario: `rows-mode-pick.md`; `UI-mode-pick.US1.10`–`US1.15` are `rows-mode-pick.md` too.
- `UI-puzzle-play` result cues: `screens/puzzle-play.md#US1` records the R2 cue named for the solve (`puzzle.result`); `screens/puzzle-play-confirm.md#US5` records the reveal `END.L5`, `S = 0` and the return to `S1`.
- `EX.confirm` — resign confirm shown and cancelled (`exceptions.md#US1` US1.7/US1.2), draw-offer `Cancel` on the play panel (`exceptions-play.md#US1` US1.12).
- `EX.save-failure` — a forced failed document write on a puzzle result shows `S3`, reports `committed=false`, keeps the earlier document and continues on Dismiss (`exceptions.md#US1` US1.4/US1.16; the whole-document commit carries both Player Elo and Last mode).

## AC 7 — the `S2` string pass and its copy owner

`PTU-localization` S2 lists strings on `mode-pick`, `shared-setup`, `shared-play`, `shared-result` and `puzzle-play`; its row is `LOC.US1` only. The run reads all five screens in `en`, `zh-Hant` and `ja`: every string is its Copy-table value, no raw key, and the copy differs per locale. The `shared-play` Advice strings S2 reads on an Advice state (`advice_on` / `advice_off` / `advice_error`, `shared-play-choices.md#US1.9`) are #566's copy; they render and pass, and this task edited nothing.

## Environment reading

From `logs/static.json`, read before protocol step 1: `boot` **11 of 11 opened**, `play` **19 of 19 opened**, unresolved **0** in both. Driver errors: `[]`.

