# UX Traceability

Authoring rules: [`.agents/specs/rules/ux/traceability.md`](../../.agents/specs/rules/ux/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Instant play | vision | [`screens/shared-play.md`](screens/shared-play.md), [`controls.md`](controls.md) |
| Clear board | vision | shared-play / puzzle-play board + coordinates; [`perception.md`](../view/perception.md) R7 |
| Cafe calm | vision | [`screens/mode-pick.md`](screens/mode-pick.md), journeys |
| Shared game; Puzzle stream; new run | definition | screens + [`shared-result.md`](screens/shared-result.md) Play again |
| Untimed play; timed Blitz and Rapid with time added after each move | definition | [`screens/shared-setup.md`](screens/shared-setup.md) Clock/Increment; [`screens/shared-play.md`](screens/shared-play.md) clocks |
| Optional Stockfish move advice when online and Advice On | definition | [`screens/shared-play.md`](screens/shared-play.md) Advice; [`screens/shared-setup.md`](screens/shared-setup.md); [`exceptions.md`](exceptions.md) `EX.error` |
| Web touch | definition | [`controls.md`](controls.md) bindings |
| Accessibility; Localization | quality | presentation craft; screen copy tables; [`localization.md`](localization.md) key and locale rules; mode-pick Switch locale (C4) |
| Mode pick; loops; configuration; Advice | design | navigation, screens, journeys |
| End conditions: win, draw, loss, clock expiry ([conditions.md](../design/end-conditions/conditions.md)) | design | [`screens/shared-result.md`](screens/shared-result.md); [`screens/shared-play.md`](screens/shared-play.md) clocks; [`exceptions.md`](exceptions.md) `EX.draw-offer` |
| Progression: Last mode, Player Elo, save failure ([progression.md](../design/progression.md)) | design | [`screens/mode-pick.md`](screens/mode-pick.md); [`screens/puzzle-play.md`](screens/puzzle-play.md); [`exceptions.md`](exceptions.md) `EX.save-failure` |
| PER.R1–R9; no camera controls | view | play screens; controls (no CC bindings) |
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
| Localization copy | screen copy tables; [`localization.md`](localization.md) (keys, owners, locale rules); mode-pick C4 | Applies |
| Save-failure feedback | `EX.save-failure` | Applies |
