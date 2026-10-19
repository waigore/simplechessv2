# Stories: Shared result

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/shared-result.md`](../../screens/shared-result.md)
- **Spec key**: `UI-shared-result`
- **Glossary terms**: [Shared game](../../../design/glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Result | US1.1 |
| R2 | Next actions | US1.2 |
| C1 | Play again | US1.2 |
| C2 | Stop | US1.3 |
| S1 | Default | US1.1 |

## US1: After the game

As Bottom player, I choose play again or stop so that the session continues or returns to modes.

### US1.1: Result shown

- **Proves**: R1, S1

```gherkin
Given GS.gameEnded is true and White won
When shared-result S1 is shown
Then R1 shows the White win outcome
```

### US1.2: Play again

- **Proves**: R2, C1

```gherkin
Given Bottom player is on shared-result S1
When Bottom activates C1
Then the screen is shared-setup
```

### US1.3: Stop

- **Proves**: C2

```gherkin
Given Bottom player is on shared-result S1
When Bottom activates C2
Then the screen is mode-pick
```

