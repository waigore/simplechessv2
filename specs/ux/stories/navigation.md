# Stories: Navigation

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`navigation.md`](../navigation.md)
- **Spec key**: `NAV`
- **Glossary terms**: [Screen](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| T1 | mode-pick → setup | US1.1 US2.6 |
| T2 | mode-pick → puzzle | US1.2 US2.7 |
| T3 | quit session | US1.3 US2.1 |
| T4 | setup → play | US1.4 |
| T5 | setup → mode-pick | US1.5 |
| T6 | play → result | US1.6 US2.3 |
| T7 | result → setup | US1.7 |
| T8 | result → mode-pick | US1.8 |
| T9 | leave stream | US1.9 US2.4 |
| N1 | new session | US1.10 |
| N2 | interrupt resume | US1.11 US1.12 |

US2 scenarios live in [`navigation-conditions.md`](navigation-conditions.md).

## US1: Screen map

As Bottom player, I move between screens so that modes and results connect.

### US1.1: T1

- **Proves**: T1

```gherkin
Given Bottom player is on mode-pick
When Bottom activates UI-mode-pick.C1
Then the screen is shared-setup
```

### US1.2: T2

- **Proves**: T2

```gherkin
Given Bottom player is on mode-pick
When Bottom activates UI-mode-pick.C2
Then the screen is puzzle-play
```

### US1.3: T3

- **Proves**: T3

```gherkin
Given Bottom player is on mode-pick S3 quit confirm
When Bottom activates Confirm
Then the session ends
```

### US1.4: T4

- **Proves**: T4

```gherkin
Given Bottom player is on shared-setup
When Bottom activates UI-shared-setup.C5
Then the screen is shared-play
```

### US1.5: T5

- **Proves**: T5

```gherkin
Given Bottom player is on shared-setup
When Bottom activates UI-shared-setup.C6
Then the screen is mode-pick
```

### US1.6: T6

- **Proves**: T6

```gherkin
Given shared-play and GS.gameEnded becomes true
When the game end system event fires
Then the screen is shared-result
```

### US1.7: T7

- **Proves**: T7

```gherkin
Given Bottom player is on shared-result
When Bottom activates UI-shared-result.C1
Then the screen is shared-setup
```

### US1.8: T8

- **Proves**: T8

```gherkin
Given Bottom player is on shared-result
When Bottom activates UI-shared-result.C2
Then the screen is mode-pick
```

### US1.9: T9

- **Proves**: T9

```gherkin
Given Bottom player is on puzzle-play S2 leave confirm
When Bottom activates Confirm
Then the screen is mode-pick
```

### US1.10: N1

- **Proves**: N1

```gherkin
Given a new session starts
When the interface opens
Then the screen is mode-pick
```

### US1.11: N2 Shared interrupt

- **Proves**: N2

```gherkin
Given Shared play was open and the tab refreshed
When the session reopens
Then the screen is mode-pick
```

### US1.12: N2 Puzzle interrupt

- **Proves**: N2

```gherkin
Given Puzzle play was open and the tab refreshed
When the session reopens
Then the screen is mode-pick
```

