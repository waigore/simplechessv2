# UX story view

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../.agents/specs/rules/playtest/traceability.md).

One row per UX story heading, per the [map index](../story-protocol.md). 34 rows over 13 indexed specs, 20 split files. The 2 journey and 9 actor rows are in [journeys-actors.md](journeys-actors.md); this file holds the other 23. Coverage level is the owning spec's row in [ux/stories.md](../../../ux/stories.md).

**Reached** is filled only where a step or Pass row names a scenario ID; otherwise the protocol judges at story level. **Unreached** appears only where a protocol's citations make the omission explicit. A row-level `none` names its linked defect; every row here is Full except the two `localization` rows (Baseline).

| Story | Protocols | Reached | Unreached |
|-------|-----------|---------|-----------|
| [`controls.md#US1`](../../../ux/stories/controls.md) | `PTU-controls` | story-level | — |
| [`controls-drag.md#US2`](../../../ux/stories/controls-drag.md) | `PTU-controls` | story-level | — |
| [`controls-point.md#US3`](../../../ux/stories/controls-point.md) | `none — no protocol cites IN.US3` | — | all | [#701](https://github.com/waigore/simplechessv2/issues/701) |
| [`exceptions.md#US1`](../../../ux/stories/exceptions.md) | `PTU-exceptions` | US1.2, US1.5, US1.7 | US1.1, US1.3, US1.4, US1.6, US1.14, US1.15, US1.16 |
| [`exceptions-play.md#US1`](../../../ux/stories/exceptions-play.md) | `PTU-exceptions` | — | US1.8–US1.13, US1.17–US1.19 |
| [`localization.md#US1`](../../../ux/stories/localization.md) | `PTU-localization` | US1.2, US1.3 | US1.1 (not build-observable) |
| [`localization.md#US2`](../../../ux/stories/localization.md) | `none — LOC.US2 is not build-observable and no protocol cites it` | — | all | [#701](https://github.com/waigore/simplechessv2/issues/701) |
| [`navigation.md#US1`](../../../ux/stories/navigation.md) | `PTU-navigation` | story-level | — |
| [`navigation-conditions.md#US2`](../../../ux/stories/navigation-conditions.md) | `PTU-navigation` | story-level | — |
| [`screens/mode-pick.md#US1`](../../../ux/stories/screens/mode-pick.md) | `PTU-mode-pick`, `PTU-localization` | mode-pick: US1.1, US1.3, US1.4, US1.6; localization: US1.9 | localization: US1.1, US1.5, US1.7, US1.8 (no `US1.2`) |
| [`screens/mode-pick-unavailable.md#US1`](../../../ux/stories/screens/mode-pick-unavailable.md) | `PTU-mode-pick`, `PTU-localization` | mode-pick: story-level | localization: US1.10–US1.15 |
| [`screens/shared-play.md#US1`](../../../ux/stories/screens/shared-play.md) | `PTU-shared-play` | story-level | — |
| [`screens/shared-play-regions.md#US2`](../../../ux/stories/screens/shared-play-regions.md) | `PTU-shared-play` | story-level | — |
| [`screens/shared-play-choices.md#US3`](../../../ux/stories/screens/shared-play-choices.md) | `none — no protocol cites UI-shared-play.US3` | — | all | [#701](https://github.com/waigore/simplechessv2/issues/701) |
| [`screens/shared-play-place.md#US3`](../../../ux/stories/screens/shared-play-place.md) | `none — no protocol cites UI-shared-play.US3` | — | all | [#701](https://github.com/waigore/simplechessv2/issues/701) |
| [`screens/shared-play-unavailable.md#US4`](../../../ux/stories/screens/shared-play-unavailable.md) | `none — no protocol cites UI-shared-play.US4` | — | all | [#701](https://github.com/waigore/simplechessv2/issues/701) |
| [`screens/shared-setup.md#US1`](../../../ux/stories/screens/shared-setup.md) | `PTU-shared-setup` | story-level | — |
| [`screens/shared-result.md#US1`](../../../ux/stories/screens/shared-result.md) | `PTU-shared-result` | story-level | — |
| [`screens/puzzle-play.md#US1`](../../../ux/stories/screens/puzzle-play.md) | `PTU-puzzle-play` | story-level | — |
| [`screens/puzzle-play-choices.md#US3`](../../../ux/stories/screens/puzzle-play-choices.md) | `none — no protocol cites UI-puzzle-play.US3` | — | all | [#701](https://github.com/waigore/simplechessv2/issues/701) |
| [`screens/puzzle-play-regions.md#US2`](../../../ux/stories/screens/puzzle-play-regions.md) | `none — no protocol cites UI-puzzle-play.US2` | — | all | [#701](https://github.com/waigore/simplechessv2/issues/701) |
| [`screens/puzzle-play-place.md#US3`](../../../ux/stories/screens/puzzle-play-place.md) | `none — no protocol cites UI-puzzle-play.US3` | — | all | [#701](https://github.com/waigore/simplechessv2/issues/701) |
| [`screens/puzzle-play-confirm.md#US5`](../../../ux/stories/screens/puzzle-play-confirm.md) | `PTU-puzzle-play` | story-level | — |

## Notes

- **Split resolution**: `UI-mode-pick.US1` reaches both `screens/mode-pick.md#US1` and `screens/mode-pick-unavailable.md#US1`; `EX.US1` reaches both `exceptions.md#US1` and `exceptions-play.md#US1`.
- **`exceptions` reached set** comes from the landed step/Pass-row cites, not its **Cites**: S1 → `EX.US1.5`; S3 → `EX.US1.7`, `EX.US1.2`. S2 (illegal move) names no scenario heading; that gap is recorded, not filled.
- **`screens/mode-pick.md#US1`** has eight scenario headings; there is no `US1.2`.
- 32 non-journey rows: 17 judged, 15 row-level `none`. With the 2 journey rows, 19 UX rows are judged. Scenario-cell `none` is counted separately.
