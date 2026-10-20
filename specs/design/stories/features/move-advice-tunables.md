# Stories: Advice time tunable

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`features/move-advice.md`](../../features/move-advice.md)
- **Spec key**: `F-move-advice`
- **Glossary terms**: [Advice](../../glossary.md), [Shared game](../../glossary.md)

Split from [`move-advice.md`](move-advice.md) by logical unit; that file proves the other advice rules at the default cap.

## Coverage

| Element | Scenarios |
|---------|-----------|
| CFG.ADVICE_TIME_MS | PS1.1 PS1.2 |

## PS1: Advice cap range ends

As a casual player, I get advice inside the designer's cap so that a slow search never holds a move.

### PS1.1: Shortest cap

- **Proves**: CFG.ADVICE_TIME_MS

```gherkin
Given Shared game And Advice On And online And CFG.ADVICE_TIME_MS is 500 And a best move is ready at 400 ms
When advice is set
Then GS.adviceBestMove is set within 500 ms
```

### PS1.2: Longest cap

- **Proves**: CFG.ADVICE_TIME_MS

```gherkin
Given Shared game And Advice On And online And CFG.ADVICE_TIME_MS is 5000 And no best move is ready
When the search reaches 5000 ms
Then the search stops And GS.adviceBestMove stays none
```
