# Schema: Puzzle attempt

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: entity — current puzzle deal and attempt
- **Owner**: [`CMP-puzzle-session`](../components/puzzle-session.md)
- **Serves**: Puzzle stream; W1 / L4 / L5 / L6; Elo update
- **Informed by**: [`L-puzzle-stream`](../../design/loops/puzzle-stream.md); end-conditions W1 L4 L5 L6; [DIF](../../design/difficulty.md); [`PRG`](../../design/progression.md) A1 M1
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | puzzle_id | string | yes | Puzzle catalog record id (PuzzleId) |
| F2 | required_sequence | move list | yes | Design-required line |
| F3 | played_prefix | move list | yes | Moves so far this attempt |
| F4 | wrong_move_seen | bool | yes | Blocks W1 |
| F5 | outcome | none / solved / failed_wrong / failed_reveal / abandoned | yes | Until commit; `abandoned` on L6 |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | W1 only if required sequence completed and `wrong_move_seen` is false |
| I2 | Advice never enabled while this schema is active |
| I3 | Next deal waits until outcome committed (or fail path deals next per design) |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | create | Deal next puzzle | New id + sequence; empty prefix |
| L2 | update | Legal / illegal puzzle moves | Prefix; wrong_move_seen; outcome |
| L3 | destroy | After Elo commit and next deal or leave | Drop attempt |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| [`SCH-play-state`](play-state.md) | one | Board for this puzzle |
| [`SCH-persist-doc`](persist-doc.md) | 0..1 | Elo / recentSolved after commit |

## Diagram

None — linear attempt.

## Persistence

Outcome drives [`persistence.md`](../persistence.md) M2 M4 via [`SEQ-puzzle-result-commit`](../sequences/puzzle-result-commit.md). L4, L5, and L6 (`abandoned`) commit the Elo loss ([`PRG.A1`](../../design/progression.md) / [`PRG.M1`](../../design/progression.md)); only W1 appends `GS.recentSolved` ([`SCH-persist-doc.F4`](persist-doc.md)), and abandon does not. The attempt is ephemeral.
