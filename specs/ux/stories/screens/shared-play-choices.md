# Stories: Shared play choices

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/shared-play.md`](../../screens/shared-play.md)
- **Spec key**: `UI-shared-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

Part of [`shared-play.md`](shared-play.md). The coverage table lives there. Place branches: [`shared-play-place.md`](shared-play-place.md).

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

### US3.5: Accept the offer

- **Proves**: C7, S6

```gherkin
Given shared-play S6 and Top offered the draw
When Bottom activates C7
Then the screen is shared-result and C7, C8, and C9 are not shown
```

### US3.7: Decline the offer

- **Proves**: C8

```gherkin
Given shared-play S6 and Top offered the draw and Clock is Blitz and GS.sideToMove is White
When Bottom activates C8
Then the screen is shared-play S1 and R2 shows White to move and that clock still runs
```

### US3.9: Withdraw the offer

- **Proves**: C9

```gherkin
Given shared-play S6 and Top offered the draw and Clock is Blitz and GS.sideToMove is White
When Top activates C9
Then the screen is shared-play S1 and R2 shows White to move and that clock still runs
```

### US3.12: Confirm opens the offer

- **Proves**: S2, S6

```gherkin
Given shared-play S2 showing Offer a draw? and Clock is Blitz
When the side to move activates Confirm
Then the screen is shared-play S6 and R2 still shows both clocks
```

### US3.15: Offer panel controls

- **Proves**: S6

```gherkin
Given shared-play S6
When the screen is shown
Then C1–C3 are available per side-to-move and C7, C8, and C9 are shown as available
```

### US1.8: Cancel resign

- **Proves**: S2

```gherkin
Given S2 resign confirm
When the actor activates Cancel
Then the screen is shared-play S1
```

### US1.9: Advice error shown

- **Proves**: S3

```gherkin
Given shared-play S1 and GS.advice is On
When Advice fetch failed
Then shared-play S3 shows Advice unavailable. Play continues. And C1–C5 are available
```

### US3.17: Dismiss advice error

- **Proves**: S3

```gherkin
Given shared-play S3 EX.error after Advice fetch failed
When the actor activates Dismiss
Then the screen is shared-play S1 and C1–C5 stay usable
```