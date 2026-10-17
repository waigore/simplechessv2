# UX Traceability

Authoring rules: [`.agents/specs/rules/ux/traceability.md`](../../.agents/specs/rules/ux/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Instant play | vision | [`screens/shared-play.md`](screens/shared-play.md), [`controls.md`](controls.md) |
| Clear board | vision | shared-play / puzzle-play board + coordinates; [`perception.md`](../view/perception.md) R7 |
| Cafe calm | vision | [`screens/mode-pick.md`](screens/mode-pick.md), journeys |
| Shared game; Puzzle stream; new session | definition | screens + [`shared-result.md`](screens/shared-result.md) Play again |
| Web touch | definition | [`controls.md`](controls.md) bindings |
| Accessibility; Localization | quality | presentation craft; screen copy tables |
| Mode pick; loops; configuration; Advice | design | navigation, screens, journeys |
| PER.R1–R7; no camera controls | view | play screens; controls (no CC bindings) |
| UIS interface style | aesthetics | [`presentation.md`](presentation.md) |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Actors | [`actors/`](actors/) | Applies |
| Screens | [`screens/`](screens/), [`navigation.md`](navigation.md) | Applies |
| Journeys | [`journeys/`](journeys/) | Applies |
| Navigation | [`navigation.md`](navigation.md) | Applies |
| Exception states | [`exceptions.md`](exceptions.md) | Applies — `EX.empty` N/A |
| Controls and bindings | [`controls.md`](controls.md) | Applies |
| Mockups | [`mockups/`](mockups/), [`presentation.md`](presentation.md) | Applies — depth full |
| Accessibility presentation | screens, presentation | Applies |
| Localization copy | screen copy tables | Applies |
| Save-failure feedback | `EX.save-failure` | Applies |
