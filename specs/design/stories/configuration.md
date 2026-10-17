# Stories: Configuration

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`configuration.md`](../configuration.md)
- **Spec key**: `CFG`
- **Glossary terms**: [Shared game](../glossary.md), [Puzzle stream](../glossary.md), [Advice](../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| Shared game mode | PS1.1 | Puzzle stream mode | PS1.2 |
| White seat | PS1.3 | Clock | PS1.4 PS1.5 |
| Increment | PS1.6 | Advice | PS1.7 PS1.8 |
| K1 | PS1.9 PS1.10 | K2 | PS1.11 |
| K3 | PS1.12 | | |

## PS1: Choose session options

As a casual player, I set Shared-game options so that clocks and seats match the sitting.

### PS1.1–PS1.3: Modes and seat

- **Proves**: Shared game mode, Puzzle stream mode, White seat

```gherkin
Given choose Shared game When play starts Then two people one device And clocks/Advice follow Shared options
Given choose Puzzle stream When play starts Then no clocks Advice N/A And deals follow Player Elo
Given White seat Bottom When game starts Then Bottom is White And White moves first
```

### PS1.4–PS1.8: Clock, increment, Advice

- **Proves**: Clock, Increment, Advice

```gherkin
Given Clock Untimed When start Then both clocks none
Given Clock Blitz When start Then each clock CFG.BLITZ_START (60)
Given Rapid Increment 5 s whiteClock 100 When White completes move Then whiteClock 105
Given Shared Advice On online When turn Then advice may run for side to move
Given Shared Advice Off When turn Then no eval and no display
```

### PS1.9–PS1.12: Restrictions

- **Proves**: K1, K2, K3

```gherkin
Given Clock Blitz When setup Then Increment 3 s and 5 s available
Given Clock Untimed When setup Then Increment unavailable
Given Puzzle stream When open Then White seat Clock Increment do not apply
Given Puzzle stream When open Then Advice does not apply
```
