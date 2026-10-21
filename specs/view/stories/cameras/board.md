# Stories: Board camera

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../../.agents/specs/rules/view/story.md).

- **View spec**: [`cameras/board.md`](../../cameras/board.md)
- **Spec key**: `CAM-board`
- **Glossary terms**: [Board camera](../../glossary.md), [Board orientation](../../glossary.md), [Frame](../../glossary.md)

Limits, occlusion, transitions: [`board-limits.md`](board-limits.md).

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| F1 F2 | VS1.1 | F3 F5 | VS1.2 |
| F4 M1 | VS1.3 | M2 | VS1.4 VS1.5 VS1.6 VS1.7 |
| E1 | VS1.8 | P1 | VS1.9 |

## VS1: Fixed table view

As a casual player, I look straight down at a fixed board so that my side faces me without panning.

### VS1.1: Target and rest

- **Proves**: F1, F2

```gherkin
Given CAM-board Web 9:16, White seat Bottom
When CAM-board is active
Then target is board center (4, 4), frame center matches, and the board has a 1-unit short-axis margin per PRJ.V1
```

### VS1.2: No offset or lookahead

- **Proves**: F3, F5

```gherkin
Given CAM-board Web 9:16
When framing checked
Then offset is none And lookahead is none
```

### VS1.3: Dead zone none while a piece moves

- **Proves**: F4, M1

```gherkin
Given CAM-board Web 9:16, a piece travels under PHY.M1
When travel runs
Then dead zone is none And camera position and zoom stay unchanged
```

### VS1.4: Bottom seat, no rotation

- **Proves**: M2

```gherkin
Given CAM-board Web 9:16, White seat Bottom
When play opens
Then framed board rotation about F1 is 0° ±0° within cut 0 s And White near edge faces Bottom
```

### VS1.5: Top seat, rotate 180°

- **Proves**: M2

```gherkin
Given CAM-board Web 9:16, White seat Top
When play opens
Then framed board rotates 180° ±0° about F1 within cut 0 s And White near edge faces Top
```

### VS1.6: Puzzle Solving side Black

- **Proves**: M2

```gherkin
Given CAM-board Web 9:16, Puzzle stream, Solving side Black
When the puzzle is dealt
Then board rotation about F1 is 180° ±0° within cut 0 s And Black's near edge faces the player
```

### VS1.7: Puzzle Solving side White

- **Proves**: M2

```gherkin
Given CAM-board Web 9:16, Puzzle stream, Solving side White
When the puzzle is dealt
Then board rotation about F1 is 0° ±0° within cut 0 s And White's near edge faces the player
```

### VS1.8: No effect

- **Proves**: E1

```gherkin
Given CAM-board Web 9:16, any play event
When E1 checked
Then no shake or zoom punch runs
```

### VS1.9: No player control

- **Proves**: P1

```gherkin
Given CAM-board Web 9:16
When any camera action is attempted
Then position, angle, and zoom are unchanged (CC has no actions)
```
