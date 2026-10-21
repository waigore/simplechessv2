# Stories: Puzzle stream — sequence advance

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`loops/puzzle-stream.md`](../../loops/puzzle-stream.md)
- **Spec key**: `L-puzzle-stream`
- **Glossary terms**: [Puzzle](../../glossary.md), [Required sequence](../../glossary.md)

Split from [`puzzle-stream.md`](puzzle-stream.md) by logical unit; that file proves deal, fail, result, leave, and mate-in-one.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| K2 | Matching move with or without reply | PS1.1 PS1.2 |

## PS1: Advance the required sequence

As a casual player, I play the next required move so that the sequence advances without dealing the next puzzle.

### PS1.1: Matching move with reply advances by two

- **Proves**: K2

```gherkin
Given an open puzzle And GS.sequenceIndex is 0 And the next required player move is e2e4 And the required reply is e7e5
When the player plays e2e4
Then GS.sequenceIndex is 2 And GS.position reflects both moves And the next puzzle is not dealt
```

### PS1.2: Matching move with no reply advances by one

- **Proves**: K2

```gherkin
Given an open puzzle And GS.sequenceIndex is 0 And the next required player move is e2e4 And there is no required reply after that move
When the player plays e2e4
Then GS.sequenceIndex is 1 And GS.position reflects that move And the next puzzle is not dealt
```
