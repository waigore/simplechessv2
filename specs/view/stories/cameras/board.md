# Stories: Board camera

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../../.agents/specs/rules/view/story.md).

- **View spec**: [`cameras/board.md`](../../cameras/board.md)
- **Spec key**: `CAM-board`
- **Glossary terms**: [Board camera](../../glossary.md), [Board orientation](../../glossary.md), [Frame](../../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| F1 F2 | VS1.1 | F3 F4 F5 | VS1.2 |
| M1 | VS1.3 | M2 | VS1.4 VS1.5 VS1.12 |
| L1 L2 | VS1.6 | O1 | VS1.7 |
| T1 | VS1.8 VS1.9 | E1 | VS1.10 |
| P1 | VS1.11 | | |

## VS1: Fixed table view

As a casual player, I look straight down at a fixed board so that my side faces me without panning.

### VS1.1: Target and rest

- **Proves**: F1, F2

```gherkin
Given CAM-board Web 9:16, White seat Bottom
When CAM-board is active
Then target is board center (4, 4), frame center matches, and the board has a 1-unit short-axis margin per PRJ.V1
```

### VS1.2: No offset, dead zone, or lookahead

- **Proves**: F3, F4, F5

```gherkin
Given CAM-board Web 9:16
When framing checked
Then offset, dead zone, and lookahead are none
```

### VS1.3: No follow

- **Proves**: M1

```gherkin
Given CAM-board Web 9:16, a piece travels under PHY.M1
When travel runs
Then camera position and zoom stay unchanged
```

### VS1.4: Bottom seat, no rotation

- **Proves**: M2

```gherkin
Given CAM-board Web 9:16, White seat Bottom
When play opens
Then framed board rotation about F1 is 0° And White near edge faces Bottom
```

### VS1.5: Top seat, rotate 180°

- **Proves**: M2

```gherkin
Given CAM-board Web 9:16, White seat Top
When play opens
Then framed board rotates 180° about F1 And White near edge faces Top
```

### VS1.6: Fixed bounds and zoom

- **Proves**: L1, L2

```gherkin
Given CAM-board Web 9:16
When pan or zoom attempted
Then camera stays on SPC.B1 And short-axis extent stays PRJ.P1
```

### VS1.7: Open table

- **Proves**: O1

```gherkin
Given CAM-board Web 9:16, open table
When board viewed
Then O1 holds: no scenery between camera and board
```

### VS1.8: Enter play

- **Proves**: T1

```gherkin
Given mode pick Web 9:16, CAM-board as the target camera
When FL-mode-pick.T1 or T2 fires
Then CAM-board is in use within 0 s cut And nothing carries over
```

### VS1.9: Leave play

- **Proves**: T1

```gherkin
Given CAM-board Web 9:16, Shared or Puzzle play
When FL-mode-pick.T3 or T4 fires
Then CAM-board leaves by 0 s cut
```

### VS1.10: No effect

- **Proves**: E1

```gherkin
Given CAM-board Web 9:16, any play event
When E1 checked
Then no shake or zoom punch runs
```

### VS1.11: No player control

- **Proves**: P1

```gherkin
Given CAM-board Web 9:16
When any camera action is attempted
Then position, angle, and zoom are unchanged (CC has no actions)
```

### VS1.12: Puzzle orientation

- **Proves**: M2

```gherkin
Given CAM-board Web 9:16, Puzzle stream, Solving side Black
When the puzzle is dealt
Then board rotation about F1 is 180° And Black's near edge faces the player
```
