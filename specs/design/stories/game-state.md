# Stories: Game state

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state.md`](../game-state.md)
- **Spec key**: `GS`
- **Glossary terms**: [Side to move](../glossary.md), [Required sequence](../glossary.md), [Advice](../glossary.md)

Field rows: [`stories/game-state/fields-play.md`](game-state/fields-play.md), [`stories/game-state/fields-play-moment.md`](game-state/fields-play-moment.md), [`stories/game-state/fields-persist.md`](game-state/fields-persist.md).

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| V1 | Only side to move changes position | PS1.1 |
| V2 | At most one clock runs | PS1.2 |
| V3 | No advice fields in Puzzle stream | PS1.3 |
| H1 | Sequence hidden until played or revealed | PS1.4 PS1.5 |
| H2 | Advice fields knowable only when set | PS1.6 PS1.7 |
| Q1 | Deal need not repeat | PS1.8 |

## PS1: Invariants and knowledge

As a casual player, I rely on consistent state so that legality and Elo stay trustworthy.

### PS1.1: Other side cannot move

- **Proves**: V1

```gherkin
Given GS.sideToMove is White
When Black attempts to change GS.position
Then GS.position is unchanged
```

### PS1.2: Only one clock runs

- **Proves**: V2

```gherkin
Given a Blitz game And GS.sideToMove is White And White's clock is running
When White completes a legal move
Then GS.whiteClock is stopped And GS.blackClock is running And both never run together
```

### PS1.3: Puzzle advice stays none

- **Proves**: V3

```gherkin
Given Puzzle stream And a puzzle is open
When the player completes a move
Then GS.adviceBestMove is none And GS.adviceEval is none
```

### PS1.4: Sequence hidden before reveal

- **Proves**: H1

```gherkin
Given a dealt puzzle before any reveal
When play begins on it
Then the player can know GS.position and GS.sideToMove And cannot know the full Required sequence
```

### PS1.5: Sequence knowable after reveal

- **Proves**: H1

```gherkin
Given an open puzzle
When the player reveals the solution
Then the player can know the full Required sequence
```

### PS1.6: Advice knowable when set

- **Proves**: H2

```gherkin
Given a Shared game And Advice On And online And a best move is ready
When advice is set
Then the player can know GS.adviceBestMove and GS.adviceEval
```

### PS1.7: Advice not knowable when unset

- **Proves**: H2

```gherkin
Given a Shared game And Advice Off
When the position is ready
Then GS.adviceBestMove is none And the player cannot know GS.adviceBestMove or GS.adviceEval
```

### PS1.8: Deal may differ

- **Proves**: Q1

```gherkin
Given the same GS.playerElo and history And multiple candidate puzzles
When two deals occur
Then the chosen puzzles need not match
```
