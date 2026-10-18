# Win and Loss Conditions

Authoring rules: [`.agents/specs/rules/design/end-conditions.md`](../../.agents/specs/rules/design/end-conditions.md).

- **Serves**: Win / lose for the shared game and the puzzle (definition player objectives).

## Units of play

| Unit | Win | Loss | Other endings |
|------|-----|------|---------------|
| Shared game | Checkmate, opponent resigns, or opponent's clock hits zero while you can checkmate | Checkmated, you resign, or your clock hits zero while they can checkmate | Stalemate, agreement, repetition, fifty-move rule, clock draw |
| Puzzle | Required sequence, with no wrong move on that puzzle | Sequence completed only after a wrong move, the solution revealed, or the puzzle abandoned | None — a wrong move does not end the puzzle |

## Conditions

[conditions.md](end-conditions/conditions.md) lists L1–L6, D1–D5, and W1.

## Precedence

- **P1**: After a move, before the other clock starts, apply L1, then D1, then D3 and D4. L3 and D5 apply only while a clock runs and no position ending has occurred. L3 if the other side can checkmate; D5 if not. L2 on resign; if the resign coincides with that side's clock hitting zero, L2 still applies — the player loses, even when the other side cannot checkmate (not D5). D2 only on accept. W1 only with no wrong move; otherwise completion is L4. L5 on reveal. L6 on abandon. W1, L4, L5, and L6 are never true together.

## Rewards and penalties

A [Shared game](glossary.md) carries nothing forward. W1, L4, L5, and L6 update [Player Elo](glossary.md) per [difficulty.md](difficulty.md). See [progression.md](progression.md).

## Experience intent

A shared-game loss is checkmate, resignation, or a clock that ran only on that side's turn. A win is one of those against the other side. A draw ends quietly. A puzzle failure still deals the next puzzle.
