# Stories: Top player

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/top-player.md`](../../actors/top-player.md)
- **Spec key**: `ACT-top-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| C1 | Select, move, promote, resign, offer on Top turn | US1.1 US1.2 US1.3 US2.1 US2.2 US2.3 US2.4 |
| C2 | Shared Advice toggle | US1.4 |
| C3 | Resign or offer confirm | US1.5 US1.6 |
| C4 | Answer the other seat's offer | US2.5 US2.6 |
| C5 | Every screen, whoever touches | US3.1 US3.2 US3.3 US3.4 US3.5 US3.6 US3.7 US3.8 US3.9 US3.10 US3.11 US3.12 US4.1 US4.2 US4.3 US4.4 US4.5 US4.6 |
| K2 | Top seat move ignored off turn | US1.10 US1.11 US1.12 US2.7 US2.8 US2.9 US2.10 |

## US1: Top seat turns

As Top player, I move on the Top seat's turn so that the game advances.

### US1.1: Select on Top turn

- **Proves**: C1

```gherkin
Given Top player is on shared-play S1 and Top seat is side to move
When Top activates UI-shared-play.C1 on a Top piece
Then GS.selectedPiece is that piece
```

### US1.2: Place on Top turn

- **Proves**: C1

```gherkin
Given Top player is on shared-play S1 and Top seat is side to move and a Top piece is selected
When Top activates UI-shared-play.C2 on a legal destination
Then the interface asks the game for that place and selection clears
```

### US1.3: Resign available on Top turn

- **Proves**: C1

```gherkin
Given Top player is on shared-play S1 and Top seat is side to move
When Top activates UI-shared-play.C4
Then EX.confirm resign is shown
```

### US1.4: Shared Advice

- **Proves**: C2

```gherkin
Given Top player is on shared-play S1 and GS.advice is On
When Top activates UI-shared-play.C3
Then GS.advice is Off
```

### US1.5: Confirm resign

- **Proves**: C3

```gherkin
Given Top player is on shared-play S2 resign confirm and Top seat is side to move
When Top activates Confirm
Then the screen is shared-result
```

### US1.6: Cancel resign

- **Proves**: C3

```gherkin
Given Top player is on shared-play S2 resign confirm and Top seat is side to move
When Top activates Cancel
Then the screen is shared-play S1
```

### US1.10: No move on Bottom turn

- **Proves**: K2

```gherkin
Given Top player is on shared-play S1 and Bottom seat is side to move
When Top activates UI-shared-play.C2
Then the interface asks the game for no place And the board still shows the same position ([GS.position](../../../design/game-state.md) unchanged)
```

### US1.11: Cannot select on Bottom turn

- **Proves**: K2

```gherkin
Given Top player is on shared-play S1 and Bottom seat is side to move
When Top activates UI-shared-play.C1
Then selection is unchanged and no move is asked
```

### US1.12: Cannot clear on Bottom turn

- **Proves**: K2

```gherkin
Given Top player is on shared-play S1 and Bottom seat is side to move and GS.selectedPiece is set
When Top activates UI-shared-play.C10
Then GS.selectedPiece is unchanged
```

Choice scenarios: [`top-player-choices.md`](top-player-choices.md). Other screens: [`top-player-host.md`](top-player-host.md), [`top-player-puzzle.md`](top-player-puzzle.md).
