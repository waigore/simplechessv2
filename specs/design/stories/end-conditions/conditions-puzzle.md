# Stories: End condition rows — Puzzle

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`end-conditions/conditions.md`](../../end-conditions/conditions.md)
- **Spec key**: `END`
- **Glossary terms**: [Puzzle)](../../glossary.md), [Wrong move)](../../glossary.md), [Required sequence)](../../glossary.md)

Split from [`conditions.md`](conditions.md) by logical unit; that file proves the Shared-game rows.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| W1 | Puzzle solved | PS1.1 |
| L4 | Completed after wrong move | PS1.2 |
| L5 | Reveal fails | PS1.3 |
| L6 | Abandon fails | PS1.4 |

## PS1: Finish a puzzle

As a casual player, I finish each puzzle so that the outcome matches the rules.

### PS1.1: Clean sequence solves

- **Proves**: W1

```gherkin
Given GS.wrongMoveOnPuzzle is false And the Required sequence is completed
When the sequence completes
Then the puzzle is solved And the next puzzle is harder per DIF.Y1
```

### PS1.2: Completion after wrong move fails

- **Proves**: L4

```gherkin
Given GS.wrongMoveOnPuzzle is true And the Required sequence is later completed
When the sequence completes
Then the puzzle is failed And the next puzzle is easier
```

### PS1.3: Reveal fails

- **Proves**: L5

```gherkin
Given an open puzzle
When the player reveals the solution
Then the puzzle is failed And the next puzzle is easier
```

### PS1.4: Abandon fails

- **Proves**: L6

```gherkin
Given an open puzzle
When the player abandons the puzzle
Then the puzzle is failed And GS.playerElo updates as a loss per DIF.Y1 And the next puzzle is dealt
```
