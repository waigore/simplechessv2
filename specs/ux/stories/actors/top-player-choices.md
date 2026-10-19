# Stories: Top player choices

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/top-player.md`](../../actors/top-player.md)
- **Spec key**: `ACT-top-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

Part of [`top-player.md`](top-player.md). The coverage table lives there.

## US2: Top choices

As Top player, I promote, offer, or answer a draw so that my seat stays clear.

### US2.1: Offer on Top turn

- **Proves**: C1

```gherkin
Given Top player is on shared-play S1 and Top seat is side to move
When Top activates UI-shared-play.C5
Then EX.confirm shows Offer a draw?
```

### US2.2: Promote on Top turn

- **Proves**: C1

```gherkin
Given Top player is on shared-play S4 and Top seat is side to move
When Top activates UI-shared-play.C6 on the bishop sprite
Then the place is asked with that bishop
```

### US2.3: Withdraw Top's offer

- **Proves**: C1

```gherkin
Given Top player opened shared-play S6
When Top activates UI-shared-play.C9
Then the screen is shared-play S1
```

### US2.4: Clear selection

- **Proves**: C1

```gherkin
Given Top player is on shared-play S1 and Top seat is side to move and GS.selectedPiece is set
When Top uses IN.deselect
Then GS.selectedPiece is none
```

### US2.5: Accept Bottom's offer

- **Proves**: C4

```gherkin
Given Bottom opened shared-play S6
When Top activates UI-shared-play.C7
Then the screen is shared-result
```

### US2.6: Decline Bottom's offer

- **Proves**: C4

```gherkin
Given Bottom opened shared-play S6
When Top activates UI-shared-play.C8
Then the screen is shared-play S1
```

### US2.7: Cannot offer on Bottom's turn

- **Proves**: K2

```gherkin
Given Top player is on shared-play S1 and Bottom seat is side to move
When Top activates UI-shared-play.C5
Then EX.confirm is not shown
```
