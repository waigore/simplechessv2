# Stories: Draw-offer lifecycle

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`end-conditions/conditions.md`](../../end-conditions/conditions.md)
- **Spec key**: `END`
- **Glossary terms**: [Draw](../../glossary.md), [Shared game](../../glossary.md), [Side to move](../../glossary.md)

Split from [`conditions.md`](conditions.md) by logical unit; that file proves the other Shared-game conditions.

## Coverage

| Element | Scenarios |
|---------|-----------|
| D2 | PS1.1 PS1.2 PS1.3 |

## PS1: Close a draw offer

As a casual player, I offer, withdraw, or answer a draw so that the game continues or ends as agreed.

### PS1.1: Withdraw continues

- **Proves**: D2

```gherkin
Given an open Shared game And White offered a draw And GS.drawOffer is White
When White withdraws the offer
Then GS.drawOffer is none And no draw And GS.sideToMove is White And White's clock is running
```

### PS1.2: Unanswered offer lapses on a move

- **Proves**: D2

```gherkin
Given an open Shared game And White offered a draw And GS.drawOffer is White
When White completes a legal move
Then GS.drawOffer is none And no draw And GS.sideToMove is Black
```

### PS1.3: Ended game refuses an offer

- **Proves**: D2

```gherkin
Given a Shared game And GS.gameEnded is true
When White attempts to offer a draw
Then GS.drawOffer remains none And no draw
```
