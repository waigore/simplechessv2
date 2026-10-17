# Stories: Top player

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/top-player.md`](../../actors/top-player.md)
- **Spec key**: `ACT-top-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| C1 | Move and resign on Top turn | US1.1 US1.2 |
| C2 | Shared Advice toggle | US1.3 |
| C3 | Resign confirm | US1.4 |
| K1 | Cannot use host screens | US1.5 |
| K2 | Cannot move on Bottom turn | US1.6 |

## US1: Top seat only

As Top player, I play only my Shared-play turns so that seats stay clear.

### US1.1: Select on Top turn

- **Proves**: C1

```gherkin
Given Top player is on shared-play S1 and Top seat is side to move
When Top activates UI-shared-play.C1 on a Top piece
Then GS.selectedPiece is that piece
```

### US1.2: Resign available on Top turn

- **Proves**: C1

```gherkin
Given Top player is on shared-play S1 and Top seat is side to move
When Top activates UI-shared-play.C4
Then EX.confirm resign is shown
```

### US1.3: Shared Advice

- **Proves**: C2

```gherkin
Given Top player is on shared-play S1 and GS.advice is On
When Top activates UI-shared-play.C3
Then GS.advice is Off
```

### US1.4: Confirm resign

- **Proves**: C3

```gherkin
Given Top player is on shared-play S2 resign confirm and Top seat is side to move
When Top activates Confirm
Then the screen is shared-result
```

### US1.5: Mode pick forbidden

- **Proves**: K1

```gherkin
Given Top player is present during mode-pick S1
When Top activates UI-mode-pick.C1
Then the screen stays mode-pick
```

### US1.6: No move on Bottom turn

- **Proves**: K2

```gherkin
Given Top player is on shared-play S1 and Bottom seat is side to move
When Top activates UI-shared-play.C2
Then the position is unchanged
```

