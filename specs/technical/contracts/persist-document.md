# Contract: Persist document

Authoring rules: [`.agents/specs/rules/technical/contracts.md`](../../../.agents/specs/rules/technical/contracts.md).

- **Kind**: API — load/replace durable JSON document
- **Provider**: [`CMP-persist-store`](../components/persist-store.md)
- **Consumers**: [`CMP-session-router`](../components/session-router.md), [`CMP-puzzle-session`](../components/puzzle-session.md)
- **Serves**: Save durability; Reliability after fault
- **Informed by**: [`fields-persist`](../../design/game-state/fields-persist.md)
- **ADRs**: [ADR-0003](../../adr/decisions/0003-localstorage-persistence.md)

## Operations

| ID | Name | Input | Output / effect | When |
|----|------|-------|-----------------|------|
| O1 | load | — | [`SCH-persist-doc`](../schemata/persist-doc.md) or defaults | Cold open |
| O2 | commit | full document | Replaces stored document | After Elo / Last mode / recentSolved change |
| O3 | read_committed | — | Last successful document | Inspect without I/O |

## Events

None

## Guarantees

| ID | Guarantee |
|----|-----------|
| G1 | Successful O2 is whole-document replace |
| G2 | Failed O2 leaves prior document intact |
| G3 | O1 never blocks past cold-open budget alone dominating ≤3 s open |

## Errors

| Condition | Result |
|-----------|--------|
| Write throw / quota | Fail O2; prior intact; [`FAIL.T2`](../failures.md) |
| Corrupt / missing | Defaults per [`FAIL.T3`](../failures.md) |

## Diagram

None — three operations, no events.
