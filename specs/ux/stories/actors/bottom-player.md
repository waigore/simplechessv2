# Stories: Bottom player

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/bottom-player.md`](../../actors/bottom-player.md)
- **Spec key**: `ACT-bottom-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| C1 | Meta and puzzle screens | US1.1 |
| C2 | Shared play on Bottom turn | US1.2 US1.3 |
| C3 | Exceptions Confirm/Cancel | US1.4 |
| K1 | No move when Top to move | US1.5 |

## US1: Host and Bottom seat

As Bottom player, I operate mode pick through play so that we can finish a sitting.

### US1.1: Mode pick Shared game

- **Proves**: C1

```gherkin
Given Bottom player is on mode-pick S1
When Bottom activates UI-mode-pick.C1
Then the screen is shared-setup
```

### US1.2: Move on Bottom turn

- **Proves**: C2

```gherkin
Given Bottom player is on shared-play S1 and Bottom seat is side to move and a piece is selected
When Bottom activates UI-shared-play.C2 on a legal destination
Then the interface asks the game for that place and selection clears
```

### US1.3: Advice anytime

- **Proves**: C2

```gherkin
Given Bottom player is on shared-play S1 and GS.advice is Off
When Bottom activates UI-shared-play.C3
Then GS.advice is On
```

### US1.4: Cancel resign

- **Proves**: C3

```gherkin
Given Bottom player is on shared-play S2 EX.confirm resign
When Bottom activates Cancel
Then the screen is shared-play S1 and GS.gameEnded is false
```

### US1.5: Cannot move on Top turn

- **Proves**: K1

```gherkin
Given Bottom player is on shared-play S1 and Top seat is side to move
When Bottom activates UI-shared-play.C1
Then selection is unchanged and no move is asked
```

