# Stories: Move advice — clear and stop

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`features/move-advice.md`](../../features/move-advice.md)
- **Spec key**: `F-move-advice`
- **Glossary terms**: [Advice](../../glossary.md), [Shared game](../../glossary.md)

Split from [`move-advice.md`](move-advice.md) by logical unit; that file proves when advice runs, output, and move-clear with re-search.

## Coverage

| Element | Scenarios |
|---------|-----------|
| R9, X2 | PS1.1 |
| R9, X3 | PS1.2 |
| R8, X4 | PS1.3 |

## PS1: Clear advice and stop evaluation

As a casual player, I see advice leave when help stops so that a finished or disabled search never lingers.

### PS1.1: Off clears

- **Proves**: R9, X2

```gherkin
Given advice is set
When Advice is turned Off
Then advice clears And evaluation stops
```

### PS1.2: Offline clears

- **Proves**: R9, X3

```gherkin
Given an evaluation is in flight
When the connection is lost
Then advice clears And evaluation stops
```

### PS1.3: End clears

- **Proves**: R8, X4

```gherkin
Given advice is set
When GS.gameEnded becomes true
Then advice clears
```
