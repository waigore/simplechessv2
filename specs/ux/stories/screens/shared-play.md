# Stories: Shared play

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/shared-play.md`](../../screens/shared-play.md)
- **Spec key**: `UI-shared-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Board and coordinates | US2.1 US2.2 US2.3 |
| R2 | Status | US2.4 US2.5 US2.6 US2.7 |
| R3 | Advice marks | US2.8 US2.9 |
| R4 | Resign | US1.1 |
| C1 | Select | US1.2 US1.6 |
| C2 | Place | US1.3 US1.7 |
| C3 | Advice shared | US1.4 |
| C4 | Resign | US1.1 US1.5 |
| S1 | Default | US2.1 |
| S2 | EX.confirm | US1.1 US1.8 |
| S3 | EX.error | US1.9 |

US2 region scenarios live in [`shared-play-regions.md`](shared-play-regions.md).

## US1: Shared board play

As Bottom or Top player, I move on my turn so that the game advances.

### US1.1: Resign confirm

- **Proves**: R4, C4, S2

```gherkin
Given the side-to-move actor is on shared-play S1
When that actor activates C4
Then EX.confirm shows Resign this game?
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
When Bottom activates C2 on a legal square
Then the interface asks for that legal place
```

### US1.4: Shared Advice

- **Proves**: C3

```gherkin
Given either actor is on shared-play S1 and GS.advice is Off
When that actor activates C3
Then GS.advice is On
```

### US1.5: Resign unavailable off turn

- **Proves**: C4

```gherkin
Given Bottom seat is not side to move on shared-play S1
When Bottom activates C4
Then EX.confirm is not shown and the game is not ended
```

### US1.6: Select unavailable off turn

- **Proves**: C1

```gherkin
Given Bottom seat is not side to move on shared-play S1
When Bottom activates C1 on a piece
Then GS.selectedPiece is unchanged
```

### US1.7: Place unavailable off turn

- **Proves**: C2

```gherkin
Given Bottom seat is not side to move on shared-play S1
When Bottom activates C2 on a square
Then the position is unchanged and no place is asked
```

### US1.8: Cancel resign

- **Proves**: S2

```gherkin
Given shared-play S2 resign confirm
When the actor activates Cancel
Then the screen is shared-play S1
```

### US1.9: Advice error

- **Proves**: S3

```gherkin
Given shared-play S3 EX.error after Advice fetch failed
When the actor dismisses
Then the screen is shared-play S1 and C1–C2 remain usable for the side to move
```
