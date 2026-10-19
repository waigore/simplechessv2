# Stories: Piece common rules — board, capture, attack

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/common.md`](../../../entities/pieces/common.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md), [Side to move](../../../glossary.md)

Check and legality: [`common-legality.md`](common-legality.md).

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| I1 | PS1.1 | I2 | PS1.2 |
| I35 | PS1.3 | I3 | PS1.4 |
| I4 | PS1.5 PS1.6 | I5 | PS1.7 PS1.8 |
| I6 | PS1.9 | | |

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

### PS1.7: Pawn attacks

- **Proves**: I5

```gherkin
Given White pawn on e4 And a Black piece on d5
When White attempts the pawn capture e4→d5 and the step e4→e5
Then e4→d5 captures the Black piece And e5 is not attacked by that pawn
```

### PS1.8: Rook ray

- **Proves**: I5

```gherkin
Given White rook a1, a White piece a3, a2 and a4 empty
When White attempts a1→a2 and a1→a4
Then a1→a2 is legal And a1→a4 is illegal, blocked by the a3 piece
```

### PS1.9: Pins ignored

- **Proves**: I6

```gherkin
Given White king e1, White rook e2 pinned by a Black rook e8, e3 empty And a Black king e4
When Black attempts to move the king e4→e3
Then e3 is attacked by the pinned White rook: the move is illegal
```
