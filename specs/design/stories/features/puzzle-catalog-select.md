# Stories: Puzzle catalog selection

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`features/puzzle-catalog.md`](../../features/puzzle-catalog.md)
- **Spec key**: `F-puzzle-catalog`
- **Glossary terms**: [Puzzle catalog](../../glossary.md), [Player Elo](../../glossary.md), [Wrong move](../../glossary.md)

Split from [`puzzle-catalog.md`](puzzle-catalog.md). That file proves R1–R5.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| I1 | DIF.Y1 selects by Rating and PuzzleId | PS2.1 |
| I2 | Even steps are required replies | PS2.2 |
| I3 | recentSolved stores PuzzleId | PS2.3 |
| X1 | Empty solution is not dealt | PS2.4 |
| X2 | Unreadable catalog deals nothing | PS2.5 |
| D1 | Widen is numeric, not a band | PS2.6 |

## PS2: Choose and consume a record

As a casual player, I am dealt a puzzle near my Elo so that recent solves and the mate rule stay consistent.

### PS2.1: Skip a recent PuzzleId

- **Proves**: I1

```gherkin
Given GS.playerElo is 1000 And CFG.ELO_MATCH_RANGE is 100 And CFG.ELO_RECENT_WINDOW is 20 And GS.recentSolved holds old1 And old1 and new1 both have Rating 1000
When a puzzle is dealt
Then GS.puzzleId is new1
```

### PS2.2: Game plays the required reply

- **Proves**: I2

```gherkin
Given GS.requiredSequence is e2e4 e7e5 g1f3 And GS.sequenceIndex is 0
When the player plays e2e4
Then the game plays e7e5 And GS.sequenceIndex is 2 And the next puzzle is not dealt
```

### PS2.3: Solved id is the PuzzleId

- **Proves**: I3

```gherkin
Given END.W1 holds for PuzzleId abc123 And GS.recentSolved is empty
When the result is committed
Then GS.recentSolved holds abc123
```

### PS2.4: Empty solution is not dealt

- **Proves**: X1

```gherkin
Given a record whose Moves list has length 1 And GS.puzzleId is none And GS.playerElo is 1000
When dealing considers that record
Then GS.puzzleId is none And GS.playerElo is 1000
```

### PS2.5: Unreadable catalog deals nothing

- **Proves**: X2

```gherkin
Given the host catalog cannot be read And GS.playerElo is 1000 And GS.puzzleId is none
When a deal is attempted
Then GS.puzzleId is none And GS.puzzleElo is none And GS.playerElo is 1000
```

### PS2.6: Widen the numeric window

- **Proves**: D1

```gherkin
Given GS.playerElo is 1000 And CFG.ELO_MATCH_RANGE is 100 And CFG.ELO_BAND_WIDEN is 50 And the only candidate has Rating 1150
When dealing relaxes per DIF.Y1
Then GS.puzzleElo is 1150 And no Elo band is selected
```
