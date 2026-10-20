# Stories: Shared game — draw offer

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`loops/two-player-game.md`](../../loops/two-player-game.md)
- **Spec key**: `L-two-player-game`
- **Glossary terms**: [Draw](../../glossary.md), [Shared game](../../glossary.md), [Side to move](../../glossary.md)

Split from [`two-player-game.md`](two-player-game.md) by logical unit; that file proves moves, clocks, and the loop exits.

## Coverage

| Element | Scenarios |
|---------|-----------|
| K2 | PS1.1 PS1.2 PS1.3 |

## PS1: Offer and answer a draw

As a casual player, I offer or answer a draw so that the game ends only when both sides agree.

### PS1.1: Offer opens

- **Proves**: K2

```gherkin
Given an open Shared game And GS.sideToMove is White And GS.drawOffer is none
When White offers a draw
Then GS.drawOffer is White And no draw And White's clock is running
```

### PS1.2: Accept ends

- **Proves**: K2

```gherkin
Given GS.drawOffer is White And GS.gameEnded is false
When Black accepts
Then END.D2 applies And GS.gameEnded is true And both clocks stop
```

### PS1.3: Decline continues

- **Proves**: K2

```gherkin
Given GS.drawOffer is White And GS.sideToMove is White
When Black declines
Then GS.drawOffer is none And no draw And GS.sideToMove stays White And White's clock is running
```
