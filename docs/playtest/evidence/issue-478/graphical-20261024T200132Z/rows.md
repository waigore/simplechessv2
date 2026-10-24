# Story rows — graphical run

Rows copied from `specs/playtest/traceability/story-protocol/protocols.md`.
Outcomes from this run's `results.json`; protocol verdicts in
[manifest.md](manifest.md).

| Story row | Outcome | Why | Screenshot(s) |
|---|---|---|---|
| `journeys/shared-session.md#US1` | pass | judged | `screenshots/01-mode-pick-S1.png`, `screenshots/03-shared-setup.png`, `screenshots/04-shared-play-S1.png`, `screenshots/09-shared-result.png` |
| `screens/mode-pick.md#US1` | pass | judged | `screenshots/01-mode-pick-S1.png`, `screenshots/02-mode-pick-S3.png` |
| `screens/mode-pick-unavailable.md#US1` | pass | judged | `screenshots/01-mode-pick-S1.png`, `screenshots/02-mode-pick-S3.png` |
| `screens/shared-setup.md#US1` | pass | judged | `screenshots/03-shared-setup.png` |
| `screens/shared-play.md#US1` | pass | judged | `screenshots/04-shared-play-S1.png`, `screenshots/05-shared-play-S2-confirm.png`, `screenshots/06-shared-play-S5-reject.png`, `screenshots/07-shared-play-S4-promotion.png`, `screenshots/08-shared-play-S6-offer.png` |
| `screens/shared-play-regions.md#US2` | pass | judged | `screenshots/04-shared-play-S1.png`, `screenshots/05-shared-play-S2-confirm.png`, `screenshots/06-shared-play-S5-reject.png`, `screenshots/07-shared-play-S4-promotion.png`, `screenshots/08-shared-play-S6-offer.png` |
| `screens/shared-play-choices.md#US3` | pass | judged | `screenshots/04-shared-play-S1.png`, `screenshots/05-shared-play-S2-confirm.png`, `screenshots/06-shared-play-S5-reject.png`, `screenshots/07-shared-play-S4-promotion.png`, `screenshots/08-shared-play-S6-offer.png` |
| `screens/shared-play-place.md#US3` | pass | judged | `screenshots/04-shared-play-S1.png`, `screenshots/05-shared-play-S2-confirm.png`, `screenshots/06-shared-play-S5-reject.png`, `screenshots/07-shared-play-S4-promotion.png`, `screenshots/08-shared-play-S6-offer.png` |
| `screens/shared-play-unavailable.md#US4` | pass | judged | `screenshots/04-shared-play-S1.png`, `screenshots/05-shared-play-S2-confirm.png`, `screenshots/06-shared-play-S5-reject.png`, `screenshots/07-shared-play-S4-promotion.png`, `screenshots/08-shared-play-S6-offer.png` |
| `actors/bottom-player.md#US1` | pass | judged | `screenshots/04-shared-play-S1.png`, `screenshots/05-shared-play-S2-confirm.png`, `screenshots/06-shared-play-S5-reject.png`, `screenshots/07-shared-play-S4-promotion.png`, `screenshots/08-shared-play-S6-offer.png` |
| `actors/top-player.md#US1` | pass | judged | `screenshots/04-shared-play-S1.png`, `screenshots/05-shared-play-S2-confirm.png`, `screenshots/06-shared-play-S5-reject.png`, `screenshots/07-shared-play-S4-promotion.png`, `screenshots/08-shared-play-S6-offer.png` |
| `screens/shared-result.md#US1` | pass | judged | `screenshots/09-shared-result.png` |
| `controls.md#US1` | pass | judged | `screenshots/04-shared-play-S1.png`, `screenshots/06-shared-play-S5-reject.png` |
| `controls-drag.md#US2` | pass | judged | `screenshots/04-shared-play-S1.png`, `screenshots/06-shared-play-S5-reject.png` |
| `controls-point.md#US3` | not-judged | US3.5 is the puzzle-play screen (Wave 2), so no wave-1 step reaches it; IN.point on mode-pick C1 and the shared screens' focus chains were checked above | `screenshots/04-shared-play-S1.png`, `screenshots/06-shared-play-S5-reject.png` |
| `navigation.md#US1` | pass | judged | `screenshots/01-mode-pick-S1.png`, `screenshots/03-shared-setup.png`, `screenshots/04-shared-play-S1.png`, `screenshots/09-shared-result.png` |
| `navigation-conditions.md#US2` | pass | judged | `screenshots/01-mode-pick-S1.png`, `screenshots/03-shared-setup.png`, `screenshots/04-shared-play-S1.png`, `screenshots/09-shared-result.png` |
| `stories/exceptions.md#US1` | pass | judged | `screenshots/05-shared-play-S2-confirm.png`, `screenshots/06-shared-play-S5-reject.png`, `screenshots/07-shared-play-S4-promotion.png`, `screenshots/08-shared-play-S6-offer.png` |
| `exceptions-play.md#US1` | pass | judged | `screenshots/05-shared-play-S2-confirm.png`, `screenshots/06-shared-play-S5-reject.png`, `screenshots/07-shared-play-S4-promotion.png`, `screenshots/08-shared-play-S6-offer.png` |
| `screens/mode-pick.md#US1` | pass | judged | `screenshots/10-mode-pick-zh-Hant.png`, `screenshots/11-mode-pick-ja.png` |
| `screens/mode-pick-unavailable.md#US1` | pass | judged | `screenshots/10-mode-pick-zh-Hant.png`, `screenshots/11-mode-pick-ja.png` |
| `localization.md#US1` | not-judged | LOC.US1.1 key names are a spec review | `screenshots/10-mode-pick-zh-Hant.png`, `screenshots/11-mode-pick-ja.png` |
