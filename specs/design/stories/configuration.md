# Stories: Configuration

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`configuration.md`](../configuration.md)
- **Spec key**: `CFG`
- **Glossary terms**: [Shared game](../glossary.md), [Puzzle stream](../glossary.md), [Advice](../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| Shared game mode | PS1.1 | Puzzle stream mode | PS1.2 |
| White seat | PS1.3 PS1.4 | Clock | PS1.5 PS1.6 PS1.7 |
| Increment | PS1.8 | Advice | PS1.9 PS1.10 |
| K1 | PS1.11 PS1.12 | K2, K3 | PS1.13 |

## PS1: Choose session options

As a casual player, I set options so that clocks and seats fit the session.

### PS1.1: Shared mode

- **Proves**: Shared game mode

```gherkin
Given Shared game with default options
When the game starts
Then GS.clock Untimed And GS.whiteClock none
```

### PS1.2: Puzzle by Elo

- **Proves**: Puzzle stream mode

```gherkin
Given GS.playerElo 1000
When Puzzle stream deals its first puzzle
Then dealt GS.puzzleElo is 1050, within CFG.ELO_MATCH_RANGE (100) of GS.playerElo 1000
```

### PS1.3: Bottom seat White

- **Proves**: White seat

```gherkin
Given White seat Bottom player
When the game starts
Then Bottom player is White And moves first
```

### PS1.4: Top seat White

- **Proves**: White seat

```gherkin
Given White seat Top player
When the game starts
Then Top player is White And moves first
```

### PS1.5: Untimed

- **Proves**: Clock

```gherkin
Given Clock Untimed
When the game starts
Then GS.whiteClock and GS.blackClock are none
```

### PS1.6: Blitz 60

- **Proves**: Clock

```gherkin
Given Clock Blitz
When the game starts
Then both clocks are CFG.BLITZ_START (60)
```

### PS1.7: Rapid 600

- **Proves**: Clock

```gherkin
Given Clock Rapid
When the game starts
Then both clocks are CFG.RAPID_START (600)
```

### PS1.8: Increment

- **Proves**: Increment

```gherkin
Given Rapid And Increment 5 s And GS.whiteClock 100
When White completes a move
Then GS.whiteClock is 105
```

### PS1.9: Advice On

- **Proves**: Advice

```gherkin
Given Shared game And Advice On And online
When the turn passes
Then advice may run for side to move
```

### PS1.10: Advice Off

- **Proves**: Advice

```gherkin
Given Shared game And Advice Off
When the turn passes
Then GS.adviceBestMove and GS.adviceEval are none
```

### PS1.11: Increment available

- **Proves**: K1

```gherkin
Given Clock Blitz
When options are chosen
Then Increment 3 s and 5 s available
```

### PS1.12: Increment blocked

- **Proves**: K1

```gherkin
Given Clock Untimed
When options are chosen
Then Increment is unavailable
```

### PS1.13: Shared-only

- **Proves**: K2, K3

```gherkin
Given Puzzle stream
When it starts
Then White seat, Clock, Increment, and Advice do not apply
```
