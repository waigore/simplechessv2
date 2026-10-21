# Stories: Pawn

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/pawn.md`](../../../entities/pieces/pawn.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| I28 | One forward | PS1.1 PS1.2 |
| I29 | Double step | PS1.3 PS1.4 |
| I30 | Diagonal capture | PS1.5 PS1.6 |
| I31 | En passant | PS1.7 |
| I32 | EP expires | PS1.8 |
| I33 | Promotion choice | PS1.9 PS1.10 |
| I34 | Underpromotion / order | PS1.11 |

## PS1: Pawn moves, en passant, promotion

As a casual player, I advance pawns with capture and promotion so that special moves stay correct.

### PS1.1: Single step

- **Proves**: I28

```gherkin
Given White pawn on e2 And e3 empty
When White plays e2→e3
Then the move is legal And that pawn's P4 is true
```

### PS1.2: Blocked single step

- **Proves**: I28

```gherkin
Given White pawn on e2 And e3 occupied
When White attempts e2→e3
Then the move is illegal
```

### PS1.3: Double from start

- **Proves**: I29

```gherkin
Given White pawn on e2 with P4 false And e3 and e4 empty
When White plays e2→e4
Then the move is legal And P4 is true
```

### PS1.4: No double after moved

- **Proves**: I29

```gherkin
Given White pawn on e3 with P4 true And e4 empty
When White attempts e3→e5
Then the move is illegal
```

### PS1.5: Diagonal capture

- **Proves**: I30

```gherkin
Given White pawn on e4 And Black piece on d5
When White plays e4→d5
Then the Black piece is removed
```

### PS1.6: Diagonal without capture target

- **Proves**: I30

```gherkin
Given White pawn on e4 And d5 empty
When White attempts e4→d5
Then the move is illegal
```

### PS1.7: En passant

- **Proves**: I31

```gherkin
Given Black just played d7→d5 And a White pawn sits on e5
When White immediately plays e5→d6 en passant
Then the Black pawn on d5 is removed And White's pawn is on d6
```

### PS1.8: En passant expires

- **Proves**: I32

```gherkin
Given Black just played d7→d5 creating an en passant right for White And a White pawn sits on e5
When White plays e5→e6 first
Then en passant on d6 is no longer legal
```

### PS1.9: Must promote

- **Proves**: I33

```gherkin
Given White pawn moves to e8
When the move completes
Then the pawn is replaced by Q, R, B, or N of White
```

### PS1.10: Promotion refusal

- **Proves**: I33

```gherkin
Given White pawn moves to e8
When the player chooses to stay a pawn
Then the choice is refused
```

### PS1.11: Underpromote before check eval

- **Proves**: I34

```gherkin
Given White pawn moves to e8 And the player chooses a knight
When promotion finishes
Then the new knight has moved And check is evaluated only after promotion And before Black's turn
```
