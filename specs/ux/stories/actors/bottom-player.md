# Stories: Bottom player

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/bottom-player.md`](../../actors/bottom-player.md)
- **Spec key**: `ACT-bottom-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| C1 | Host screens' controls | US1.1 US1.2 US1.3 US1.4 |
| C2 | Shared play on Bottom turn | US1.5 US1.6 US1.7 US1.8 US2.1 US2.2 US2.3 US2.4 |
| C3 | Exceptions Confirm/Cancel | US1.9 |
| C4 | Answer Top's offer | US2.5 US2.6 |
| K1 | No move when Top to move | US1.10 US2.7 |
| K2 | Cannot answer own offer | US2.8 |

## US1: Host and Bottom seat

As Bottom player, I operate mode pick through play so that we can finish a sitting.

### US1.1: Mode pick Shared game

- **Proves**: C1

```gherkin
Given Bottom player is on mode-pick S1
When Bottom activates UI-mode-pick.C1
Then the screen is shared-setup
```

### US1.2: Setup Start

- **Proves**: C1

```gherkin
Given Bottom player is on shared-setup S1
When Bottom activates UI-shared-setup.C5
Then the screen is shared-play
```

### US1.3: Result Play again

- **Proves**: C1

```gherkin
Given Bottom player is on shared-result S1
When Bottom activates UI-shared-result.C1
Then the screen is shared-setup
```

### US1.4: Puzzle Reveal

- **Proves**: C1

```gherkin
Given Bottom player is on puzzle-play S1
When Bottom activates UI-puzzle-play.C3
Then EX.confirm reveal is shown
```

### US1.5: Move on Bottom turn

- **Proves**: C2

```gherkin
Given Bottom player is on shared-play S1 and Bottom seat is side to move and a piece is selected
When Bottom activates UI-shared-play.C2 on a legal destination
Then the interface asks the game for that place and selection clears
```

### US1.6: Select on Bottom turn

- **Proves**: C2

```gherkin
Given Bottom player is on shared-play S1 and Bottom seat is side to move
When Bottom activates UI-shared-play.C1 on a Bottom piece
Then GS.selectedPiece is that piece
```

### US1.7: Resign on Bottom turn

- **Proves**: C2

```gherkin
Given Bottom player is on shared-play S1 and Bottom seat is side to move
When Bottom activates UI-shared-play.C4
Then EX.confirm resign is shown
```

### US1.8: Advice anytime

- **Proves**: C2

```gherkin
Given Bottom player is on shared-play S1 and GS.advice is Off
When Bottom activates UI-shared-play.C3
Then GS.advice is On
```

### US1.9: Cancel resign

- **Proves**: C3

```gherkin
Given Bottom player is on shared-play S2 EX.confirm resign
When Bottom activates Cancel
Then the screen is shared-play S1 and GS.gameEnded is false
```

### US1.10: Cannot move on Top turn

- **Proves**: K1

```gherkin
Given Bottom player is on shared-play S1 and Top seat is side to move
When Bottom activates UI-shared-play.C1
Then selection is unchanged and no move is asked
```

Choice scenarios: [`bottom-player-choices.md`](bottom-player-choices.md).
