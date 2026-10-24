# UX story view

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../.agents/specs/rules/playtest/traceability.md).

One row per UX story heading, per the [map index](../story-protocol.md). 34 rows over 13 indexed specs, 20 split files. The 2 journey and 9 actor rows are in [journeys-actors.md](journeys-actors.md); this file holds the other 23. Coverage level is the owning spec's row in [ux/stories.md](../../../ux/stories.md).

**Reached** is filled only where a step or Pass row names a scenario ID; otherwise the protocol judges at story level. **Unreached** appears only where a protocol's citations make the omission explicit. A row-level `none` names its linked defect; every row here is Full except the two `localization` rows (Baseline).

| Story | Protocols | Reached | Unreached |
|-------|-----------|---------|-----------|
| [`controls.md#US1`](../../../ux/stories/controls.md) | `PTU-controls` | story-level | — |
| [`controls-drag.md#US2`](../../../ux/stories/controls-drag.md) | `PTU-controls` | story-level | — |
| [`controls-point.md#US3`](../../../ux/stories/controls-point.md) | `PTU-controls` | US3.1–US3.5 | — |
| [`exceptions.md#US1`](../../../ux/stories/exceptions.md) | `PTU-exceptions` | US1.2, US1.5, US1.7 | US1.1, US1.3, US1.4, US1.6, US1.14, US1.15, US1.16 |
| [`exceptions-play.md#US1`](../../../ux/stories/exceptions-play.md) | `PTU-exceptions` | — | US1.8–US1.13, US1.17–US1.19 |
| [`localization.md#US1`](../../../ux/stories/localization.md) | `PTU-localization` | US1.2, US1.3 | US1.1 (not build-observable) |
| [`localization.md#US2`](../../../ux/stories/localization.md) | `none — LOC.US2 is out of playtest scope; judged by spec read` ([record](../story-out-of-scope.md)) | — | all | [#788](https://github.com/waigore/simplechessv2/issues/788) |
| [`navigation.md#US1`](../../../ux/stories/navigation.md) | `PTU-navigation` | story-level | — |
| [`navigation-conditions.md#US2`](../../../ux/stories/navigation-conditions.md) | `PTU-navigation` | story-level | — |
| [`screens/mode-pick.md#US1`](../../../ux/stories/screens/mode-pick.md) | `PTU-mode-pick`, `PTU-localization` | mode-pick: US1.1, US1.3, US1.4, US1.6; localization: US1.9 | localization: US1.1, US1.5, US1.7, US1.8 (no `US1.2`) |
| [`screens/mode-pick-unavailable.md#US1`](../../../ux/stories/screens/mode-pick-unavailable.md) | `PTU-mode-pick`, `PTU-localization` | mode-pick: story-level | localization: US1.10–US1.15 |
| [`screens/shared-play.md#US1`](../../../ux/stories/screens/shared-play.md) | `PTU-shared-play` | story-level | — |
| [`screens/shared-play-regions.md#US2`](../../../ux/stories/screens/shared-play-regions.md) | `PTU-shared-play` | story-level | — |
| [`screens/shared-play-choices.md#US3`](../../../ux/stories/screens/shared-play-choices.md) | `PTU-shared-play` | US3.1–US3.5, US3.7, US3.9, US3.12, US3.15, US3.17 | — |
| [`screens/shared-play-place.md#US3`](../../../ux/stories/screens/shared-play-place.md) | `PTU-shared-play` | US3.11, US3.13, US3.14, US3.16 | — |
| [`screens/shared-play-unavailable.md#US4`](../../../ux/stories/screens/shared-play-unavailable.md) | `PTU-shared-play` | US4.1–US4.13 | — |
| [`screens/shared-setup.md#US1`](../../../ux/stories/screens/shared-setup.md) | `PTU-shared-setup` | story-level | — |
| [`screens/shared-result.md#US1`](../../../ux/stories/screens/shared-result.md) | `PTU-shared-result` | story-level | — |
| [`screens/puzzle-play.md#US1`](../../../ux/stories/screens/puzzle-play.md) | `PTU-puzzle-play` | story-level | — |
| [`screens/puzzle-play-choices.md#US3`](../../../ux/stories/screens/puzzle-play-choices.md) | `PTU-puzzle-play` | US3.1, US3.2, US3.5–US3.12 | — |
| [`screens/puzzle-play-regions.md#US2`](../../../ux/stories/screens/puzzle-play-regions.md) | `PTU-puzzle-play` | US2.1–US2.9 | — |
| [`screens/puzzle-play-place.md#US3`](../../../ux/stories/screens/puzzle-play-place.md) | `PTU-puzzle-play` | US3.3, US3.4, US3.16 | — |
| [`screens/puzzle-play-confirm.md#US5`](../../../ux/stories/screens/puzzle-play-confirm.md) | `PTU-puzzle-play` | story-level | — |

## Notes

- **Split resolution**: `UI-mode-pick.US1` reaches both `screens/mode-pick.md#US1` and `screens/mode-pick-unavailable.md#US1`; `EX.US1` reaches `exceptions.md#US1` and `exceptions-play.md#US1`; the two `US3` splits likewise.
- **`exceptions` reached set** comes from the landed step/Pass-row cites, not its **Cites**: S1 → `EX.US1.5`; S3 → `EX.US1.7`, `EX.US1.2`. S2 (illegal move) names no scenario heading; that gap is recorded, not filled.
- **`screens/mode-pick.md#US1`** has eight scenario headings; there is no `US1.2`.
- 23 non-journey rows here: 22 judged, 1 row-level `none` (`localization.md#US2`). The 2 journey and 9 actor rows are in [journeys-actors.md](journeys-actors.md), all 11 judged, so the UX set is 33 judged of 34. Scenario-cell `none` counts separately.
