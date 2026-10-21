# Stories: Officers

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/officers.md`](../../../entities/pieces/officers.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| I23 | Sliding ray | PS1.1 PS1.2 |
| I24 | Queen | PS1.3 PS1.4 PS1.5 |
| I25 | Rook | PS1.6 PS1.7 |
| I26 | Bishop | PS1.8 PS1.9 |
| I27 | Knight | PS1.10 PS1.11 PS1.12 |

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

### PS1.3: Queen vertical

- **Proves**: I24

```gherkin
Given White queen on d4 And d5 empty And d6 empty
When White plays d4→d6
Then the move is legal And it is pseudo-legal under I23
```

### PS1.4: Queen horizontal

- **Proves**: I24

```gherkin
Given White queen on d4 And e4 empty And f4 empty
When White plays d4→f4
Then the move is legal And it is pseudo-legal under I23
```

### PS1.5: Queen diagonal

- **Proves**: I24

```gherkin
Given White queen on d4 And e5 empty And f6 empty
When White plays d4→f6
Then the move is legal And it is pseudo-legal under I23
```

### PS1.6: Rook orthogonal

- **Proves**: I25

```gherkin
Given White rook on a1 And clear file
When White plays a1→a4
Then the move is legal And after the move that rook's P4 is true
```

### PS1.7: Rook cannot move diagonally

- **Proves**: I25

```gherkin
Given White rook on a1 And b2 empty
When White attempts a1→b2
Then the move is illegal
```

### PS1.8: Bishop diagonal

- **Proves**: I26

```gherkin
Given White bishop on c1 And d2 empty And e3 empty
When White plays c1→e3
Then the move is legal
```

### PS1.9: Bishop cannot move non-diagonal

- **Proves**: I26

```gherkin
Given White bishop on c1 And c2 empty
When White attempts c1→c2
Then the move is illegal
```

### PS1.10: Knight jump

- **Proves**: I27

```gherkin
Given White knight on b1 And c3 empty And pieces on a2 and b2
When White plays b1→c3
Then the move is legal And intervening pieces do not block
```

### PS1.11: Knight capture

- **Proves**: I27

```gherkin
Given White knight on b1 And Black piece on c3
When White plays b1→c3
Then the Black piece is captured
```

### PS1.12: Knight cannot move non-2×1

- **Proves**: I27

```gherkin
Given White knight on b1 And b3 empty
When White attempts b1→b3
Then the move is illegal
```
