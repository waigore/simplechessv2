# Stories: Difficulty

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`difficulty.md`](../difficulty.md)
- **Spec key**: `DIF`
- **Glossary terms**: [Player Elo](../glossary.md), [Puzzle Elo](../glossary.md), [Puzzle](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| Y1 | Elo update and deal | PS1.1 PS1.2 PS1.3 PS1.4 |
| C1 | No manual Elo | PS1.5 PS1.9 |
| CFG.ELO_K | Default K | PS1.1 |
| CFG.ELO_MATCH_RANGE | ± band | PS1.3 |
| CFG.ELO_START | First Elo | PS1.6 |
| CFG.ELO_RECENT_WINDOW | Solved-memory window | PS1.7 |
| CFG.ELO_BAND_WIDEN | Band-widen step | PS1.8 |

## PS1: Match puzzles to level

As a casual player, I get puzzles near my Elo so that the stream stays adaptive.

### PS1.1: Win updates Elo

- **Proves**: Y1, CFG.ELO_K

```gherkin
Given Puzzle stream And GS.playerElo is 1000 And puzzleElo is 1000 And END.W1 holds
When DIF.Y1 runs
Then S is 1 And E is 0.5 And GS.playerElo becomes 1000 + CFG.ELO_K × (1 − 0.5) = 1010 And puzzleElo is unchanged
```

### PS1.2: Loss updates Elo

- **Proves**: Y1

```gherkin
Given Puzzle stream And GS.playerElo is 1000 And puzzleElo is 1000 And abandon-puzzle holds
When DIF.Y1 runs
Then S is 0 And GS.playerElo becomes 1000 + 20 × (0 − 0.5) = 990
```

### PS1.3: Prefer in-band unsolved

- **Proves**: Y1, CFG.ELO_MATCH_RANGE

```gherkin
Given GS.playerElo is 1000 And catalog puzzles at 950, 1000, and 1200 And none of 950 or 1000 are in GS.recentSolved
When the next puzzle is dealt
Then the dealt puzzleElo is within ±CFG.ELO_MATCH_RANGE (100) of 1000
```

### PS1.4: Relax when none fit

- **Proves**: Y1

```gherkin
Given GS.playerElo is 1000 And every in-band candidate is among the last 20 solved
When the next puzzle is dealt
Then the dealer widens the band by 50 and/or allows a recently solved puzzle until one is found
```

### PS1.5: Cannot set Elo by hand

- **Proves**: C1

```gherkin
Given Puzzle stream And GS.playerElo is 1100
When the player attempts to set Player Elo manually
Then GS.playerElo remains 1100
```

### PS1.6: First-time Elo

- **Proves**: CFG.ELO_START

```gherkin
Given this game's storage has no Player Elo
When the player first enters Puzzle stream
Then GS.playerElo is CFG.ELO_START (1000)
```

### PS1.7: Solved memory window

- **Proves**: CFG.ELO_RECENT_WINDOW

```gherkin
Given GS.recentSolved holds CFG.ELO_RECENT_WINDOW (20) IDs
When END.W1 appends a new ID
Then GS.recentSolved holds CFG.ELO_RECENT_WINDOW (20), newest last, the oldest dropped
```

### PS1.8: Band widens when none fit

- **Proves**: CFG.ELO_BAND_WIDEN

```gherkin
Given GS.playerElo is 1000 And no unsolved puzzle is within CFG.ELO_MATCH_RANGE (100)
When the next puzzle is dealt
Then the dealer widens the band by CFG.ELO_BAND_WIDEN (50) until a puzzle fits
```

### PS1.9: Saved-data clear resets Elo

- **Proves**: C1

```gherkin
Given GS.playerElo is 1100
When this game's saved data is cleared
Then the next game uses GS.playerElo CFG.ELO_START (1000)
```
