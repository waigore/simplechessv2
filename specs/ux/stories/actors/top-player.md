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
| C3 | Resign or offer confirm | US1.5 |
| C4 | Answer Bottom's offer | US2.5 US2.6 |
| K1 | Host screens do not activate | US1.6 US1.7 US1.8 US1.9 |
| K2 | Cannot move on Bottom turn | US1.10 US2.7 |
| K3 | Cannot answer own offer | US2.8 |

## US1: Top seat only

As Top player, I play only my Shared-play turns so that seats stay clear.

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

### US1.6: Mode pick forbidden

- **Proves**: K1

```gherkin
Given Top player is present during mode-pick S1
When Top activates UI-mode-pick.C1
Then the screen stays mode-pick
```

### US1.7: Setup forbidden

- **Proves**: K1

```gherkin
Given Top player is present during shared-setup S1
When Top activates UI-shared-setup.C5
Then the screen stays shared-setup
```

### US1.8: Result forbidden

- **Proves**: K1

```gherkin
Given Top player is present during shared-result S1
When Top activates UI-shared-result.C2
Then the screen stays shared-result
```

### US1.9: Puzzle forbidden

- **Proves**: K1

```gherkin
Given Top player is present during puzzle-play S1
When Top activates UI-puzzle-play.C5
Then the screen stays puzzle-play
```

### US1.10: No move on Bottom turn

- **Proves**: K2

```gherkin
Given Top player is on shared-play S1 and Bottom seat is side to move
When Top activates UI-shared-play.C2
Then the interface asks the game for no place And the board still shows the same position ([GS.position](../../../design/game-state.md) unchanged)
```

Choice scenarios: [`top-player-choices.md`](top-player-choices.md).
