# Stories: Piece common rules

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/common.md`](../../../entities/pieces/common.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md), [Side to move](../../../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| I1 | PS1.1 | I2 | PS1.2 |
| I35 | PS1.3 | I3 | PS1.4 |
| I4 | PS1.5 PS1.6 | I5 | PS1.7 PS1.8 |
| I6 | PS1.9 | I7 | PS1.10 |
| I8 | PS1.11 | I9 | PS1.12 |
| I10 | PS1.13 PS1.14 | I11 | PS1.15 |

## PS1: Board, capture, check, legality

As a casual player, I make only legal moves so that check and capture stay orthodox.

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
Given the board
When colors are checked
Then a1 dark And orthogonal neighbors differ
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
Given a king-capture would be next
When legality applies
Then an end condition comes first; the king is never captured
```

### PS1.7: Pawn attacks

- **Proves**: I5

```gherkin
Given White pawn e4
When attacks are listed
Then d5 and f5 yes, e5 no
```

### PS1.8: Rook ray

- **Proves**: I5

```gherkin
Given White rook a1, piece a3, a2 empty
When attacks are listed
Then a2 and a3 yes, a4 no
```

### PS1.9: Pins ignored

- **Proves**: I6

```gherkin
Given pinned White rook
When its attacks are tested
Then still attacks; knights jump; king attacks every adjacent square
```

### PS1.10: Check

- **Proves**: I7

```gherkin
Given White to move with king e1 attacked
When check is evaluated
Then White in check
```

### PS1.11: Self-check illegal

- **Proves**: I8

```gherkin
Given a move would leave White's king in check
When attempted
Then illegal
```

### PS1.12: Pseudo-legal first

- **Proves**: I9

```gherkin
Given White to move
When a move matches piece rules (castle, en passant, promotion)
Then pseudo-legal before the self-check filter
```

### PS1.13: Safe is legal

- **Proves**: I10

```gherkin
Given pseudo-legal And White's king not in check after
When legality applies
Then the move is legal
```

### PS1.14: Into check illegal

- **Proves**: I10

```gherkin
Given pseudo-legal And White's king in check after
When legality applies
Then the move is illegal
```

### PS1.15: Only side to move

- **Proves**: I11

```gherkin
Given GS.sideToMove is White
When Black attempts a move
Then GS.position is unchanged
```
