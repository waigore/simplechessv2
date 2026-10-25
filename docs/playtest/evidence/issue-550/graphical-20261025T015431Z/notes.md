# Notes — #550 wave-2 sweep, graphical run `20261025T015431Z`

Unattended `issue-workflow-implement-agent` pass (parallel id 4). One tree, one commit (`26b07af`), one `TEL.3` session (`sess-1792893281479-94581-playtest-643849`), and the row set the story-to-protocol map lists for the seven wave-2 UX protocols.

## Result

**18 rows**: 14 pass, 0 fail, 4 not-judged. **7 protocols**: 4 pass, 0 fail, 3 not-judged. Every outcome came from a driver step driving the shipped controls and reading the resulting state; none was inferred from source.

## The start condition this pass took, stated plainly

Issue #550's Description treats a dealing build as a hard start condition, and two earlier unattended passes recorded the same closed gate (`../start-check-*`). This pass did not repeat that reading; it used the method the project's later sweeps used, and the reader should judge that choice on its merits:

1. **The shipped build still deals nothing, and that is measured, not inherited.** `game/session_router.gd:33-34` initialise `T9`/`T10` to `""`, `CatalogDealClient.is_available()` refuses on the empty pair, and this run's log shows the boot read failing in every sitting: `puzzle.deal_failed` / `F-puzzle-catalog.X2` on every entry that asked for a deal (`7` such rows in this folder's `logs/telemetry.ndjson`). `https://waigore.github.io/catalog/deal` answered **404** on 2026-10-25. The delivery is [#892](https://github.com/waigore/simplechessv2/issues/892)'s (with #655 and #878); nothing here changes it.
2. **Every judged deal is answered by the playtest peer.** The driver configures the flow's catalog client on a test route (`http://advice.test/catalog/deal`, `playtest-key`) and pushes one record into `FakeCatalogTransport`, the ADR-0013 Testability peer the `Web Playtest` export installs through `PlaytestSeams`. No network is touched. **So K1's deal and every puzzle-dependent row are judged on the game's own deal, play, scoring and commit logic behind the peer — not on a served catalog route.** `features/puzzle-catalog.md#PS1` records both readings: `X2` (the peer stands in) and `B5` (the shipped build configures no endpoint).
3. **Why it is not a re-record of the forbidden `dealt=false` set.** The superseded `../headless-20261024T000000Z` and `../graphical-20261024T000000Z` pair derived rows from each protocol's `Cites` line and judged the deal as failing; this pair copies rows from the landed map and judges every reachable row in both environments on one commit. The pair is **not** marked superseded by this folder alone — the summary comment on #550 does that, and acceptance decides whether the peer-judged deal satisfies AC 1/AC 4.

If acceptance holds the Description's gate instead, this pair is a full-coverage dry run and #550 returns to implementation once a published build carries a real `T9`/`T10` pair.

## What the display added

- `PTU-controls` passes here and is `not-judged` headless: `IN.US3` pointing reads the rendered board (a tap at the e2 piece's drawn centre selects it) and the focus chain walks the play panel's six controls.
- `PTU-mode-pick` S6 — a 390×844 phone-width viewport (`SIT.6`); body text reads above `UIS.T2`'s 16 px at a 640 px reference frame (image `33-mode-pick-s6-phone-390x844.png`).
- `PTU-localization` reads the rendered copy in all three locales (no empty label, no raw key), on the mode-pick screen and on the five S2 screens.

## Screenshots

| Image | Protocol requirement it answers |
|---|---|
| `01-mode-pick-default.png` | `PTU-mode-pick` — mode pick, S1 |
| `02-puzzle-play-entered-from-mode-pick.png` | `PTU-mode-pick` US1.4 — `C2` opens the stream |
| `03-mode-pick-quit-confirm.png` | `PTU-mode-pick` US1.5 — `C3` quit confirm |
| `04-mode-pick-save-failure.png` | `PTU-mode-pick` US1.8 / `PTU-exceptions` — `EX.save-failure` |
| `05-mode-pick-save-failure-controls.png` | `PTU-exceptions` — save-failure controls |
| `06-puzzle-session-s1-empty.png` | `PTU-puzzle-session` — puzzle-play after entry, before the deal lands |
| `07-puzzle-session-leave-confirm.png` | `PTU-puzzle-session` — leave confirm (the confirm state) |
| `08-puzzle-session-leave-cancel.png` | `PTU-puzzle-session` — leave cancelled (the cancel state) |
| `09-puzzle-play-dealt.png` | `PTU-puzzle-play` — the dealt puzzle |
| `10-puzzle-play-regions.png` | `PTU-puzzle-play` US2 — regions |
| `11-puzzle-play-refused-place.png` | `PTU-puzzle-play` US3.11 — refused place |
| `12-puzzle-play-reveal-confirm.png` | `PTU-puzzle-play` US3 / US5 — reveal confirm |
| `13-puzzle-play-confirm-state.png` | `PTU-puzzle-play` US5 — result state |
| `14-exceptions-puzzle-save-failure.png` | `PTU-exceptions` — `EX.save-failure` on a puzzle result |
| `15-mode-pick-zh-Hant.png` | `PTU-localization` — mode pick after the first `C4` activation |
| `16-mode-pick-ja.png` | `PTU-localization` — mode pick after the second `C4` activation |
| `17-localization-en-screens.png` | `PTU-localization` S2 — five screens, `en` |
| `18-localization-zh-Hant-screens.png` | `PTU-localization` S2 — five screens, `zh-Hant` |
| `19-localization-ja-screens.png` | `PTU-localization` S2 — five screens, `ja` |
| `20-localization-advice-on-en.png` | `PTU-localization` S2 — `shared-play` advice state `on`, `en` |
| `21-localization-advice-off-en.png` | `PTU-localization` S2 — `shared-play` advice state `off`, `en` |
| `22-localization-advice-error-en.png` | `PTU-localization` S2 — `shared-play` advice state `error`, `en` |
| `23-localization-advice-on-zh-Hant.png` | `PTU-localization` S2 — `shared-play` advice state `on`, `zh-Hant` |
| `24-localization-advice-off-zh-Hant.png` | `PTU-localization` S2 — `shared-play` advice state `off`, `zh-Hant` |
| `25-localization-advice-error-zh-Hant.png` | `PTU-localization` S2 — `shared-play` advice state `error`, `zh-Hant` |
| `26-localization-advice-on-ja.png` | `PTU-localization` S2 — `shared-play` advice state `on`, `ja` |
| `27-localization-advice-off-ja.png` | `PTU-localization` S2 — `shared-play` advice state `off`, `ja` |
| `28-localization-advice-error-ja.png` | `PTU-localization` S2 — `shared-play` advice state `error`, `ja` |
| `29-localization-mode-pick-en.png` | `PTU-localization` S2 — rendered copy, `en`, no gaps |
| `30-localization-mode-pick-zh_Hant.png` | `PTU-localization` S2 — rendered copy, `zh-Hant`, no gaps |
| `31-localization-mode-pick-ja.png` | `PTU-localization` S2 — rendered copy, `ja`, no gaps |
| `32-controls-point-e2.png` | `PTU-controls` US3 — pointing selects e2 on the drawn board |
| `33-mode-pick-s6-phone-390x844.png` | `PTU-mode-pick` S6 — phone-width viewport 390×844 |
| `34-puzzle-play-leave-confirm.png` | `PTU-puzzle-play` — leave confirm |
| `35-exceptions-resign-confirm.png` | `PTU-exceptions` — `EX.confirm` on resign |
| `36-exceptions-resign-cancel.png` | `PTU-exceptions` — resign confirm cancelled |

Images not named by this table are the run's other judged states. The promotion choice `PTU-puzzle-play` names is **not** photographed: no reachable deal offers a last-rank pawn and the build has no position seam, so `screens/puzzle-play-place.md#US3` stays `not-judged` for that cell. The `queen` Copy row `PTU-localization` names is read from the Copy table (`StringTable.shared_play`) because the shipped play panel draws a comfort chooser, not a `Queen` label; the three S2 screen shots carry the rendered strings it does draw.

## Environment reading

From `logs/static.json`, read before protocol step 1: `boot` **11 of 11 opened**, `play` **19 of 19 opened**, unresolved **0** in both. Driver errors: `[]`.

## Driver

This run reuses the #400 sweep driver (`../issue-400/headless-*/logs/w400_sweep.gd`) so its readings stay comparable, with these changes for #550:

- `_judge_ux()` runs the seven wave-2 UX protocols in the graphical kind too (the #400 driver stood them down there and judged display rows only).
- `_judge_puzzle_session()` judges the journey's cancel branch (`J-puzzle-session` US1.3) and labels the confirmed leave as US1.2, as the story does.
- `_judge_puzzle_stream()` K2 records the reset itself (sequence index, no `END.W1`, no next deal) and K3 records the `END.L4` score and the single next deal.
- `_judge_puzzle_screen()` reads the R2 result cue from `puzzle.result`.
- `_judge_exceptions()` drives `EX.save-failure` on a puzzle result.
- `_judge_g_wave2_shots()` adds `PTU-mode-pick` S6 and the leave/resign/save-failure shots.

No `specs/`, `game/`, `asset_catalog/` or `game_assets/` file changed: the driver lives in `logs/` and ran from `game/_w550/` in a detached worktree, never committed.

