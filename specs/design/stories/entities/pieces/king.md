# Stories: King and castling

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/king.md`](../../../entities/pieces/king.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| I12 | King step | PS1.1 PS1.2 |
| I13 | Castling form | PS1.3 |
| I14 | Kingside squares | PS1.3 |
| I15 | Queenside squares | PS1.4 |
| I16 | King unmoved | PS1.5 |
| I17 | Rook unmoved | PS1.6 |
| I18 | Path empty | PS1.7 |
| I19 | Not in check | PS1.8 |
| I20 | Cross/end safe | PS1.9 |
| I21 | Any fail → illegal | PS1.5 |
| I22 | After castling rights | PS1.3 |

## PS1: King moves and castling

As a casual player, I castle only when all rights hold so that king safety stays orthodox.

### PS1.1: One-square king move

- **Proves**: I12

```gherkin
Given White king on e1 And e2 empty And e2 not attacked
When White moves the king e1→e2
Then the move is legal
```

### PS1.2: Into attack illegal

- **Proves**: I12

```gherkin
Given White king on e1 And e2 attacked by Black
When White attempts e1→e2
Then the move is illegal
```

### PS1.3: Kingside castling

- **Proves**: I13, I14, I22

```gherkin
Given White to move And castling rights hold for kingside
When White castles kingside
Then king is on g1 And rook from h1 is on f1 And both P4 are true
```

### PS1.4: Queenside castling

- **Proves**: I15

```gherkin
Given White to move And castling rights hold for queenside
When White castles queenside
Then king is on c1 And rook from a1 is on d1
```

### PS1.5: King moved blocks castling

- **Proves**: I16, I21

```gherkin
Given White king has P4 true And otherwise kingside looks clear
When White attempts kingside castling
Then the move is illegal
```

### PS1.6: Rook moved blocks

- **Proves**: I17

```gherkin
Given White h1 rook has P4 true And the king is unmoved
When White attempts kingside castling
Then the move is illegal
```

### PS1.7: Path blocked

- **Proves**: I18

```gherkin
Given a piece on f1 And otherwise kingside rights hold
When White attempts kingside castling
Then the move is illegal
```

### PS1.8: In check cannot castle

- **Proves**: I19

```gherkin
Given White is in check And otherwise kingside rights hold
When White attempts kingside castling
Then the move is illegal
```

### PS1.9: Crossing attacked square

- **Proves**: I20

```gherkin
Given f1 is attacked And otherwise White kingside rights hold
When White attempts kingside castling
Then the move is illegal
```
