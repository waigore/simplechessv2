# Stories: Top player puzzle controls

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/top-player.md`](../../actors/top-player.md)
- **Spec key**: `ACT-top-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

Part of [`top-player.md`](top-player.md). The coverage table lives there.

## US4: Whoever touches the puzzle stream

As Top player, I operate puzzle controls so that a touch is enough.

### US4.1: Puzzle Reveal

- **Proves**: C5

```gherkin
Given Top player is on puzzle-play S1
When Top activates UI-puzzle-play.C3
Then EX.confirm reveal is shown
```

### US4.2: Select on puzzle

- **Proves**: C5

```gherkin
Given Top player is on puzzle-play S1 with an open puzzle
When Top activates UI-puzzle-play.C1 on a movable piece
Then GS.selectedPiece is that piece
```

### US4.3: Place on puzzle

- **Proves**: C5

```gherkin
Given Top player is on puzzle-play S1 and a piece is selected
When Top activates UI-puzzle-play.C2 on a square
Then the interface asks the puzzle to judge that place
```

### US4.4: Abandon on puzzle

- **Proves**: C5

```gherkin
Given Top player is on puzzle-play S1
When Top activates UI-puzzle-play.C4
Then EX.confirm shows Abandon this puzzle?
```

### US4.5: Leave stream from puzzle

- **Proves**: C5

```gherkin
Given Top player is on puzzle-play S1
When Top activates UI-puzzle-play.C5
Then EX.confirm shows Leave the puzzle stream?
```

### US4.6: Promote on puzzle

- **Proves**: C5

```gherkin
Given Top player is on puzzle-play S4
When Top activates UI-puzzle-play.C6 on the rook sprite
Then the puzzle judges that place with a White rook and S4 closes
```
