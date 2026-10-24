# UX story coverage: exceptions

Authoring rules: [`.agents/specs/rules/ux/story-coverage.md`](../../../.agents/specs/rules/ux/story-coverage.md).

Part of [`story-coverage.md`](../story-coverage.md). One row per exception element defined in [`exceptions.md`](../exceptions.md), in its order, with the scenario that proves it "shown when its condition holds, recovery arrives at the named screen or state". The counted unit is the element ID; an exception's copy keys belong to [`localization.md`](../localization.md) and are not extra items. The rule file owns the bar.

## Every `EX.*` element

| Exception | Condition | Proving scenario | Story file |
|-----------|-----------|------------------|------------|
| `EX.loading` | Cold open | `US1.1` | [`stories/exceptions.md`](../stories/exceptions.md) |
| `EX.confirm` | Destructive action asked | `US1.2`, `US1.7`, `US1.14` | [`stories/exceptions.md`](../stories/exceptions.md) |
| `EX.interrupt` | Return after an interruption | `US1.3`, `US1.15` | [`stories/exceptions.md`](../stories/exceptions.md) |
| `EX.save-failure` | Store write fails | `US1.4`, `US1.16` | [`stories/exceptions.md`](../stories/exceptions.md) |
| `EX.error` | Unexpected failure | `US1.5` | [`stories/exceptions.md`](../stories/exceptions.md) |
| `EX.unsupported-input` | Non-touch device | `US1.6` | [`stories/exceptions.md`](../stories/exceptions.md) |
| `EX.promote` | Pawn reaches the last rank | `US1.8`, `US1.9` | [`stories/exceptions.md`](../stories/exceptions.md) + [`exceptions-play.md`](../stories/exceptions-play.md) |
| `EX.rejected` | Illegal drop or play | `US1.10`, `US1.11` | [`exceptions-play.md`](../stories/exceptions-play.md) |
| `EX.draw-offer` | An offer is open | `US1.12`, `US1.13`, `US1.17`–`US1.19` | [`exceptions-play.md`](../stories/exceptions-play.md) |

All 9 `EX.*` IDs defined in `exceptions.md` are proven. Where an exception is shown, the screen spec's coverage table names it too (`EX.promote` is `S4` on [`screens/shared-play.md`](../screens/shared-play.md)); this table names the proof, not the screens.
