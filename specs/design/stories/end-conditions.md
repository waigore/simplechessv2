# Stories: End conditions

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`end-conditions.md`](../end-conditions.md)
- **Spec key**: `END`
- **Glossary terms**: [Shared game](../glossary.md), [Puzzle](../glossary.md), [Wrong move](../glossary.md)

Condition rows L1–L3, D1–D5: [`stories/end-conditions/conditions.md`](end-conditions/conditions.md). Puzzle rows W1, L4, L5, L6: [`stories/end-conditions/conditions-puzzle.md`](end-conditions/conditions-puzzle.md).

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| P1 | Ending precedence | PS1.1 PS1.2 |

## PS1: One ending at a time

As a casual player, I finish a game or puzzle so that exactly one ending applies.

### PS1.1: Checkmate beats stalemate

- **Proves**: P1

```gherkin
Given the side to move is in check with no legal move
When endings are checked after a move
Then END.L1 applies And END.D1 does not
```

### PS1.2: Resign beats clock draw

- **Proves**: P1

```gherkin
Given a timed game And White's clock hits zero as White resigns And Black cannot checkmate
When the coinciding endings resolve
Then END.L2 applies, White loses And END.D5 does not
```
