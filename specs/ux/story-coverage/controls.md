# UX story coverage: UI actions

Authoring rules: [`.agents/specs/rules/ux/story-coverage.md`](../../../.agents/specs/rules/ux/story-coverage.md).

Part of [`story-coverage.md`](../story-coverage.md). One row per UI action defined in [`controls.md`](../controls.md), in its order, with the scenarios proving that at least one binding on each platform the [definition](../../definition/definition.md#supported-platforms) marks primary activates it. The counted unit is the element ID; binding rows (`B*`) and focus (`F1`) are proven alongside. The rule file owns the bar.

## Every `IN.*` element

| UI action | Activating binding | Proving scenarios | Story file |
|-----------|--------------------|-------------------|------------|
| `IN.confirm` | `B4` | `US1.1` | [`stories/controls.md`](../stories/controls.md) |
| `IN.cancel` | `B5` | `US1.2` | [`stories/controls.md`](../stories/controls.md) |
| `IN.back` | `B6` | `US1.3` | [`stories/controls.md`](../stories/controls.md) |
| `IN.point` | `B7`, focus `F1` | `US3.1`–`US3.5` | [`controls-point.md`](../stories/controls-point.md) |
| `IN.activate` | `B1` | `US1.4` | [`stories/controls.md`](../stories/controls.md) |
| `IN.select` | `B2` | `US1.5` | [`stories/controls.md`](../stories/controls.md) |
| `IN.move` | `B3`, drag `B10` | `US1.6`, `US2.1` | [`stories/controls.md`](../stories/controls.md) + [`controls-drag.md`](../stories/controls-drag.md) |
| `IN.deselect` | `B8`, `B9`, drag `B11` | `US1.7`, `US1.8`, `US2.2`–`US2.4` | [`stories/controls.md`](../stories/controls.md) + [`controls-drag.md`](../stories/controls-drag.md) |

All 8 `IN.*` IDs defined in `controls.md` are proven. `IN.point` is the widest: `US3.1`–`US3.5` walk the pointer action across all five screens, so no screen state leaves it unproven.
