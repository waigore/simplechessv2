# Protocol view: UX

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../.agents/specs/rules/playtest/traceability.md).

Part of the [protocol view](protocols.md). 11 UX protocols (Headless and Graphical). **Cites** is quoted from the protocol file; **Judged rows** is what that cite covers under the [UX judge rule](../story-protocol.md).

| Protocol | **Cites** | Judged rows | `none` in namespace |
|----------|-----------|-------------|---------------------|
| [shared-session](../../ux/shared-session.md) | `J-shared-session` (N1–N2, S1–S4, B1–B2) | [`journeys/shared-session.md#US1`](../../../ux/stories/journeys/shared-session.md) — US1.1–US1.5 | — |
| [puzzle-session](../../ux/puzzle-session.md) | `J-puzzle-session` (N1–N2, S1–S2, B1) | [`journeys/puzzle-session.md#US1`](../../../ux/stories/journeys/puzzle-session.md) — US1.1–US1.3 | — |
| [mode-pick](../../ux/mode-pick.md) | `UI-mode-pick.US1` | [`screens/mode-pick.md#US1`](../../../ux/stories/screens/mode-pick.md), [`mode-pick-unavailable.md#US1`](../../../ux/stories/screens/mode-pick-unavailable.md) | — |
| [shared-setup](../../ux/shared-setup.md) | `UI-shared-setup.US1` | [`screens/shared-setup.md#US1`](../../../ux/stories/screens/shared-setup.md) | — |
| [shared-play](../../ux/shared-play.md) | `UI-shared-play.US1`, `UI-shared-play.US2`, `UI-shared-play.US3`, `UI-shared-play.US4`, `ACT-bottom-player.US1`, `ACT-top-player.US1` | [`screens/shared-play.md#US1`](../../../ux/stories/screens/shared-play.md), [`shared-play-regions.md#US2`](../../../ux/stories/screens/shared-play-regions.md), [`shared-play-choices.md#US3`](../../../ux/stories/screens/shared-play-choices.md), [`shared-play-place.md#US3`](../../../ux/stories/screens/shared-play-place.md), [`shared-play-unavailable.md#US4`](../../../ux/stories/screens/shared-play-unavailable.md), [`actors/bottom-player.md#US1`](../../../ux/stories/actors/bottom-player.md), [`actors/top-player.md#US1`](../../../ux/stories/actors/top-player.md) | — |
| [shared-result](../../ux/shared-result.md) | `UI-shared-result.US1` | [`screens/shared-result.md#US1`](../../../ux/stories/screens/shared-result.md) | — |
| [puzzle-play](../../ux/puzzle-play.md) | `UI-puzzle-play.US1`, `UI-puzzle-play.US2`, `UI-puzzle-play.US3`, `UI-puzzle-play.US5` | [`screens/puzzle-play.md#US1`](../../../ux/stories/screens/puzzle-play.md), [`puzzle-play-regions.md#US2`](../../../ux/stories/screens/puzzle-play-regions.md), [`puzzle-play-choices.md#US3`](../../../ux/stories/screens/puzzle-play-choices.md), [`puzzle-play-place.md#US3`](../../../ux/stories/screens/puzzle-play-place.md), [`puzzle-play-confirm.md#US5`](../../../ux/stories/screens/puzzle-play-confirm.md) | — |
| [controls](../../ux/controls.md) | `IN.US1`, `IN.US2`, `IN.US3` | [`controls.md#US1`](../../../ux/stories/controls.md), [`controls-drag.md#US2`](../../../ux/stories/controls-drag.md), [`controls-point.md#US3`](../../../ux/stories/controls-point.md) | — |
| [navigation](../../ux/navigation.md) | `NAV.US1`, `NAV.US2` | [`navigation.md#US1`](../../../ux/stories/navigation.md), [`navigation-conditions.md#US2`](../../../ux/stories/navigation-conditions.md) | — |
| [exceptions](../../ux/exceptions.md) | `EX.US1` | [`stories/exceptions.md#US1`](../../../ux/stories/exceptions.md), [`exceptions-play.md#US1`](../../../ux/stories/exceptions-play.md) (split rule) | — |
| [localization](../../ux/localization.md) | `UI-mode-pick.US1`, `LOC.US1` | [`screens/mode-pick.md#US1`](../../../ux/stories/screens/mode-pick.md), [`mode-pick-unavailable.md#US1`](../../../ux/stories/screens/mode-pick-unavailable.md), [`localization.md#US1`](../../../ux/stories/localization.md) | [`localization.md#US2`](../../../ux/stories/localization.md) — out of playtest scope ([#788](https://github.com/waigore/simplechessv2/issues/788)) |

## Notes

- **Journey protocols** judge only their journey row and reach every scenario from their Steps tables. `PTU-puzzle-session`'s **Cites** parenthetical stops at `S2` while its Steps run to `S3`; the row records the Steps set.
- **`PTU-shared-play`** cites each actor `US1` row; the actor splits belong to no protocol, so no actor row is single-cited.
- **`PTU-localization`** judges `screens/mode-pick.md#US1` through the story ID, which reaches its split file too, and leaves `LOC.US2` out of playtest scope ([story-out-of-scope.md](../story-out-of-scope.md)). Its landed **Cites** line is rule-conformant and carries no deviation note.
- **`PTU-navigation`** records the landed `NAV.US1` + `NAV.US2` line; **`PTU-exceptions`** records `EX.US1`. This map edits no protocol file.
- Every protocol in the #34, #35, and #37 gates judges at least one story row.
