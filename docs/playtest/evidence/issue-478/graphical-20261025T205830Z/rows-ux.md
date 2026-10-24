# Story rows — ux — graphical run

Rows from `traceability/story-protocol/protocols.md` at `d34050f`; outcomes from
this run's `results.json`. Manifest: [manifest.md](manifest.md).

## Story rows

| Story row | Protocol | Outcome | Why | Screenshot |
|---|---|---|---|---|
| `journeys/shared-session.md#US1` | `PTU-shared-session` | pass | all scenario checks pass | 06–16 |
| `screens/mode-pick.md#US1` | `PTU-mode-pick` | pass | all scenario checks pass | 01, 03–05, 24–25 |
| `screens/mode-pick-unavailable.md#US1` | `PTU-mode-pick` | fail | **#846** — US1.10, US1.11, US1.13: C1/C2 leave mode pick and C4 switches locale while S3 is up | 03 |
| `screens/shared-setup.md#US1` | `PTU-shared-setup` | pass | all scenario checks pass | 06–08 |
| `screens/shared-play.md#US1` | `PTU-shared-play` | pass | all scenario checks pass | 09–11 |
| `screens/shared-play-regions.md#US2` | `PTU-shared-play` | pass | all scenario checks pass | 09–14 |
| `screens/shared-play-choices.md#US3` | `PTU-shared-play` | pass | all scenario checks pass | 09, 12, 13, 14 |
| `screens/shared-play-place.md#US3` | `PTU-shared-play` | not-judged | US3.13 promotion-shown and US3.14 lapsed offer need a last-rank pawn | 11, 14 |
| `screens/shared-play-unavailable.md#US4` | `PTU-shared-play` | not-judged | US4.9/4.10 need S4 (promotion) | 09, 13 |
| `actors/bottom-player.md#US1` | `PTU-shared-play` | pass | all scenario checks pass | 11 |
| `actors/top-player.md#US1` | `PTU-shared-play` | pass | all scenario checks pass | 14 |
| `screens/shared-result.md#US1` | `PTU-shared-result` | pass | all scenario checks pass | 15–16 |
| `controls.md#US1` | `PTU-controls` | pass | all scenario checks pass | — |
| `controls-drag.md#US2` | `PTU-controls` | pass | all scenario checks pass | — |
| `controls-point.md#US3` | `PTU-controls` | pass | pointing needs a display | 03, 06 |
| `navigation.md#US1` | `PTU-navigation` | pass | all scenario checks pass | — |
| `navigation-conditions.md#US2` | `PTU-navigation` | pass | all scenario checks pass | — |
| `exceptions.md#US1` | `PTU-exceptions` | not-judged | US1.6 unsupported input needs a non-touch Web device | — |
| `exceptions-play.md#US1` | `PTU-exceptions` | not-judged | US1.8/1.9 promotion needs a crafted position | — |
| `screens/mode-pick.md#US1` | `PTU-localization` | pass | all scenario checks pass | 01, 03–05, 24–25 |
| `screens/mode-pick-unavailable.md#US1` | `PTU-localization` | fail | **#846** — US1.10, US1.11, US1.13: C1/C2 leave mode pick and C4 switches locale while S3 is up | 03 |
| `localization.md#US1` | `PTU-localization` | not-judged | LOC.US1.1 key names are a spec review | 24–28 |
