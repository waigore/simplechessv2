# Stories: Piece common rules — attacked squares

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/common.md`](../../../entities/pieces/common.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md), [Side to move](../../../glossary.md)

Split from [`common.md`](common.md) by logical unit; that file proves the board, capture, and placement rules.

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| I5 | PS2.1 PS2.2 PS2.3 PS2.4 | I6 | PS2.5 PS2.6 PS2.7 |

## PS2: Attacked squares

As a casual player, I see check and king safety follow attack rules so that pins and jumps resolve correctly.

### PS2.1: Pawn capture attacks

- **Proves**: I5

```gherkin
Given White pawn on e4 And a Black piece on d5
When White attempts the pawn capture e4→d5
Then e4→d5 captures the Black piece
```

### PS2.2: Pawn step does not attack

- **Proves**: I5

```gherkin
Given White pawn on e4 And e5 empty
When White's attack on e5 is tested
Then e5 is not attacked by that pawn
```

### PS2.3: Rook ray through empty

- **Proves**: I5

```gherkin
Given White rook a1, a White piece a3, a2 and a4 empty
When White attempts a1→a2
Then a1→a2 is legal
```

### PS2.4: Rook ray blocked

- **Proves**: I5

```gherkin
Given White rook a1, a White piece a3, a2 and a4 empty
When White attempts a1→a4
Then a1→a4 is illegal, blocked by the a3 piece
```

### PS2.5: Pins ignored

- **Proves**: I6

```gherkin
Given White king e1, White rook e2, Black rook e8, e3–e7 empty, Black king d4
When Black attempts to move the king d4→e3
Then e3 is attacked by the pinned White rook: the move is illegal
```

### PS2.6: Knight attacks through blockers

- **Proves**: I6

```gherkin
Given White king e1, White knight b1, pieces on a2 and b2, Black king c3
When Black is in check tested
Then c3 is attacked by the knight
```

### PS2.7: King attacks adjacent

- **Proves**: I6

```gherkin
Given White king e1, Black king d3, e2 empty
When Black attempts d3→e2
Then e2 is attacked by the White king: the move is illegal
```
