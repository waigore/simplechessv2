# Stories: Puzzle play regions

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/puzzle-play.md`](../../screens/puzzle-play.md)
- **Spec key**: `UI-puzzle-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

Part of [`puzzle-play.md`](puzzle-play.md) stories; the coverage table lives there. This file proves region visibility, citing the design for what the player can know ([game-state.md](../../../design/game-state.md) H1, [puzzle-stream.md](../../../design/loops/puzzle-stream.md)).

## US2: What the stream shows

As Bottom player, I see the dealt puzzle and my Elo so that practice stays clear.

### US2.1: Coordinates

- **Proves**: R1, S1

```gherkin
Given Bottom player is on puzzle-play S1
When the screen is shown
Then R1 shows a–h and 1–8 only on the outer edges
```

### US2.2: Position shown

- **Proves**: R1

```gherkin
Given a puzzle is open with dealt GS.position (always knowable in play, game-state H1)
When the screen is shown
Then R1 shows that position
```

### US2.3: Selection visible

- **Proves**: R1

```gherkin
Given GS.selectedPiece is a White knight on g1
When the screen is shown
Then R1 highlights that piece and square
```

### US2.4: Elo visible

- **Proves**: R2

```gherkin
Given GS.playerElo is 1000 (shown on deal, puzzle-stream K1)
When puzzle-play is shown
Then R2 shows Elo 1000
```

### US2.5: Puzzle result cue

- **Proves**: R2

```gherkin
Given a wrong move just failed the open puzzle (clear fail, puzzle-stream K2)
When the cue is shown before the next deal
Then R2 shows Wrong move
```

### US2.6: Actions visible

- **Proves**: R3

```gherkin
Given puzzle-play S1
When the screen is shown
Then R3 shows Reveal, Abandon, and Leave stream
```

### US2.7: Solved cue

- **Proves**: R2

```gherkin
Given [END.W1](../../../design/end-conditions/conditions.md) solved the open puzzle
When the cue is shown before the next deal
Then R2 shows Solved
```

### US2.8: Abandon cue

- **Proves**: R2

```gherkin
Given [END.L6](../../../design/end-conditions/conditions.md) abandoned the open puzzle
When the cue is shown before the next deal
Then R2 shows Abandoned
```

### US2.9: Legal marks visible

- **Proves**: R1

```gherkin
Given GS.selectedPiece is a White knight on g1 (legal moves derived from GS.position, game-state)
When the screen is shown
Then R1 marks each legal destination square
```
