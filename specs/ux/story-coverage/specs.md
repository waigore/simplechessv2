# UX story coverage: per-spec record

Authoring rules: [`.agents/specs/rules/ux/story-coverage.md`](../../../.agents/specs/rules/ux/story-coverage.md).

Part of [`story-coverage.md`](../story-coverage.md). One row per spec in [`stories.md`](../stories.md), in its order. Kinds are the element IDs the spec defines; the scenarios are the ones that prove them. The rule file owns the bar and every requirement by kind; this table records that the bar was met and where the proof is.

## Every indexed spec

| Spec | Level | Kinds | Story file (base, then splits) and scenarios |
|------|-------|-------|----------------------------------------------|
| [`actors/bottom-player.md`](../actors/bottom-player.md) | Full | C1–C4, K1 | [`stories/actors/bottom-player.md`](../stories/actors/bottom-player.md) `US1.1`–`US1.11`, `US5.1`, `US5.2`; [`-choices`](../stories/actors/bottom-player-choices.md) `US2.1`–`US2.10`; [`-exceptions`](../stories/actors/bottom-player-exceptions.md) `US5.1`, `US5.2`; [`-host`](../stories/actors/bottom-player-host.md) `US3.1`–`US3.8`; [`-puzzle`](../stories/actors/bottom-player-puzzle.md) `US4.1`–`US4.6` |
| [`actors/top-player.md`](../actors/top-player.md) | Full | C1–C5, K2 | [`stories/actors/top-player.md`](../stories/actors/top-player.md) `US1.1`–`US1.12`; [`-choices`](../stories/actors/top-player-choices.md) `US2.1`–`US2.10`; [`-host`](../stories/actors/top-player-host.md) `US3.1`–`US3.12`; [`-puzzle`](../stories/actors/top-player-puzzle.md) `US4.1`–`US4.6` |
| [`screens/mode-pick.md`](../screens/mode-pick.md) | Full | R1–R3, C1–C4, S1–S4 | [`stories/screens/mode-pick.md`](../stories/screens/mode-pick.md) `US1.1`–`US1.9`; [`-unavailable`](../stories/screens/mode-pick-unavailable.md) `US1.10`–`US1.15` |
| [`screens/shared-setup.md`](../screens/shared-setup.md) | Full | R1–R2, C1–C6, S1 | [`stories/screens/shared-setup.md`](../stories/screens/shared-setup.md) `US1.1`–`US1.9` |
| [`screens/shared-play.md`](../screens/shared-play.md) | Full | R1–R4, C1–C10, S1–S6 | [`stories/screens/shared-play.md`](../stories/screens/shared-play.md) `US1.1`–`US1.10`; [`-regions`](../stories/screens/shared-play-regions.md) `US2.1`–`US2.10`; [`-choices`](../stories/screens/shared-play-choices.md) `US3.1`–`US3.5`, `US3.7`, `US3.9`, `US3.12`, `US3.15`, `US3.17`; [`-place`](../stories/screens/shared-play-place.md) `US3.11`, `US3.13`, `US3.14`, `US3.16`; [`-unavailable`](../stories/screens/shared-play-unavailable.md) `US4.1`–`US4.13` |
| [`screens/shared-result.md`](../screens/shared-result.md) | Full | R1–R2, C1–C2, S1 | [`stories/screens/shared-result.md`](../stories/screens/shared-result.md) `US1.1`–`US1.3` |
| [`screens/puzzle-play.md`](../screens/puzzle-play.md) | Full | R1–R3, C1–C6, S1–S5 | [`stories/screens/puzzle-play.md`](../stories/screens/puzzle-play.md) `US1.1`–`US1.4`, `US1.8`, `US1.10`, `US1.11`; [`-regions`](../stories/screens/puzzle-play-regions.md) `US2.1`–`US2.9`; [`-choices`](../stories/screens/puzzle-play-choices.md) `US3.1`, `US3.2`, `US3.5`–`US3.12`; [`-place`](../stories/screens/puzzle-play-place.md) `US3.3`, `US3.4`, `US3.16`; [`-confirm`](../stories/screens/puzzle-play-confirm.md) `US5.1`–`US5.6` |
| [`journeys/shared-session.md`](../journeys/shared-session.md) | Full | N1–N2, S1–S4, B1–B2 | [`stories/journeys/shared-session.md`](../stories/journeys/shared-session.md) `US1.1`–`US1.5` |
| [`journeys/puzzle-session.md`](../journeys/puzzle-session.md) | Full | N1–N2, S1–S2, B1 | [`stories/journeys/puzzle-session.md`](../stories/journeys/puzzle-session.md) `US1.1`–`US1.3` |
| [`navigation.md`](../navigation.md) | Full | T1–T9, N1–N2 | [`stories/navigation.md`](../stories/navigation.md) `US1.1`–`US1.12`; [`-conditions`](../stories/navigation-conditions.md) `US2.1`, `US2.3`, `US2.4`, `US2.6`, `US2.7` |
| [`controls.md`](../controls.md) | Full | `IN.*` (8), B1–B11, F1 | [`stories/controls.md`](../stories/controls.md) `US1.1`–`US1.8`; [`-drag`](../stories/controls-drag.md) `US2.1`–`US2.4`; [`-point`](../stories/controls-point.md) `US3.1`–`US3.5`. Per-element proof: [`controls.md`](controls.md) |
| [`exceptions.md`](../exceptions.md) | Full | `EX.*` (9) | [`stories/exceptions.md`](../stories/exceptions.md) `US1.1`–`US1.7`, `US1.14`–`US1.16`; [`-play`](../stories/exceptions-play.md) `US1.8`–`US1.13`, `US1.17`–`US1.19`. Per-element proof: [`exceptions.md`](exceptions.md) |
| [`localization.md`](../localization.md) | Baseline | L1–L10 | [`stories/localization.md`](../stories/localization.md) `US1.1`–`US2.4` |

All 12 Full specs meet the rule's bar: every element ID they define appears in a **Proves** line of at least one scenario above. `localization.md` is Baseline by decision, not by gap — see [`story-coverage.md`](../story-coverage.md). `_template.md` is not a story and is not indexed.
