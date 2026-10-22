# Stories: Shared play unavailable controls

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/shared-play.md`](../../screens/shared-play.md)
- **Spec key**: `UI-shared-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

Part of [`shared-play.md`](shared-play.md). The coverage table lives there. This file proves controls do nothing while unavailable.

## US4: Unavailable controls

As Bottom or Top player, I tap a control that is not available so that the screen state does not change.

### US4.1: Select unavailable in confirm

- **Proves**: C1

```gherkin
Given shared-play S2 resign confirm
When the side-to-move actor activates C1
Then GS.selectedPiece is unchanged and S2 stays
```

### US4.2: Place unavailable in confirm

- **Proves**: C2

```gherkin
Given shared-play S2 resign confirm
When the side-to-move actor activates C2
Then no place is asked and S2 stays
```

### US4.3: Advice unavailable in confirm

- **Proves**: C3

```gherkin
Given shared-play S2 resign confirm and GS.advice is On
When the side-to-move actor activates C3
Then GS.advice is unchanged and S2 stays
```

### US4.4: Resign unavailable in confirm

- **Proves**: C4

```gherkin
Given shared-play S2 resign confirm
When the side-to-move actor activates C4
Then no second confirm is shown and S2 stays
```

### US4.5: Offer unavailable in confirm

- **Proves**: C5

```gherkin
Given shared-play S2 resign confirm
When the side-to-move actor activates C5
Then EX.confirm is unchanged and S2 stays
```

### US4.6: Accept unavailable without an offer

- **Proves**: C7

```gherkin
Given shared-play S1
When the actor activates C7
Then the screen stays S1
```

### US4.7: Decline unavailable without an offer

- **Proves**: C8

```gherkin
Given shared-play S1
When the actor activates C8
Then the screen stays S1
```

### US4.8: Withdraw unavailable without an offer

- **Proves**: C9

```gherkin
Given shared-play S1
When the actor activates C9
Then the screen stays S1
```

### US4.9: Select unavailable in promotion

- **Proves**: C1

```gherkin
Given shared-play S4
When the side-to-move actor activates C1
Then GS.selectedPiece is unchanged and S4 stays
```

### US4.10: Place unavailable in promotion

- **Proves**: C2

```gherkin
Given shared-play S4
When the side-to-move actor activates C2
Then no place is asked and S4 stays
```

### US4.11: Resign unavailable in draw offer

- **Proves**: C4

```gherkin
Given shared-play S6
When the side-to-move actor activates C4
Then no confirm is shown and S6 stays
```

### US4.12: Offer unavailable in draw offer

- **Proves**: C5

```gherkin
Given shared-play S6
When the side-to-move actor activates C5
Then no confirm is shown and S6 stays
```

### US4.13: Clear unavailable in confirm

- **Proves**: C10

```gherkin
Given shared-play S2 resign confirm and GS.selectedPiece is set
When the side-to-move actor activates C10
Then GS.selectedPiece is unchanged and S2 stays
```
