# UX story view: journeys and actors

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../.agents/specs/rules/playtest/traceability.md).

Part of the [UX story view](ux.md); rule: [map index](../story-protocol.md).

## Journeys — 2 rows, both judged

The only rows whose **Cites** is a bare journey key. That key judges `specs/ux/stories/journeys/<journey>.md#US1`, whose scenarios are numbered inside the `US1` heading. The **Cites** parenthetical names the protocol's own step and outcome IDs (`N<n>` normal, `S<n>` step, `B<n>` branch), never journey scenarios, so it never fixes the reached set on its own. Reached scenarios come from the protocol's **Steps** table.

| Story | Protocol | **Cites** as landed | Reached | Unreached |
|-------|----------|--------------------|---------|-----------|
| [`journeys/shared-session.md#US1`](../../../ux/stories/journeys/shared-session.md) | `PTU-shared-session` | `J-shared-session` (N1–N2, S1–S4, B1–B2) | US1.1 (S1), US1.2 (S2), US1.3 (S3), US1.4 (S4), US1.5 (S2 "End or resign") | — |
| [`journeys/puzzle-session.md#US1`](../../../ux/stories/journeys/puzzle-session.md) | `PTU-puzzle-session` | `J-puzzle-session` (N1–N2, S1–S2, B1) | US1.1 (S1), US1.2 (S2), US1.3 (S3) | — |

**`puzzle-session` note.** The **Cites** parenthetical stops at `S2` while the Steps table runs to `S3` (cancel leave). The reached set follows the Steps table; this map does not edit the **Cites** line, which belongs to that protocol. No scenario is unreached in either journey row.

## Actors — 9 rows, 9 judged

The two `US1` rows reach `PTU-shared-play`; the seven `US2`–`US5` splits are judged rows no protocol cites. `PTU-shared-play` judges the `US1` rows at story level and no actor split, so no actor row is single-cited.

| Story | Protocol | Reached | Level |
|-------|----------|---------|-------|
| [`actors/bottom-player.md#US1`](../../../ux/stories/actors/bottom-player.md) | `PTU-shared-play` | story-level | Full |
| [`actors/top-player.md#US1`](../../../ux/stories/actors/top-player.md) | `PTU-shared-play` | story-level | Full |
| [`actors/bottom-player-choices.md#US2`](../../../ux/stories/actors/bottom-player-choices.md) | no protocol cites it | US2.1–US2.10 | Full |
| [`actors/bottom-player-host.md#US3`](../../../ux/stories/actors/bottom-player-host.md) | no protocol cites it | US3.1–US3.8 | Full |
| [`actors/bottom-player-puzzle.md#US4`](../../../ux/stories/actors/bottom-player-puzzle.md) | no protocol cites it | US4.1–US4.6 | Full |
| [`actors/bottom-player-exceptions.md#US5`](../../../ux/stories/actors/bottom-player-exceptions.md) | no protocol cites it | US5.1, US5.2 | Full |
| [`actors/top-player-choices.md#US2`](../../../ux/stories/actors/top-player-choices.md) | no protocol cites it | US2.1–US2.10 | Full |
| [`actors/top-player-host.md#US3`](../../../ux/stories/actors/top-player-host.md) | no protocol cites it | US3.1–US3.12 | Full |
| [`actors/top-player-puzzle.md#US4`](../../../ux/stories/actors/top-player-puzzle.md) | no protocol cites it | US4.1–US4.6 | Full |

The seven uncited splits are not row-level `none`: their record, and the decision on an owning protocol, lives in [#865](https://github.com/waigore/simplechessv2/issues/865).
