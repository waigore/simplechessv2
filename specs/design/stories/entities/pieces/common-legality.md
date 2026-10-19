# Stories: Piece common rules — check and legality

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/common.md`](../../../entities/pieces/common.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md), [Side to move](../../../glossary.md)

Split from [`common.md`](common.md) by logical unit; that file proves board, capture, and attack.

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| I7 | PS1.1 | I8 | PS1.2 |
| I9 | PS1.3 | I10 | PS1.4 PS1.5 |
| I11 | PS1.6 PS1.7 | | |

## PS1: Check and legal moves

As a casual player, I make only legal moves so that check and legality stay orthodox.

### PS1.1: Check

- **Proves**: I7

```gherkin
Given White to move with king e1 attacked
When check is evaluated
Then White in check
```

### PS1.2: Self-check illegal

- **Proves**: I8

```gherkin
Given a move would leave White's king in check
When attempted
Then illegal
```

### PS1.3: Pseudo-legal first

- **Proves**: I9

```gherkin
Given White to move And a White pawn on e5 And a Black pawn on d5 that just moved two squares
When White attempts the en passant capture e5→d6
Then the move is pseudo-legal under I9 before the self-check filter
```

### PS1.4: Safe is legal

- **Proves**: I10

```gherkin
Given pseudo-legal And White's king not in check after
When legality applies
Then the move is legal
```

### PS1.5: Into check illegal

- **Proves**: I10

```gherkin
Given pseudo-legal And White's king in check after
When legality applies
Then the move is illegal
```

### PS1.6: Only side to move

- **Proves**: I11

```gherkin
Given GS.sideToMove is White
When Black attempts a move
Then GS.position is unchanged
```

### PS1.7: Side to move moves

- **Proves**: I11

```gherkin
Given GS.sideToMove is White And a White pawn on e2
When White moves e2→e4
Then GS.position changes And GS.sideToMove becomes Black
```
