# Stories: Play exceptions

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`exceptions.md`](../exceptions.md)
- **Spec key**: `EX`
- **Glossary terms**: [Exception](../glossary.md)

## Coverage

Part of [`exceptions.md`](exceptions.md). The coverage table lives there.

## US1: Promotion, refusal, and draw

As Bottom player, I meet promotion, a refused place, and a draw offer so that recovery is clear.

### US1.8: Promotion shown

- **Proves**: EX.promote

```gherkin
Given a legal pawn place would land on the last rank
When that place is asked
Then EX.promote shows queen, rook, bishop, and knight sprites at that square
```

### US1.9: Promotion drop

- **Proves**: EX.promote

```gherkin
Given EX.promote is showing and the pawn is selected
When the actor uses IN.deselect
Then the pawn stays selected and the move is not committed
```

### US1.10: Rejected place shown

- **Proves**: EX.rejected

```gherkin
Given a selected piece and a place the piece rules refuse
When that place is asked
Then the attempted square flashes and GS.selectedPiece stays that piece
```

### US1.11: Rejected place does not trap

- **Proves**: EX.rejected

```gherkin
Given EX.rejected has flashed on shared-play
When the flash ends
Then the screen stays shared-play and the side to move can place again
```

### US1.12: Draw offer shown

- **Proves**: EX.draw-offer

```gherkin
Given the side to move confirmed Offer a draw?
When EX.draw-offer opens
Then one shared panel shows Accept, Decline, and Withdraw
```

### US1.13: Draw offer declined

- **Proves**: EX.draw-offer

```gherkin
Given EX.draw-offer is open
When an actor activates Decline
Then S6 closes and play continues with the same side to move and clocks unchanged
```
