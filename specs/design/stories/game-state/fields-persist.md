# Stories: Game-state persistent and configuration fields

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-persist.md`](../../game-state/fields-persist.md)
- **Spec key**: `GS`
- **Glossary terms**: [Player Elo](../../glossary.md), [Last mode](../../glossary.md), [White seat](../../glossary.md)

Part of [`stories/game-state.md`](../game-state.md). Play fields: [`fields-play.md`](fields-play.md).

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| GS.playerElo | Persistent Elo | PS1.1 PS1.2 |
| GS.lastMode | Persistent last mode | PS1.2 PS1.3 |
| GS.recentSolved | Last solved IDs | PS1.4 PS1.5 PS1.11 |
| GS.whiteSeat | White seat option | PS1.6 PS1.7 |
| GS.clock | Clock option | PS1.6 PS1.7 |
| GS.increment | Increment option | PS1.6 PS1.7 |
| GS.advice | Advice option | PS1.6 PS1.7 |
| GS.locale | Shipped locale | PS1.8 PS1.9 PS1.10 |

## PS1: Kept fields

As a casual player, I keep my settings and Elo so that each session starts as expected.

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

### PS1.6: Option defaults

- **Proves**: GS.whiteSeat, GS.clock, GS.increment, GS.advice

```gherkin
Given no stored options
When the game first runs
Then GS.whiteSeat is Bottom player And GS.clock is Untimed And GS.increment is 3 s And GS.advice is On
```

### PS1.7: Options lock at start

- **Proves**: GS.whiteSeat, GS.clock, GS.increment, GS.advice

```gherkin
Given a Shared game started with White seat, Clock, and Increment chosen
When play proceeds
Then those stay locked And Advice may still toggle
```

### PS1.8: Locale from shipped browser locale

- **Proves**: GS.locale

```gherkin
Given the browser locale is ja And ja is shipped
When the game first runs
Then GS.locale is ja
```

### PS1.9: Locale fallback

- **Proves**: GS.locale

```gherkin
Given the browser locale is fr And fr is not shipped
When the game first runs
Then GS.locale is en
```

### PS1.10: Locale stays shipped

- **Proves**: GS.locale

```gherkin
Given the player sets the locale to zh-Hant
When the setting applies
Then GS.locale is zh-Hant, one of en, zh-Hant, ja
```

### PS1.11: Solved IDs lost when saved data cleared

- **Proves**: GS.recentSolved

```gherkin
Given GS.recentSolved holds p1, p2
When this game's saved data is cleared
Then GS.recentSolved is empty on next use
```
