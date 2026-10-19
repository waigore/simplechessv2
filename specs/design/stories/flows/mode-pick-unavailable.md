# Stories: Mode pick — unavailable verbs and interruptions

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`flows/mode-pick.md`](../../flows/mode-pick.md)
- **Spec key**: `FL-mode-pick`
- **Glossary terms**: [Session](../../glossary.md), [Shared game](../../glossary.md), [Puzzle stream](../../glossary.md), [Last mode](../../glossary.md)

Split from [`mode-pick.md`](mode-pick.md) by logical unit; that file proves the available verbs, transitions, and entry and exit.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| P1 | Unavailable verbs | PS1.1 |
| P2 | No direct switch | PS1.2 |
| P3 | No direct switch | PS1.3 |
| U1 | Interrupt → P1 | PS1.4 |

## PS1: Unavailable verbs and interruptions

As a casual player, I leave a mode only by its own exit so that each mode is entered from mode pick.

### PS1.1: Unavailable verbs have no effect

- **Proves**: P1

```gherkin
Given phase is P1
When the player attempts a piece move
Then GS.position is unchanged
```

### PS1.2: No direct switch from Shared game

- **Proves**: P2

```gherkin
Given phase is P2
When the player attempts to switch to Puzzle stream
Then the phase remains P2 And GS.lastMode is Shared game
```

### PS1.3: No direct switch from Puzzle stream

- **Proves**: P3

```gherkin
Given phase is P3
When the player attempts to switch to Shared game
Then the phase remains P3 And GS.lastMode is Puzzle stream
```

### PS1.4: Interrupt mid-mode

- **Proves**: U1

```gherkin
Given phase is P3 And a puzzle is open And GS.playerElo is 1200
When the player closes and reopens
Then phase is P1 And GS.playerElo is 1200 And the open puzzle was not abandon-scored
```
