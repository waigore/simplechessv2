# Stories: Play fields — draw offer

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-play-end.md`](../../game-state/fields-play-end.md)
- **Spec key**: `GS`
- **Glossary terms**: [Draw](../../glossary.md), [Side to move](../../glossary.md), [Shared game](../../glossary.md)

Split from [`fields-play-end.md`](fields-play-end.md) by logical unit; that file proves `GS.gameEnded`, `GS.repetitionHistory`, and `GS.fiftyMoveCount`.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| GS.drawOffer | Pending draw offer | PS1.1 PS1.2 PS1.3 PS1.4 PS1.5 PS1.6 PS1.7 |

## PS1: Track a pending draw offer

As a casual player, I rely on one clear offer state so that a draw is never accepted after the game moves on.

### PS1.1: Initial none

- **Proves**: GS.drawOffer

```gherkin
Given a Shared game is open And no draw was offered
When the game starts
Then GS.drawOffer is none
```

### PS1.2: Offer records the side

- **Proves**: GS.drawOffer

```gherkin
Given an open Shared game And GS.sideToMove is White And GS.drawOffer is none
When White offers a draw
Then GS.drawOffer is White
```

### PS1.3: Decline clears

- **Proves**: GS.drawOffer

```gherkin
Given GS.drawOffer is White And GS.sideToMove is White
When Black declines
Then GS.drawOffer is none And GS.sideToMove stays White And White's clock is running
```

### PS1.4: Accept clears and ends

- **Proves**: GS.drawOffer

```gherkin
Given GS.drawOffer is White And GS.gameEnded is false
When Black accepts
Then GS.drawOffer is none And END.D2 applies And GS.gameEnded is true
```

### PS1.5: Only one offer while open

- **Proves**: GS.drawOffer

```gherkin
Given GS.drawOffer is White
When White offers a draw again
Then GS.drawOffer stays White
```

### PS1.6: Ended game holds no offer

- **Proves**: GS.drawOffer

```gherkin
Given GS.gameEnded is true And GS.drawOffer is none
When White offers a draw
Then GS.drawOffer stays none
```

### PS1.7: End clears an open offer

- **Proves**: GS.drawOffer

```gherkin
Given GS.drawOffer is White And the game is open
When END.L2 applies
Then GS.drawOffer is none
```
