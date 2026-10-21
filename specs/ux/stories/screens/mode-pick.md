# Stories: Mode pick

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/mode-pick.md`](../../screens/mode-pick.md)
- **Spec key**: `UI-mode-pick`
- **Glossary terms**: [Screen](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Last mode highlight | US1.1 |
| R2 | Quit region | US1.1 |
| R3 | Locale name | US1.9 |
| C1 | Shared game | US1.3 US1.10 |
| C2 | Puzzle stream | US1.4 US1.11 |
| C3 | Quit → confirm | US1.5 US1.12 |
| C4 | Switch locale, immediate | US1.9 US1.13 |
| S1 | Default | US1.1 |
| S2 | EX.loading | US1.6 |
| S3 | EX.confirm quit | US1.5 US1.7 US1.14 |
| S4 | EX.save-failure | US1.8 US1.15 |

US1.10–US1.15: [`mode-pick-unavailable.md`](mode-pick-unavailable.md).

## US1: Choose a mode

As Bottom player, I pick a mode so that play starts.

### US1.1: Default shows Last mode and available controls

- **Proves**: R1, R2, S1

```gherkin
Given a new session starts and GS.lastMode is Puzzle stream
When the interface opens
Then the screen is mode-pick S1 And R1 highlights Puzzle stream And R2 shows Quit And C1–C4 are available
```

### US1.3: Shared game

- **Proves**: C1

```gherkin
Given Bottom player is on mode-pick S1
When Bottom activates C1
Then the screen is shared-setup
```

### US1.4: Puzzle stream

- **Proves**: C2

```gherkin
Given Bottom player is on mode-pick S1
When Bottom activates C2
Then the screen is puzzle-play
```

### US1.5: Quit opens confirm

- **Proves**: C3, S3

```gherkin
Given Bottom player is on mode-pick S1
When Bottom activates C3
Then EX.confirm shows End this session?
```

### US1.6: Loading blocks

- **Proves**: S2

```gherkin
Given cold open before the board is playable
When the interface opens
Then EX.loading is shown and C1–C4 are not available
```

### US1.7: Cancel quit

- **Proves**: S3

```gherkin
Given Bottom player is on mode-pick S3
When Bottom activates Cancel
Then the screen is mode-pick S1
```

### US1.8: Save failure dismiss

- **Proves**: S4

```gherkin
Given Bottom player is on mode-pick S4 after a failed Last mode write
When Bottom activates Dismiss
Then the screen is mode-pick S1 and prior GS.lastMode remains
```

### US1.9: Switch locale applies immediately

- **Proves**: R3, C4

```gherkin
Given Bottom player is on mode-pick S1 and GS.locale is en
When Bottom activates C4
Then R3 shows 繁體中文 and every copy string shows its zh-Hant form and the screen is mode-pick S1
```
