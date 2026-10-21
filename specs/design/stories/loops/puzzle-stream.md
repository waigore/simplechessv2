# Stories: Puzzle stream

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`loops/puzzle-stream.md`](../../loops/puzzle-stream.md)
- **Spec key**: `L-puzzle-stream`
- **Glossary terms**: [Puzzle](../../glossary.md), [Required sequence](../../glossary.md), [Wrong move](../../glossary.md), [Player Elo](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| K1 | Deal next puzzle | PS1.1 |
| K2 | Move, reveal, abandon, mate in one | PS1.2 PS1.3 PS1.4 PS1.5 PS1.8 |
| K3 | Result then next deal | PS1.6 |
| K4 | Leave stream | PS1.7 |
| E1 | Leave exit | PS1.7 |

## PS1: Work the puzzle stream

As a casual player, I solve adaptive puzzles so that Elo drifts without ending the stream on failure.

### PS1.1: Enter deals a puzzle

- **Proves**: K1

```gherkin
Given the player enters Puzzle stream And GS.playerElo is 1000
When K1 runs
Then a puzzle is dealt per DIF.Y1 And GS.puzzleId is set And GS.solvingSide is the dealt side to move And GS.sequenceIndex is 0 And GS.wrongMoveOnPuzzle is false And the player can know GS.playerElo
```

### PS1.2: Matching move advances

- **Proves**: K2

```gherkin
Given an open puzzle And GS.sequenceIndex is 0 And the next required player move is e2e4 And the required reply is e7e5
When the player plays e2e4
Then GS.sequenceIndex is 2 And GS.position reflects both moves And the next puzzle is not dealt
```

### PS1.3: Wrong move resets puzzle

- **Proves**: K2

```gherkin
Given an open puzzle And GS.sequenceIndex is 2 And GS.wrongMoveOnPuzzle is false
When the player plays a Wrong move
Then GS.position returns to the puzzle start And GS.sequenceIndex is 0 And GS.wrongMoveOnPuzzle is true And the next puzzle is not dealt
```

### PS1.4: Reveal fails

- **Proves**: K2

```gherkin
Given an open puzzle
When the player reveals the solution
Then END.L5 applies And clocks remain none And Advice remains none
```

### PS1.5: Abandon reaches END.L6

- **Proves**: K2

```gherkin
Given an open puzzle And GS.playerElo is 1100
When the player abandons the puzzle
Then END.L6 applies And GS.playerElo is 1100 And the next puzzle is not dealt
```

### PS1.6: After result, Elo updates and next deal

- **Proves**: K3

```gherkin
Given END.W1 just held on the open puzzle
When K3 runs
Then GS.playerElo updates once per DIF.Y1 And the next puzzle is dealt once And play returns to K2
```

### PS1.7: Leave without abandon score

- **Proves**: K4, E1

```gherkin
Given an open puzzle And GS.playerElo is 1150
When the player leaves the stream
Then phase is FL-mode-pick.P1 And GS.playerElo is 1150 And the open puzzle is not abandon-scored
```

### PS1.8: Mate in one accepts any checkmate

- **Proves**: K2

```gherkin
Given an open mate-in-one puzzle And the recorded step is h1h8 And a1a8 is another legal checkmating move And GS.sequenceIndex is 0
When the player plays a1a8
Then the sequence step matches And GS.wrongMoveOnPuzzle is false And the next puzzle is not dealt
```
