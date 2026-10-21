# Stories: Shared play

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/shared-play.md`](../../screens/shared-play.md)
- **Spec key**: `UI-shared-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Board | US2.1 US2.2 US2.3 US2.10 |
| R2 | Status | US2.4 US2.5 US2.6 US2.7 |
| R3 | Advice | US2.8 US2.9 |
| R4 | Resign | US1.1 |
| C1 | Select | US1.2 US1.6 US4.1 US4.9 |
| C2 | Place | US1.3 US1.7 US3.11 US3.13 US3.14 US3.16 US4.2 US4.10 |
| C3 | Advice | US1.4 US4.3 |
| C4 | Resign | US1.1 US1.5 US4.4 US4.11 |
| S1 | Default | US2.1 |
| S2 | EX.confirm | US1.1 US1.8 US3.12 |
| S3 | EX.error | US1.9 US3.17 |
| C5 | Offer draw | US3.1 US3.2 US4.5 US4.12 |
| C6 | Promotion | US3.3 US3.4 |
| C7 | Accept | US3.5 US4.6 |
| C8 | Decline | US3.7 US4.7 |
| C9 | Withdraw | US3.9 US4.8 |
| S4 | EX.promote | US3.3 US3.13 |
| S5 | EX.rejected | US3.11 |
| S6 | EX.draw-offer | US3.5 US3.12 US3.14 US3.15 |

US2: [`shared-play-regions.md`](shared-play-regions.md). US3: [`shared-play-choices.md`](shared-play-choices.md), [`shared-play-place.md`](shared-play-place.md). US4: [`shared-play-unavailable.md`](shared-play-unavailable.md).

## US1: Shared board play

As Bottom or Top player, I move on my turn so that the game advances.

### US1.1: Resign confirm

- **Proves**: R4, C4, S2

```gherkin
Given the side-to-move actor is on S1
When that actor activates C4
Then EX.confirm shows Resign this game? And Confirm and Cancel are available
```

### US1.2: Select on turn

- **Proves**: C1

```gherkin
Given Bottom seat is side to move on shared-play S1
When Bottom activates C1 on a Bottom piece
Then GS.selectedPiece is that piece
```

### US1.3: Place move

- **Proves**: C2

```gherkin
Given Bottom seat is side to move and GS.selectedPiece is set
When Bottom activates C2 on a legal square that is not last-rank promotion
Then the interface asks for that place and GS.selectedPiece is cleared
```

### US1.4: Shared Advice

- **Proves**: C3

```gherkin
Given shared-play S1 and GS.advice is Off
When that actor activates C3
Then GS.advice is On
```

### US1.5: Resign unavailable off turn

- **Proves**: C4

```gherkin
Given Bottom is not side to move on shared-play S1
When Bottom activates C4
Then no confirm appears
```

### US1.6: Select unavailable off turn

- **Proves**: C1

```gherkin
Given Bottom is not side to move on shared-play S1
When Bottom activates C1 on a piece
Then GS.selectedPiece is unchanged
```

### US1.7: Place unavailable off turn

- **Proves**: C2

```gherkin
Given Bottom is not side to move on shared-play S1
When Bottom activates C2 on a square
Then position unchanged and no place asked
```
