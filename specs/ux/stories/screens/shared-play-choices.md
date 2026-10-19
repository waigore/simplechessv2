# Stories: Shared play choices

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/shared-play.md`](../../screens/shared-play.md)
- **Spec key**: `UI-shared-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

Part of [`shared-play.md`](shared-play.md). The coverage table lives there.

## US3: Promotion, refusal, and draw

As the side-to-move actor, I choose a promotion or a draw so that the board stays playable.

### US3.1: Offer draw

- **Proves**: C5

```gherkin
Given the side-to-move actor is on shared-play S1
When that actor activates C5
Then EX.confirm shows Offer a draw?
```

### US3.2: Offer unavailable off turn

- **Proves**: C5

```gherkin
Given Bottom seat is not side to move on shared-play S1
When Bottom activates C5
Then EX.confirm is not shown
```

### US3.13: Promotion shown

- **Proves**: S4

```gherkin
Given shared-play S1 and a legal pawn place is on the last rank
When the side to move asks that place
Then S4 shows queen, rook, bishop, and knight sprites and C6 is usable
```

### US3.3: Promotion commit

- **Proves**: C6, S4

```gherkin
Given shared-play S4 and the pawn is White
When the side to move activates C6 on the knight sprite
Then the place is asked with a White knight and S4 closes
```

### US3.4: Promotion unavailable

- **Proves**: C6

```gherkin
Given shared-play S1 with no pawn on the last rank
When the actor activates C6
Then no promotion type is committed
```

### US3.5: Other seat accepts

- **Proves**: C7, S6

```gherkin
Given shared-play S6 and Top offered the draw
When Bottom activates C7
Then the screen is shared-result and the result is a draw
```

### US3.6: Offerer cannot accept

- **Proves**: C7

```gherkin
Given shared-play S6 and Top offered the draw
When Top activates C7
Then the screen stays S6
```

### US3.7: Other seat declines

- **Proves**: C8

```gherkin
Given shared-play S6 and Top offered the draw
When Bottom activates C8
Then the screen is shared-play S1 and Top's seat is still side to move
```

### US3.8: Offerer cannot decline

- **Proves**: C8

```gherkin
Given shared-play S6 and Top offered the draw
When Top activates C8
Then the screen stays S6
```

### US3.9: Offerer withdraws

- **Proves**: C9

```gherkin
Given shared-play S6 and Top offered the draw
When Top activates C9
Then the screen is shared-play S1 and Top's seat is still side to move
```

### US3.10: Other seat cannot withdraw

- **Proves**: C9

```gherkin
Given shared-play S6 and Top offered the draw
When Bottom activates C9
Then the screen stays S6
```

### US3.12: Confirm opens the offer

- **Proves**: S2, S6

```gherkin
Given shared-play S2 showing Offer a draw?
When the side to move activates Confirm
Then the screen is shared-play S6 and that clock is still running
```

### US3.11: Refused place

- **Proves**: S5

```gherkin
Given shared-play S1 with a selection and a place the piece rules refuse
When the side to move asks that place
Then S5 flashes that square and GS.selectedPiece stays set and C1 stays usable
```
