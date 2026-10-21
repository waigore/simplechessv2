# Stories: Play fields — session and run

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-play.md`](../../game-state/fields-play.md)
- **Spec key**: `GS`
- **Glossary terms**: [Side to move](../../glossary.md), [Wrong move](../../glossary.md)

Split from [`stories/game-state.md`](../game-state.md) by scope. Moment fields: [`fields-play-moment.md`](fields-play-moment.md). Ending fields: [`fields-play-end.md`](fields-play-end.md). Draw offer: [`fields-play-draw.md`](fields-play-draw.md). Puzzle fields: [`fields-play-puzzle.md`](fields-play-puzzle.md). Start and reset: [`fields-play-reset.md`](fields-play-reset.md). Persistent fields: [`fields-persist.md`](fields-persist.md).

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| GS.position | PS1.1 PS1.2 PS1.5 | GS.sideToMove | PS1.1 PS1.2 PS1.12 |
| GS.whiteClock, GS.blackClock | PS1.3 PS1.4 | GS.puzzleId | PS1.9 PS1.10 |
| GS.wrongMoveOnPuzzle | PS1.6 PS1.8 PS1.9 | GS.requiredSequence | PS1.9 PS1.11 |
| GS.sequenceIndex | PS1.9 | | |

## PS1: Session fields

As a casual player, I rely on consistent run state so that every game starts clean.

### PS1.1: Wrong move resets position

- **Proves**: GS.position, GS.sideToMove

```gherkin
Given an open puzzle after a Wrong move
When the puzzle resets
Then GS.position is the dealt start And GS.sideToMove is the dealt side
```

### PS1.2: New game resets session fields

- **Proves**: GS.position, GS.sideToMove

```gherkin
Given a Shared game ended mid-position
When another game begins
Then GS.position is the orthodox opening And GS.sideToMove is White
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

### PS1.5: Illegal write leaves position legal

- **Proves**: GS.position

```gherkin
Given an open Shared game And GS.position is legal for Shared
When a write would make GS.position illegal for Shared
Then GS.position remains legal for Shared
```

### PS1.6: Wrong-move flag stays on later move

- **Proves**: GS.wrongMoveOnPuzzle

```gherkin
Given an open puzzle And GS.wrongMoveOnPuzzle is true
When a later move is played on that puzzle
Then GS.wrongMoveOnPuzzle is still true
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

### PS1.12: Side to move alternates

- **Proves**: GS.sideToMove

```gherkin
Given an open Shared game And GS.sideToMove is White
When a White legal move completes
Then GS.sideToMove is Black
```
