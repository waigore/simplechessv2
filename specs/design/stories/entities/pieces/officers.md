# Stories: Officers

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/officers.md`](../../../entities/pieces/officers.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| I23 | Sliding ray | PS1.1 PS1.2 |
| I24 | Queen | PS1.3 |
| I25 | Rook | PS1.4 PS1.5 |
| I26 | Bishop | PS1.6 |
| I27 | Knight | PS1.7 PS1.8 |

## PS1: Queen, rook, bishop, knight

As a casual player, I move officers by their rays or jumps so that blocking and capture stay clear.

### PS1.1: Slider needs clear path

- **Proves**: I23

```gherkin
Given White rook on a1 And a friendly piece on a2 And a3 empty
When White attempts a1→a3
Then the move is illegal
```

### PS1.2: Capture on destination stops

- **Proves**: I23

```gherkin
Given White rook on a1 And Black piece on a3 And a2 empty
When White plays a1→a3
Then the Black piece is captured And the rook stops on a3
```

### PS1.3: Queen any ray

- **Proves**: I24

```gherkin
Given White queen on d4 And clear paths
When queen moves vertically, horizontally, or diagonally any number of empty squares
Then each such move is pseudo-legal under I23
```

### PS1.4: Rook orthogonal

- **Proves**: I25

```gherkin
Given White rook on a1 And clear file
When White plays a1→a4
Then the move is legal And after the move that rook's P4 is true
```

### PS1.5: Rook cannot move diagonally

- **Proves**: I25

```gherkin
Given White rook on a1 And b2 empty
When White attempts a1→b2
Then the move is illegal
```

### PS1.6: Bishop diagonal

- **Proves**: I26

```gherkin
Given White bishop on c1 And d2 empty And e3 empty
When White plays c1→e3
Then the move is legal
```

### PS1.7: Knight jump

- **Proves**: I27

```gherkin
Given White knight on b1 And c3 empty And pieces on a2 and b2
When White plays b1→c3
Then the move is legal And intervening pieces do not block
```

### PS1.8: Knight capture

- **Proves**: I27

```gherkin
Given White knight on b1 And Black piece on c3
When White plays b1→c3
Then the Black piece is captured
```
