# Stories: Bottom player choices

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/bottom-player.md`](../../actors/bottom-player.md)
- **Spec key**: `ACT-bottom-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

Part of [`bottom-player.md`](bottom-player.md). The coverage table lives there.

## US2: Bottom choices

As Bottom player, I promote, offer, or answer a draw so that my seat stays clear.

### US2.1: Offer on Bottom turn

- **Proves**: C2

```gherkin
Given Bottom player is on shared-play S1 and Bottom seat is side to move
When Bottom activates UI-shared-play.C5
Then EX.confirm shows Offer a draw?
```

### US2.2: Promote on Bottom turn

- **Proves**: C2

```gherkin
Given Bottom player is on shared-play S4 and Bottom seat is side to move
When Bottom activates UI-shared-play.C6 on the rook sprite
Then the place is asked with that rook
```

### US2.3: Withdraw Bottom's offer

- **Proves**: C2

```gherkin
Given Bottom player opened shared-play S6
When Bottom activates UI-shared-play.C9
Then the screen is shared-play S1
```

### US2.4: Clear selection

- **Proves**: C2

```gherkin
Given Bottom player is on shared-play S1 and Bottom seat is side to move and GS.selectedPiece is set
When Bottom uses IN.deselect
Then GS.selectedPiece is none
```

### US2.5: Accept Top's offer

- **Proves**: C4

```gherkin
Given Top opened shared-play S6
When Bottom activates UI-shared-play.C7
Then the screen is shared-result
```

### US2.6: Decline Top's offer

- **Proves**: C4

```gherkin
Given Top opened shared-play S6
When Bottom activates UI-shared-play.C8
Then the screen is shared-play S1
```

### US2.7: Cannot offer on Top's turn

- **Proves**: K1

```gherkin
Given Bottom player is on shared-play S1 and Top seat is side to move
When Bottom activates UI-shared-play.C5
Then EX.confirm is not shown
```
