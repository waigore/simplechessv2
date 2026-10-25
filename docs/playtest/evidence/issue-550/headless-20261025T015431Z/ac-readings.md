# AC readings — headless-20261025T015431Z

Back to [`notes.md`](notes.md). One section per acceptance criterion #550 names, with the row files it rests on.

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
