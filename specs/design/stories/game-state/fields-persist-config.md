# Stories: Game-state configuration fields

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-persist.md`](../../game-state/fields-persist.md)
- **Spec key**: `GS`
- **Glossary terms**: [White seat](../../glossary.md), [Advice](../../glossary.md)

Split from [`fields-persist.md`](fields-persist.md) by logical unit; that file proves persistent Elo, last mode, and solved IDs.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| GS.whiteSeat | White seat option | PS1.1 PS1.2 |
| GS.clock | Clock option | PS1.1 PS1.3 |
| GS.increment | Increment option | PS1.1 PS1.4 |
| GS.advice | Advice option | PS1.1 PS1.5 PS1.6 |
| GS.locale | Shipped locale | PS1.7 PS1.8 PS1.9 |

## PS1: Session options

As a casual player, I keep my options so that each Shared game starts as expected.

### PS1.1: Option defaults

- **Proves**: GS.whiteSeat, GS.clock, GS.increment, GS.advice

```gherkin
Given no stored options
When the game first runs
Then GS.whiteSeat is Bottom player And GS.clock is Untimed And GS.increment is 3 s And GS.advice is On
```

### PS1.2: White seat locked after start

- **Proves**: GS.whiteSeat

```gherkin
Given a Shared game started with GS.whiteSeat Bottom player
When play tries to set GS.whiteSeat to Top player
Then GS.whiteSeat is Bottom player
```

### PS1.3: Clock locked after start

- **Proves**: GS.clock

```gherkin
Given a Shared game started with GS.clock Untimed
When play tries to set GS.clock to Blitz
Then GS.clock is Untimed
```

### PS1.4: Increment locked after start

- **Proves**: GS.increment

```gherkin
Given a Shared game started timed with GS.increment 3 s
When play tries to set GS.increment to 5 s
Then GS.increment is 3 s
```

### PS1.5: Advice toggles during Shared game

- **Proves**: GS.advice

```gherkin
Given a Shared game with GS.advice On
When play sets GS.advice to Off
Then GS.advice is Off
```

### PS1.6: Advice unused in Puzzle stream

- **Proves**: GS.advice

```gherkin
Given Puzzle stream And GS.advice is On
When Puzzle stream play proceeds
Then GS.advice does not apply
```

### PS1.7: Locale from shipped browser locale

- **Proves**: GS.locale

```gherkin
Given the browser locale is ja And ja is shipped
When the game first runs
Then GS.locale is ja
```

### PS1.8: Locale fallback

- **Proves**: GS.locale

```gherkin
Given the browser locale is fr And fr is not shipped
When the game first runs
Then GS.locale is en
```

### PS1.9: Locale stays shipped

- **Proves**: GS.locale

```gherkin
Given the player sets the locale to zh-Hant
When the setting applies
Then GS.locale is zh-Hant, one of en, zh-Hant, ja
```
