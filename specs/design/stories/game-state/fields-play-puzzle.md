# Stories: Play fields — puzzle solving side

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-play.md`](../../game-state/fields-play.md)
- **Spec key**: `GS`
- **Glossary terms**: [Puzzle](../../glossary.md), [Required sequence](../../glossary.md), [Solving side](../../glossary.md)

Split from [`fields-play.md`](fields-play.md) by logical unit; that file proves the other session fields.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| GS.solvingSide | Side the player moves | PS1.1 PS1.2 PS1.5 |
| GS.sideToMove | Dealt side to move | PS1.1 |
| GS.puzzleId | Open puzzle | PS1.3 PS1.5 |
| GS.puzzleElo | Fixed puzzle rating | PS1.3 PS1.5 PS1.6 |
| GS.requiredSequence | Correct move list | PS1.3 PS1.5 |
| GS.sequenceIndex | Next required step | PS1.3 PS1.4 |
| GS.wrongMoveOnPuzzle | Wrong-move flag | PS1.3 |

## PS1: Bind the player to the puzzle

As a casual player, I always move the same side in a puzzle so that the required replies stay clear.

### PS1.1: Deal sets the solving side

- **Proves**: GS.solvingSide, GS.sideToMove

```gherkin
Given the dealt position has Black to move
When the puzzle is dealt
Then GS.solvingSide is Black And GS.sideToMove is Black
```

### PS1.2: Solving side never changes

- **Proves**: GS.solvingSide

```gherkin
Given GS.solvingSide is Black And a required reply is due
When the game plays the reply
Then GS.solvingSide stays Black
```

### PS1.3: Deal fills the puzzle fields

- **Proves**: GS.puzzleId, GS.puzzleElo, GS.requiredSequence, GS.sequenceIndex, GS.wrongMoveOnPuzzle

```gherkin
Given catalog puzzle P with Puzzle Elo 1050 And Required sequence length 3
When P is dealt
Then GS.puzzleId is P And GS.puzzleElo is 1050 And GS.requiredSequence is P's list And GS.sequenceIndex is 0 And GS.wrongMoveOnPuzzle is false
```

### PS1.4: Index stays in bounds

- **Proves**: GS.sequenceIndex

```gherkin
Given an open puzzle And GS.requiredSequence length is 3 And GS.sequenceIndex is 2
When the last required step is played
Then GS.sequenceIndex is 3 And no further step advances it
```

### PS1.5: Leaving the stream clears puzzle fields

- **Proves**: GS.puzzleId, GS.solvingSide, GS.puzzleElo, GS.requiredSequence

```gherkin
Given an open puzzle And Player Elo is 1100
When the player leaves the stream
Then GS.puzzleId is none And GS.puzzleElo is none And GS.requiredSequence is none And GS.solvingSide is none And GS.playerElo is 1100
```

### PS1.6: Puzzle Elo holds through a wrong move

- **Proves**: GS.puzzleElo

```gherkin
Given an open puzzle with GS.puzzleElo 1050
When the player makes a Wrong move
Then GS.puzzleElo stays 1050
```

PS1.5 cites `GS.playerElo`, a persistent field proven in [`fields-persist.md`](fields-persist.md). The open puzzle is not scored as [END.L6](../../end-conditions/conditions.md).
