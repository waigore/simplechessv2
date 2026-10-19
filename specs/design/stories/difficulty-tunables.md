# Stories: Difficulty tunables

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`difficulty.md`](../difficulty.md)
- **Spec key**: `DIF`
- **Glossary terms**: [Player Elo](../glossary.md), [Puzzle Elo](../glossary.md), [Puzzle](../glossary.md)

Split from [`difficulty.md`](difficulty.md) by logical unit; that file proves the Elo update and deal at the defaults.

## Coverage

| Element | Scenarios |
|---------|-----------|
| CFG.ELO_K | PS1.1 PS1.2 |
| CFG.ELO_MATCH_RANGE | PS1.3 PS1.4 |
| CFG.ELO_RECENT_WINDOW | PS1.5 PS1.6 |
| CFG.ELO_START | PS1.7 PS1.8 |
| CFG.ELO_BAND_WIDEN | PS1.9 PS1.10 |

## PS1: Elo tunable range ends

As a casual player, I get a stable Elo stream at any designer setting so that tuning cannot break the deal.

### PS1.1: Lowest K

- **Proves**: CFG.ELO_K

```gherkin
Given CFG.ELO_K is 10 And GS.playerElo is 1000 And puzzleElo is 1000 And END.W1 holds
When DIF.Y1 runs
Then GS.playerElo is 1000 + 10 × (1 − 0.5) = 1005
```

### PS1.2: Highest K

- **Proves**: CFG.ELO_K

```gherkin
Given CFG.ELO_K is 40 And GS.playerElo is 1000 And puzzleElo is 1000 And END.W1 holds
When DIF.Y1 runs
Then GS.playerElo is 1000 + 40 × (1 − 0.5) = 1020
```

### PS1.3: Narrowest band

- **Proves**: CFG.ELO_MATCH_RANGE

```gherkin
Given CFG.ELO_MATCH_RANGE is 50 And GS.playerElo is 1000 And unsolved puzzles at 1050 and 1051
When the next puzzle is dealt
Then the dealt puzzleElo is 1050
```

### PS1.4: Widest band

- **Proves**: CFG.ELO_MATCH_RANGE

```gherkin
Given CFG.ELO_MATCH_RANGE is 200 And GS.playerElo is 1000 And unsolved puzzles at 1200 and 1201
When the next puzzle is dealt
Then the dealt puzzleElo is 1200
```

### PS1.5: Shortest solved memory

- **Proves**: CFG.ELO_RECENT_WINDOW

```gherkin
Given CFG.ELO_RECENT_WINDOW is 5 And GS.recentSolved holds 5 IDs
When END.W1 appends a new ID
Then GS.recentSolved holds 5 IDs, newest last, the oldest dropped
```

### PS1.6: Longest solved memory

- **Proves**: CFG.ELO_RECENT_WINDOW

```gherkin
Given CFG.ELO_RECENT_WINDOW is 50 And GS.recentSolved holds 50 IDs
When END.W1 appends a new ID
Then GS.recentSolved holds 50 IDs, newest last, the oldest dropped
```

### PS1.7: Lowest start

- **Proves**: CFG.ELO_START

```gherkin
Given CFG.ELO_START is 400 And no Player Elo is stored
When the player first enters Puzzle stream
Then GS.playerElo is 400
```

### PS1.8: Highest start

- **Proves**: CFG.ELO_START

```gherkin
Given CFG.ELO_START is 2400 And no Player Elo is stored
When the player first enters Puzzle stream
Then GS.playerElo is 2400
```

### PS1.9: Smallest widen

- **Proves**: CFG.ELO_BAND_WIDEN

```gherkin
Given CFG.ELO_MATCH_RANGE is 100 And CFG.ELO_BAND_WIDEN is 25 And the only unsolved puzzle is at 1125
When the next puzzle is dealt
Then the band widens once to ±125 And the puzzle at 1125 is dealt
```

### PS1.10: Largest widen

- **Proves**: CFG.ELO_BAND_WIDEN

```gherkin
Given CFG.ELO_MATCH_RANGE is 100 And CFG.ELO_BAND_WIDEN is 100 And the only unsolved puzzle is at 1200
When the next puzzle is dealt
Then the band widens once to ±200 And the puzzle at 1200 is dealt
```
