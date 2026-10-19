# Stories: Play fields — session and run

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-play.md`](../../game-state/fields-play.md)
- **Spec key**: `GS`
- **Glossary terms**: [Side to move)](../../glossary.md), [Wrong move)](../../glossary.md)

Split from [`stories/game-state.md`](../game-state.md) by scope. Moment fields: [`fields-play-moment.md`](fields-play-moment.md). Persistent fields: [`fields-persist.md`](fields-persist.md).

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| GS.position | PS1.1 PS1.2 | GS.sideToMove | PS1.2 |
| GS.whiteClock, GS.blackClock | PS1.3 PS1.4 | GS.gameEnded | PS1.2 PS1.5 |
| GS.puzzleId | PS1.6 PS1.9 PS1.10 | GS.puzzleElo | PS1.6 |
| GS.requiredSequence, GS.sequenceIndex | PS1.7 PS1.9 PS1.11 | GS.wrongMoveOnPuzzle | PS1.8 PS1.9 |

## PS1: Session fields

As a casual player, I rely on consistent run state so that every game starts clean.

### PS1.1: Wrong move resets position

- **Proves**: GS.position

```gherkin
Given an open puzzle after a Wrong move
When the puzzle resets
Then GS.position is the dealt start
```

### PS1.2: New game resets session fields

- **Proves**: GS.position, GS.sideToMove, GS.gameEnded

```gherkin
Given a Shared game ended mid-position
When another game begins
Then GS.position is the orthodox opening And GS.sideToMove is White And GS.gameEnded is false
```

### PS1.3: Clock initials

- **Proves**: GS.whiteClock, GS.blackClock

```gherkin
Given Clock Blitz
When the game starts
Then GS.whiteClock is 60 And GS.blackClock is 60
```

### PS1.4: Clocks never negative

- **Proves**: GS.whiteClock, GS.blackClock

```gherkin
Given Blitz And GS.whiteClock 2
When 2 seconds elapse
Then GS.whiteClock is 0, not below 0
```

### PS1.5: End refuses moves

- **Proves**: GS.gameEnded

```gherkin
Given GS.gameEnded is true
When a move is attempted
Then GS.position is unchanged
```

### PS1.6: Deal sets puzzle fields

- **Proves**: GS.puzzleId, GS.puzzleElo

```gherkin
Given puzzle P with Puzzle Elo 1050
When P is dealt
Then GS.puzzleId is P And GS.puzzleElo is 1050, fixed for that puzzle
```

### PS1.7: Sequence advances

- **Proves**: GS.requiredSequence, GS.sequenceIndex

```gherkin
Given a puzzle with Required sequence length 3
When the first required move is played
Then GS.sequenceIndex is 1
```

### PS1.8: Wrong-move flag sticks

- **Proves**: GS.wrongMoveOnPuzzle

```gherkin
Given GS.wrongMoveOnPuzzle is false
When a Wrong move is played
Then GS.wrongMoveOnPuzzle is true until a new deal
```

### PS1.9: New deal resets puzzle fields

- **Proves**: GS.puzzleId, GS.requiredSequence, GS.sequenceIndex, GS.wrongMoveOnPuzzle

```gherkin
Given an ended puzzle with sequenceIndex 3, wrongMoveOnPuzzle true
When the next puzzle is dealt
Then GS.sequenceIndex is 0 And GS.wrongMoveOnPuzzle false And GS.puzzleId is the new puzzle
```

### PS1.10: Puzzle id only in Puzzle stream

- **Proves**: GS.puzzleId

```gherkin
Given a Shared game And GS.puzzleId is none
When a puzzle id would be set during that game
Then GS.puzzleId remains none
```

### PS1.11: Sequence never empty while open

- **Proves**: GS.requiredSequence

```gherkin
Given a dealt puzzle is open
When GS.requiredSequence would be emptied
Then GS.requiredSequence still has length ≥ 1
```
