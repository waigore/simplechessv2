# Stories: Move advice

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`features/move-advice.md`](../../features/move-advice.md)
- **Spec key**: `F-move-advice`
- **Glossary terms**: [Advice](../../glossary.md), [Shared game](../../glossary.md), [Side to move](../../glossary.md)

Clear/stop: [`move-advice-clear.md`](move-advice-clear.md). Cap ends: [`move-advice-tunables.md`](move-advice-tunables.md).

## Coverage

| Element | Scenarios |
|---------|-----------|
| R1 | PS1.1 PS1.2 |
| R2 | PS1.1 PS1.3 PS1.4 |
| R3 | PS1.1 |
| R4, R5 | PS1.5 PS1.13 |
| R6, I1 | PS1.6 |
| R7, CFG.ADVICE_TIME_MS | PS1.7 PS1.8 |
| R8, X1 | PS1.9 |
| R8 | PS1.14 |
| D1 | PS1.2 PS1.3 |

## PS1: Optional board advice

As a casual player, I may see best-move advice so that help never delays a move.

### PS1.1: Shared may evaluate

- **Proves**: R1, R2, R3

```gherkin
Given Shared game And Advice On And online
When the position is ready
Then the engine evaluates automatically for the side to move
```

### PS1.2: Puzzle never

- **Proves**: R1, D1

```gherkin
Given Puzzle stream And a puzzle open
When the position is ready
Then no evaluation runs And GS.adviceBestMove is none
```

### PS1.3: Off never

- **Proves**: R2, D1

```gherkin
Given Shared game And Advice Off
When the position is ready
Then no evaluation runs And GS.adviceBestMove is none
```

### PS1.4: Offline never

- **Proves**: R2

```gherkin
Given Shared game And Advice On And GS.online is false
When the position is ready
Then no evaluation runs And GS.adviceBestMove and GS.adviceEval are none
```

### PS1.5: White output

- **Proves**: R4, R5

```gherkin
Given R2 holds, GS.sideToMove White, best move ready
When advice is set
Then GS.adviceBestMove is that move And GS.adviceEval is centipawns from White's view And the player cannot know a principal line
```

### PS1.6: Move never waits

- **Proves**: R6, I1

```gherkin
Given evaluation in flight, GS.sideToMove White, GS.position P
When White completes a legal move to P2
Then GS.sideToMove is Black And GS.position is P2 And GS.adviceBestMove and GS.adviceEval are none
```

### PS1.7: Inside the cap

- **Proves**: R7, CFG.ADVICE_TIME_MS

```gherkin
Given R2 holds And best move ready at 1500 ms
When it is set
Then GS.adviceBestMove is set within CFG.ADVICE_TIME_MS (2000)
```

### PS1.8: Cap stops search

- **Proves**: R7, CFG.ADVICE_TIME_MS

```gherkin
Given R2 holds And no best move ready
When the search reaches CFG.ADVICE_TIME_MS (2000)
Then the search stops And GS.adviceBestMove stays none
```

### PS1.9: Move clears

- **Proves**: R8, X1

```gherkin
Given advice set, evaluation in flight, R2 holds after the move
When a move completes
Then advice clears And evaluation starts on the new position
```

### PS1.13: Black output

- **Proves**: R4, R5

```gherkin
Given R2 holds, GS.sideToMove Black, best move ready
When advice is set
Then GS.adviceBestMove is that Black move And GS.adviceEval is centipawns from White's view And the player cannot know a principal line
```

### PS1.14: Off move, no search

- **Proves**: R8

```gherkin
Given advice is set And Advice Off
When a move completes
Then GS.adviceBestMove and GS.adviceEval are none And no evaluation starts
```
