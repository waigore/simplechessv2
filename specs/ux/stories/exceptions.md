# Stories: Exceptions

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`exceptions.md`](../exceptions.md)
- **Spec key**: `EX`
- **Glossary terms**: [Exception](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| EX.loading | Cold open | US1.1 |
| EX.confirm | Destructive confirm | US1.2 US1.7 |
| EX.interrupt | Resume mode-pick | US1.3 |
| EX.save-failure | Prior commit kept | US1.4 |
| EX.error | Dismiss continue | US1.5 |
| EX.unsupported-input | Non-touch | US1.6 |

## US1: Shared exceptions

As Bottom player, I see shared failure and confirm patterns so that recovery is clear.

### US1.1: Loading

- **Proves**: EX.loading

```gherkin
Given cold open before the board is playable
When the interface loads
Then EX.loading is shown until mode-pick S1
```

### US1.2: Confirm cancel

- **Proves**: EX.confirm

```gherkin
Given EX.confirm resign is shown
When the actor activates Cancel
Then the prior screen state returns
```

### US1.3: Interrupt

- **Proves**: EX.interrupt

```gherkin
Given Shared play was open and the session refreshed
When the sitting reopens
Then the screen is mode-pick
```

### US1.4: Save failure

- **Proves**: EX.save-failure

```gherkin
Given a failed Elo write shows EX.save-failure
When the actor dismisses
Then the previous committed Elo remains
```

### US1.5: Error

- **Proves**: EX.error

```gherkin
Given EX.error after Advice fetch failed on shared-play
When the actor dismisses
Then shared-play remains usable for local moves
```

### US1.6: Unsupported input

- **Proves**: EX.unsupported-input

```gherkin
Given Web play and a non-touch primary input is used
When that input targets a play control
Then EX.unsupported-input is shown and the control does not activate
```

### US1.7: Confirm shown on resign

- **Proves**: EX.confirm

```gherkin
Given the side-to-move actor is on shared-play S1
When that actor activates UI-shared-play.C4
Then EX.confirm is shown and names resign
```

