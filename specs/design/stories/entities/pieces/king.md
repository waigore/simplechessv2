# Stories: King non-castling moves

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/king.md`](../../../entities/pieces/king.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md)

Castling: [`king-castling.md`](king-castling.md).

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| I12 | King step | PS1.1 PS1.2 PS1.3 |

## PS1: King step

As a casual player, I move the king one square so that captures and checks stay orthodox.

### PS1.1: Empty step

- **Proves**: I12

```gherkin
Given White king on e1 And e2 empty And e2 not attacked
When White moves the king e1→e2
Then the move is legal
```

### PS1.2: Capture

- **Proves**: I12

```gherkin
Given White king on e1 And Black piece on d1 And d1 not attacked
When White moves the king e1→d1
Then the move is legal And the Black piece is removed
```

### PS1.3: Into attack

- **Proves**: I12

```gherkin
Given White king on e1 And e2 attacked by Black
When White attempts e1→e2
Then the move is illegal
```
