# Stories: Game-state persistent fields

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-persist.md`](../../game-state/fields-persist.md)
- **Spec key**: `GS`
- **Glossary terms**: [Player Elo](../../glossary.md), [Last mode](../../glossary.md)

Part of [`stories/game-state.md`](../game-state.md). Configuration fields: [`fields-persist-config.md`](fields-persist-config.md). Play fields: [`fields-play.md`](fields-play.md).

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| GS.playerElo | Persistent Elo | PS1.1 PS1.2 PS1.6 PS1.7 |
| GS.lastMode | Persistent last mode | PS1.2 PS1.3 PS1.6 |
| GS.recentSolved | Last solved IDs | PS1.4 PS1.5 PS1.8 |

## PS1: Kept persistent fields

As a casual player, I keep Elo and mode so that each session starts as expected.

### PS1.1: Elo initial

- **Proves**: GS.playerElo

```gherkin
Given this game's storage has no Player Elo
When the game first runs
Then GS.playerElo is CFG.ELO_START (1000)
```

### PS1.2: Elo and mode persist

- **Proves**: GS.playerElo, GS.lastMode

```gherkin
Given GS.playerElo is 1100 And GS.lastMode is Puzzle stream And the session ends
When the player reopens
Then GS.playerElo is 1100 And GS.lastMode is Puzzle stream
```

### PS1.3: Last mode initial

- **Proves**: GS.lastMode

```gherkin
Given this game's storage has no Last mode
When the game first runs
Then GS.lastMode is none
```

### PS1.4: Solved IDs initial

- **Proves**: GS.recentSolved

```gherkin
Given no puzzle has been solved
When the game first runs
Then GS.recentSolved is empty
```

### PS1.5: Solved IDs trim

- **Proves**: GS.recentSolved

```gherkin
Given GS.recentSolved holds CFG.ELO_RECENT_WINDOW (20) IDs
When END.W1 appends a new ID
Then GS.recentSolved holds CFG.ELO_RECENT_WINDOW (20) IDs, newest last And the oldest is dropped
```

### PS1.6: Elo and last mode reset on clear

- **Proves**: GS.playerElo, GS.lastMode

```gherkin
Given GS.playerElo is 1120 And GS.lastMode is Puzzle stream
When this game's saved data is cleared
Then GS.playerElo is CFG.ELO_START (1000) And GS.lastMode is none on next use
```

### PS1.7: Elo update stays uncapped

- **Proves**: GS.playerElo

```gherkin
Given Puzzle stream And GS.playerElo is 3000 And puzzleElo is 3000 And END.W1 holds
When DIF.Y1 runs
Then GS.playerElo becomes 3000 + CFG.ELO_K × (1 − 0.5) = 3010 And no Elo cap applies
```

### PS1.8: Solved IDs lost when saved data cleared

- **Proves**: GS.recentSolved

```gherkin
Given GS.recentSolved holds p1, p2
When this game's saved data is cleared
Then GS.recentSolved is empty on next use
```
