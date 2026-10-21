# Stories: Puzzle catalog

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`features/puzzle-catalog.md`](../../features/puzzle-catalog.md)
- **Spec key**: `F-puzzle-catalog`
- **Glossary terms**: [Puzzle catalog](../../glossary.md), [Puzzle Elo](../../glossary.md), [Required sequence](../../glossary.md), [Wrong move](../../glossary.md)

Selection, replies, and edges: [`puzzle-catalog-select.md`](puzzle-catalog-select.md).

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Host snapshot, CC0, not in the client | PS1.1 |
| R2 | Dated snapshot; continuous Rating; no bands | PS1.2 |
| R3 | FEN, first move, required list | PS1.3 |
| R4 | Recorded move only when the mark is false | PS1.4 PS1.5 PS1.6 |
| R5 | Any checkmate when `mateIn1` | PS1.5 PS1.6 PS1.7 |

## PS1: Read a catalog record

As a casual player, I receive one puzzle from the host catalog so that the position and solution match that snapshot.

### PS1.1: Catalog stays on the host

- **Proves**: R1

```gherkin
Given the served snapshot holds 6157341 records And the client does not contain those records
When a puzzle is dealt
Then GS.puzzleId is a PuzzleId from that snapshot And the client still does not contain the snapshot
```

### PS1.2: Continuous Rating, no bands

- **Proves**: R2

```gherkin
Given the served snapshot is dated 2026-10-05 and holds 6157341 puzzles
When a puzzle is dealt
Then GS.puzzleElo equals that record's Rating And no Elo-band id is set
```

### PS1.3: Apply the first move

- **Proves**: R3

```gherkin
Given PuzzleId abc123, FEN 4k3/8/8/8/8/8/4P3/4K3 b - - 0 1, Moves e8d7 e2e4, Rating 1050, mate-in-one mark false
When the puzzle is dealt
Then the presented position is after e8d7 And GS.puzzleId is abc123 And GS.puzzleElo is 1050 And GS.requiredSequence is e2e4 And GS.solvingSide is White
```

### PS1.4: Recorded move matches

- **Proves**: R4

```gherkin
Given the dealt puzzle from PS1.3 And GS.requiredSequence is e2e4 And the mate-in-one mark is false
When the player plays e2e4
Then the sequence completes And GS.wrongMoveOnPuzzle is false
```

### PS1.5: Another move misses when the mark is false

- **Proves**: R4, R5

```gherkin
Given the dealt puzzle from PS1.3 And e2e3 is legal and is not the recorded move And the mate-in-one mark is false
When the player plays e2e3
Then it is a Wrong move And GS.sequenceIndex is 0 And GS.wrongMoveOnPuzzle is true
```

### PS1.6: Any checkmate matches mate in one

- **Proves**: R4, R5

```gherkin
Given a mate-in-one record And GS.requiredSequence is h1h8 And a1a8 is another legal checkmating move
When the player plays a1a8
Then the sequence completes And GS.wrongMoveOnPuzzle is false And GS.requiredSequence is still h1h8
```

### PS1.7: A non-mating move misses mate in one

- **Proves**: R5

```gherkin
Given a mate-in-one record And GS.requiredSequence is h1h8 And e2e4 is legal and is not checkmate
When the player plays e2e4
Then it is a Wrong move And GS.sequenceIndex is 0
```
