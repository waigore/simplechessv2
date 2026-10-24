# Story-to-protocol map

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../.agents/specs/rules/playtest/traceability.md).

Index over which protocol judges which story row. [Procedures](../procedures.md) step 2 maps an issue to story rows and step 4 judges each selected row; this map names the rows, their judging protocols, and the rows no protocol reaches.

## Rule this map applies

The row unit, the UX and design judge rules, the multi-protocol rule, and the `none` rules are owned by [`story-rows.md`](../story-rows.md). This map applies them and states no rule of its own. It records which rows exist, which protocol judges each, and the scenario cells no step reaches.

## Views

| View | Rows | Lists |
|------|------|-------|
| [UX story view](story-protocol/ux.md) | 23 | Every screen, control, navigation, and exception heading, its protocols, reached and unreached scenarios |
| [Journey and actor view](story-protocol/journeys-actors.md) | 11 | The 2 journey rows, the 9 actor rows, and how a bare journey key resolves |
| [Design story view](story-protocol/design/index.md) | 41 | Every design heading, its `Spec key`, element range, protocols |
| [Protocol view](story-protocol/protocols.md) | 24 | Each protocol and the rows it judges, split by level |

## Split rules

- **UX**: a story-ID cite reaches every file carrying that heading — `UI-mode-pick.US1` covers `screens/mode-pick.md#US1` and `screens/mode-pick-unavailable.md#US1`. No protocol cites a scenario ID today, so a scenario-level split case does not apply; one would reach only its own file.
- **Rows out of playtest scope**: `localization.md#US2` stays `none`, judged by spec read.
- **Design**: each `## PS<n>` heading is its own row, including the three splits continuing at `PS2` (`common-attack.md`, `puzzle-catalog-select.md`, `progression-mode.md`). Within `E-pieces`, [pieces.md](../../design/entities/pieces.md) assigns each `I` range to its owning split.

## Tally

| Level | Rows | Judged | `none` |
|-------|------|--------|--------|
| UX | 34 (32 non-journey + 2 journey) | 33 | 1 |
| Design | 41 | 41 | 0 |
| **Total** | **75** | **74** | **1** |

No row is `out`. Scenario-cell `none` is counted apart from row-level `none`; the one UX `none` is `localization.md#US2`, judged by spec read.

## Worked row

`stories/controls-drag.md#US2` (`IN.US2`, `US2.1`–`US2.4`, Full) → [controls](../ux/controls.md) **Cites** `IN.US2` → judged, all four scenarios reached.

## Downstream

[coverage](../coverage.md) intersects this row set with issue scope in [procedures](../procedures.md) step 3. The per-protocol story lists in the [protocol view](story-protocol/protocols.md) are what the wave sweeps copy.
