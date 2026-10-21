# Stories: King castling

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/king.md`](../../../entities/pieces/king.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md)

Split from [`king.md`](king.md) by logical unit; that file proves I12.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| I13 | Castling form | PS1.1 |
| I14 | Kingside | PS1.1 |
| I15 | Queenside | PS1.2 |
| I16 | King unmoved | PS1.1 PS1.3 |
| I17 | Rook unmoved | PS1.1 PS1.4 |
| I18 | Path empty | PS1.1 PS1.5 |
| I19 | Not in check | PS1.1 PS1.6 |
| I20 | Cross/end safe | PS1.1 PS1.7 PS1.8 PS1.9 PS1.10 |
| I21 | Fail → illegal | PS1.3 |
| I22 | After rights | PS1.1 |

## PS1: Castling

As a casual player, I castle only when all rights hold so that king safety stays orthodox.

### PS1.1: Kingside

- **Proves**: I13, I14, I16, I17, I18, I19, I20, I22

```gherkin
Given White to move And king e1 P4 false And h1 rook P4 false
  And f1 g1 empty And not in check And f1 g1 not attacked
When White castles kingside
Then king on g1 And rook on f1 And both P4 true And that side's castling rights false
```

### PS1.2: Queenside

- **Proves**: I15

```gherkin
Given White to move And queenside castling rights hold
When White castles queenside
Then king on c1 And rook from a1 on d1
```

### PS1.3: King moved

- **Proves**: I16, I21

```gherkin
Given White king P4 true And otherwise kingside clear
When White attempts kingside castling
Then the move is illegal
```

### PS1.4: Rook moved

- **Proves**: I17

```gherkin
Given White h1 rook P4 true And king unmoved
When White attempts kingside castling
Then the move is illegal
```

### PS1.5: Path blocked

- **Proves**: I18

```gherkin
Given piece on f1 And otherwise kingside rights hold
When White attempts kingside castling
Then the move is illegal
```

### PS1.6: In check

- **Proves**: I19

```gherkin
Given White in check And otherwise kingside rights hold
When White attempts kingside castling
Then the move is illegal
```

### PS1.7: Crossing attacked

- **Proves**: I20

```gherkin
Given f1 attacked And otherwise White kingside rights hold
When White attempts kingside castling
Then the move is illegal
```

### PS1.8: Destination attacked

- **Proves**: I20

```gherkin
Given g1 attacked And otherwise White kingside rights hold
When White attempts kingside castling
Then the move is illegal
```

### PS1.9: Rook square attacked

- **Proves**: I20

```gherkin
Given h1 attacked And f1 g1 not attacked And otherwise White kingside rights hold
When White castles kingside
Then the move is legal And king on g1 And rook on f1
```

### PS1.10: Queenside b1 attacked

- **Proves**: I20

```gherkin
Given b1 attacked And otherwise White queenside rights hold
When White castles queenside
Then the move is legal And king on c1 And rook from a1 on d1
```
