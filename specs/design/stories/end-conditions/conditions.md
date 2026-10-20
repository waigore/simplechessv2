# Stories: Shared-game endings

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`end-conditions/conditions.md`](../../end-conditions/conditions.md)
- **Spec key**: `END`
- **Glossary terms**: [Shared game](../../glossary.md), [Draw](../../glossary.md), [Resign](../../glossary.md)

Split from [`stories/end-conditions.md`](../end-conditions.md) by logical unit. Puzzle rows: [`conditions-puzzle.md`](conditions-puzzle.md).

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| L1 | PS1.1 PS1.2 | L2 | PS1.3 |
| L3 | PS1.4 PS1.5 | D1 | PS1.6 PS1.7 |
| D2 | PS1.8 PS1.9 | D3 | PS1.10 PS1.11 |
| D4 | PS1.12 PS1.13 | D5 | PS1.5 PS1.14 |

## PS1: Reach a result

As a casual player, I finish a Shared game so that the result matches the rules.

### PS1.1: Checkmate loses

- **Proves**: L1

```gherkin
Given side to move in check, no legal move
When checked after a move
Then mover loses And GS.gameEnded true
```

### PS1.2: Check with escape continues

- **Proves**: L1

```gherkin
Given side to move in check with a legal move
When checked after a move
Then play continues
```

### PS1.3: Resign loses

- **Proves**: L2

```gherkin
Given an open Shared game
When the side to move resigns
Then that side loses And GS.gameEnded true
```

### PS1.4: Clock expiry loses

- **Proves**: L3

```gherkin
Given timed And GS.whiteClock 0 And Black can checkmate
When expiry
Then White loses And no seconds added
```

### PS1.5: Clock above zero continues

- **Proves**: L3, D5

```gherkin
Given timed And GS.whiteClock 5 And Black cannot checkmate
When checked while the clock runs
Then no ending applies
```

### PS1.6: Stalemate draws

- **Proves**: D1

```gherkin
Given not in check, no legal move
When checked after a move
Then draw
```

### PS1.7: Moves remaining continue

- **Proves**: D1

```gherkin
Given not in check, with a legal move
When checked after a move
Then play continues
```

### PS1.8: Accepted draw

- **Proves**: D2

```gherkin
Given White offers a draw And GS.drawOffer is White
When Black accepts
Then draw And GS.drawOffer is none And GS.gameEnded true
```

### PS1.9: Declined draw

- **Proves**: D2

```gherkin
Given White offers a draw And GS.drawOffer is White
When Black declines
Then play continues, same side to move, clock running And GS.drawOffer is none
```

### PS1.10: Third repetition draws

- **Proves**: D3

```gherkin
Given same position, side, rights a third time
When checked after a move
Then draw
```

### PS1.11: Second repetition continues

- **Proves**: D3

```gherkin
Given same position, side, rights a second time
When checked after a move
Then play continues
```

### PS1.12: Fifty moves draw

- **Proves**: D4

```gherkin
Given fifty moves each, no capture or pawn move
When checked after a move
Then draw
```

### PS1.13: Forty-nine moves continue

- **Proves**: D4

```gherkin
Given forty-nine moves each, no capture or pawn move
When checked after a move
Then play continues
```

### PS1.14: Clock expiry draws

- **Proves**: D5

```gherkin
Given timed And GS.whiteClock 0 And Black cannot checkmate
When expiry
Then draw And no seconds added
```
