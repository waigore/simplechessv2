# Stories: Move advice

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`features/move-advice.md`](../../features/move-advice.md)
- **Spec key**: `F-move-advice`
- **Glossary terms**: [Advice](../../glossary.md), [Shared game](../../glossary.md), [Side to move](../../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| R1 | PS1.1 PS1.2 | R2 | PS1.3 PS1.4 |
| R3 | PS1.3 | R4 R5 | PS1.5 |
| R6 I1 | PS1.6 | R7 CFG.ADVICE_TIME_MS | PS1.7 |
| R8 X1 | PS1.8 | R9 X2 | PS1.9 |
| R9 X3 | PS1.10 | R8 X4 | PS1.11 |
| D1 | PS1.2 PS1.4 | | |

## PS1: Optional board advice

As a casual player, I may see best-move advice so that help appears without delaying my move.

### PS1.1–PS1.4: When advice runs

- **Proves**: R1, R2, R3, D1

```gherkin
Given Shared Advice On online When side to move Then evaluation may run
Given Puzzle stream When puzzle open Then no evaluation And adviceBestMove none
Given Shared Advice On online When position ready Then engine evaluates automatically
Given Shared Advice Off When position ready Then no evaluation and no display
```

### PS1.5–PS1.7: Output and cap

- **Proves**: R4, R5, R6, I1, R7, CFG.ADVICE_TIME_MS

```gherkin
Given Shared R2 holds sideToMove White And best move ready When set Then adviceBestMove is that move And adviceEval is centipawns from White's view
Given eval in flight When legal move completes Then move and turn change without waiting on engine
Given R2 holds When eval runs Then search stops by CFG.ADVICE_TIME_MS (2000)
```

### PS1.8–PS1.11: Clear paths

- **Proves**: R8, R9, X1, X2, X3, X4

```gherkin
Given advice showing eval in flight And R2 holds after move When move completes Then advice clears And eval starts on new position
Given advice showing When Advice Off Then clears And eval stops
Given eval in flight When connection lost Then clears And eval stops
Given advice showing When gameEnded true Then advice clears
```
