# Stories: Navigation conditions

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`navigation.md`](../navigation.md)
- **Spec key**: `NAV`
- **Glossary terms**: [Screen](../glossary.md)

## Coverage

Part of [`navigation.md`](navigation.md) stories; the coverage table lives there. This file proves the fail-stay legs of conditioned transitions. Whoever touches a transition may use it, so no seat is refused.

## US2: Transition guards

As Bottom or Top player, I stay put when a transition does not apply so that navigation is predictable.

### US2.1: T3 fail-stay

- **Proves**: T3

```gherkin
Given Bottom player is on mode-pick S3 quit confirm
When Bottom activates Cancel
Then the screen stays mode-pick and the session does not end
```

### US2.3: T6 fail-stay

- **Proves**: T6

```gherkin
Given shared-play S2 resign confirm and GS.gameEnded is false
When the actor activates Cancel
Then the screen stays shared-play
```

### US2.4: T9 fail-stay

- **Proves**: T9

```gherkin
Given Bottom player is on puzzle-play S2 leave confirm
When Bottom activates Cancel
Then the screen stays puzzle-play
```

### US2.6: T1 unavailable in loading

- **Proves**: T1

```gherkin
Given mode-pick S2 EX.loading
When Bottom activates UI-mode-pick.C1
Then the screen stays mode-pick
```

### US2.7: T2 unavailable in loading

- **Proves**: T2

```gherkin
Given mode-pick S2 EX.loading
When Bottom activates UI-mode-pick.C2
Then the screen stays mode-pick
```
