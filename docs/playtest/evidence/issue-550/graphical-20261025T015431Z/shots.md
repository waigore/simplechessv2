# Screenshots — graphical run `20261025T015431Z`

Back to [`notes.md`](notes.md). Each image sits in [`screenshots/`](screenshots/).


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
