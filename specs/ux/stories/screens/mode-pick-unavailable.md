# Stories: Mode pick unavailable and state edges

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/mode-pick.md`](../../screens/mode-pick.md)
- **Spec key**: `UI-mode-pick`
- **Glossary terms**: [Screen](../../glossary.md)

## Coverage

Part of [`mode-pick.md`](mode-pick.md). The coverage table lives there. This file proves activate-while-unavailable for C1–C4, Confirm ending the session, and the S4 save-failure message.

## US1: Unavailable controls and state edges

As Bottom player, I tap a control that is not available so that the screen state does not change.

### US1.10: C1 unavailable in quit confirm

- **Proves**: C1

```gherkin
Given Bottom player is on mode-pick S3 quit confirm
When Bottom activates C1
Then the screen stays mode-pick and the quit confirm remains
```

### US1.11: C2 unavailable in quit confirm

- **Proves**: C2

```gherkin
Given Bottom player is on mode-pick S3 quit confirm
When Bottom activates C2
Then the screen stays mode-pick and the quit confirm remains
```

### US1.12: C3 unavailable in quit confirm

- **Proves**: C3

```gherkin
Given Bottom player is on mode-pick S3 quit confirm
When Bottom activates C3
Then no second confirm is shown and S3 stays
```

### US1.13: C4 unavailable in quit confirm

- **Proves**: C4

```gherkin
Given Bottom player is on mode-pick S3 quit confirm
When Bottom activates C4
Then GS.locale is unchanged and S3 stays
```

### US1.14: Confirm ends session

- **Proves**: S3

```gherkin
Given Bottom player is on mode-pick S3 quit confirm
When Bottom activates Confirm
Then the session ends
```

### US1.15: Save failure message

- **Proves**: S4

```gherkin
Given Bottom player is on mode-pick S1 and a Last mode write fails
When the persist-failure system event fires
Then S4 shows Save failed. Prior values kept. And C1–C4 are available
```
