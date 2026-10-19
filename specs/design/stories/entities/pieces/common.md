# Stories: Piece common rules — board, capture, placement

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/common.md`](../../../entities/pieces/common.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md), [Side to move](../../../glossary.md)

Check and legality: [`common-legality.md`](common-legality.md). Attacked squares: [`common-attack.md`](common-attack.md).

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| I1 | PS1.1 | I2 | PS1.2 PS1.10 |
| I35 | PS1.3 | I3 | PS1.4 |
| I4 | PS1.5 PS1.6 | | |

## PS1: Board, capture, attack

As a casual player, I make only legal moves so that capture and attack stay orthodox.

### PS1.1: Board form

- **Proves**: I1

```gherkin
Given any mode
When the board is set
Then 8×8, files a–h, ranks 1–8, ≤1 piece per square
```

### PS1.2: Forward

- **Proves**: I2

```gherkin
Given White pawn e2
When it steps forward
Then +rank toward Black
```

### PS1.3: Square colors

- **Proves**: I35

```gherkin
Given the orthodox board And a White pawn on e2
When White plays e2→e4
Then a1 is dark And each pair of orthogonally adjacent squares differs in color
```

### PS1.4: Capture removes

- **Proves**: I3

```gherkin
Given White knight can take Black pawn d5
When it captures
Then the Black pawn is removed same move
```

### PS1.5: Friendly square illegal

- **Proves**: I4

```gherkin
Given White piece on e4
When another White moves onto e4
Then illegal, position unchanged
```

### PS1.6: King never captured

- **Proves**: I4

```gherkin
Given a Shared game And Black to move And Black king h8 And White queen g7 And White king f6
When Black attempts any move
Then Black has no legal move And END.L1 (checkmate) applies And the king is never captured
```

### PS1.10: Black pawn forward

- **Proves**: I2

```gherkin
Given Black pawn e7
When it steps forward
Then −rank toward White
```
