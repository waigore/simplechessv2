# Stories: Puzzle stream visit

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`scenarios/puzzle-stream-visit.md`](../../scenarios/puzzle-stream-visit.md)
- **Spec key**: `SC-puzzle-stream-visit`
- **Glossary terms**: [Puzzle](../../glossary.md), [Player Elo](../../glossary.md), [Wrong move](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| W1.1 | Open at mode pick | PS1.1 |
| W1.2 | Choose Puzzle stream | PS1.1 |
| W1.3 | Solve each Solving side move | PS1.1 |
| W1.4 | Solve and deal next | PS1.1 |
| W2.1 | Wrong move resets | PS1.2 |
| W2.2 | Reveal fails | PS1.2 |
| W2.3 | Abandon fails | PS1.2 |
| W2.4 | Leave unscored | PS1.2 |

## PS1: Visit the Puzzle stream

As a casual player, I solve puzzles and leave calmly so that every result follows the stream rules.

### PS1.1: Solve the first deal

- **Proves**: W1.1, W1.2, W1.3, W1.4

```gherkin
Given a first visit And GS.playerElo is 1000 And GS.lastMode is none
When the player opens the game
Then phase is FL-mode-pick.P1 And Shared game is the default choice
When the player chooses Puzzle stream
Then phase is FL-mode-pick.P3 And a puzzle is dealt per DIF.Y1 And GS.sequenceIndex is 0
When the player plays each Solving side move before the last
Then GS.sequenceIndex increases by 2 for each matching move and reply And the next puzzle is not dealt
When the player completes the last required step with GS.wrongMoveOnPuzzle false
Then GS.sequenceIndex is the sequence length And END.W1 applies And S is 1 And GS.playerElo rises per DIF.Y1 And GS.recentSolved appends the puzzle id And the next puzzle is dealt
```

### PS1.2: Wrong move, reveal, abandon, leave

- **Proves**: W2.1, W2.2, W2.3, W2.4

```gherkin
Given an open puzzle And GS.sequenceIndex is 0
When the player plays a Wrong move
Then GS.position returns to the dealt start And GS.sequenceIndex is 0 And GS.wrongMoveOnPuzzle is true And the next puzzle is not dealt
When the player reveals the solution
Then END.L5 applies And S is 0 And the next puzzle is dealt
When the player abandons the new puzzle
Then END.L6 applies And S is 0 And the next puzzle is dealt
When the player leaves the stream
Then phase is FL-mode-pick.P1 And GS.playerElo is kept And the open puzzle is not scored as END.L6
```
