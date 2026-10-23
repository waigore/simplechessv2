# Graphical notes — #545

Same build as the headless twin (`16e197b`, deliverable `5a7541b` / PR #595). Run: `godot --path game -s res://../docs/playtest/evidence/issue-545/graphical-20261024T000000Z/probe/accept545_graphical.gd` on a macOS window driven to 720×1280; PNGs under `screenshots/`.

## Drive

Mode pick `C1` → shared set-up `C5` → shared play: `C3` (Advice), `C4` + `confirm` (resign), then the shared result. The debug stack (Pause / Resume / Inspect / Jump / Overlay / **AssertTelemetry** / SetViewport) is visible top-left in every play capture.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-shared-setup-en.png` | Shared set-up, `en`, before start. |
| `02-shared-play-s1.png` | Shared play S1: White to move, Advice On, Resign, Offer draw, full board. |
| `03-shared-play-advice.png` | After `C3`: Advice Off — the toggle operates on the rendered UI (S3). |
| `04-shared-play-resign-confirm.png` | After `C4`: resign confirm raised over the board (S3/S4). |
| `05-shared-result.png` | After confirm: shared result, "Black wins" — the resign committed, matching the emitted `shared.resign` `end` / `shared.end` `END.L2`. |

## Checks recorded in the log

- `A545G JUDGE pass` on every row; `A545G_PROBE pass`.
- `verdict=pass matched=3` for `US1` / `US1.4` / `US1.1` over this run's own buffer.
- `f3-verdict=fail` with `UI-shared-play.US9` named in `missing` — `F3` is a fail verdict, not a warning.
- `display=macOS` confirms `ENV.2`; captures are 720×1280 and render the full screen.

## Note on the capture window

The project default window is 1280×720 landscape; the first capture attempt clipped the play screen to a corner. The probe sets the window to 720×1280 before driving, and `_layout_shared_play_regions()` re-runs on each screen transition, so the captures show the complete phone-portrait layout. The captures in this folder are from the corrected run.
