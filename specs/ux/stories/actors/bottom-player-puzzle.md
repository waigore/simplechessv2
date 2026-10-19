# Stories: Bottom player result and puzzle controls

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/bottom-player.md`](../../actors/bottom-player.md)
- **Spec key**: `ACT-bottom-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

Part of [`bottom-player.md`](bottom-player.md). The coverage table lives there.

## US4: Host controls on results and puzzles

As Bottom player, I operate the result and puzzle controls so that I can continue or leave.

### US4.1: Stop from result

- **Proves**: C1

```gherkin
Given Bottom player is on shared-result S1
When Bottom activates UI-shared-result.C2
Then the screen is mode-pick S1
```

### US4.2: Select on puzzle

- **Proves**: C1

```gherkin
Given Bottom player is on puzzle-play S1 with an open puzzle
When Bottom activates UI-puzzle-play.C1 on a movable piece
Then GS.selectedPiece is that piece
```

### US4.3: Place on puzzle

- **Proves**: C1

```gherkin
Given Bottom player is on puzzle-play S1 and a piece is selected
When Bottom activates UI-puzzle-play.C2 on a square
Then the interface asks the puzzle to judge that place
```

### US4.4: Abandon on puzzle

- **Proves**: C1

```gherkin
Given Bottom player is on puzzle-play S1
When Bottom activates UI-puzzle-play.C4
Then EX.confirm shows Abandon this puzzle?
```

### US4.5: Leave stream from puzzle

- **Proves**: C1

```gherkin
Given Bottom player is on puzzle-play S1
When Bottom activates UI-puzzle-play.C5
Then EX.confirm shows Leave the puzzle stream?
```

### US4.6: Promote on puzzle

- **Proves**: C1

```gherkin
Given Bottom player is on puzzle-play S4
When Bottom activates UI-puzzle-play.C6 on the rook sprite
Then the puzzle judges that place with a White rook and S4 closes
```
