# Stories: Shared-game clock tunables

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`loops/two-player-game.md`](../../loops/two-player-game.md)
- **Spec key**: `L-two-player-game`
- **Glossary terms**: [Blitz](../../glossary.md), [Rapid](../../glossary.md), [Shared game](../../glossary.md)

Split from [`two-player-game.md`](two-player-game.md) by logical unit; that file proves the loop at the default clocks.

## Coverage

| Element | Scenarios |
|---------|-----------|
| CFG.BLITZ_START | PS1.1 PS1.2 |
| CFG.RAPID_START | PS1.3 PS1.4 |

## PS1: Clock tunable range ends

As a casual player, I get the chosen clock length so that Blitz and Rapid stay predictable at any setting.

### PS1.1: Shortest Blitz

- **Proves**: CFG.BLITZ_START

```gherkin
Given CFG.BLITZ_START is 30 And Clock Blitz
When K1 completes
Then GS.whiteClock is 30 And GS.blackClock is 30 And only White's clock runs
```

### PS1.2: Longest Blitz

- **Proves**: CFG.BLITZ_START

```gherkin
Given CFG.BLITZ_START is 180 And Clock Blitz
When K1 completes
Then GS.whiteClock is 180 And GS.blackClock is 180 And only White's clock runs
```

### PS1.3: Shortest Rapid

- **Proves**: CFG.RAPID_START

```gherkin
Given CFG.RAPID_START is 300 And Clock Rapid
When K1 completes
Then GS.whiteClock is 300 And GS.blackClock is 300 And only White's clock runs
```

### PS1.4: Longest Rapid

- **Proves**: CFG.RAPID_START

```gherkin
Given CFG.RAPID_START is 1800 And Clock Rapid
When K1 completes
Then GS.whiteClock is 1800 And GS.blackClock is 1800 And only White's clock runs
```
