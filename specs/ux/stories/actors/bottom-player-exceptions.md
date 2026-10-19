# Stories: Bottom player exception controls

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/bottom-player.md`](../../actors/bottom-player.md)
- **Spec key**: `ACT-bottom-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

Part of [`bottom-player.md`](bottom-player.md). The coverage table lives there.

## US5: Exceptions

As Bottom player, I confirm or cancel an exception so that the action I chose does or does not run.

### US5.1: Cancel resign

- **Proves**: C3

```gherkin
Given Bottom player is on shared-play S2 EX.confirm resign
When Bottom activates Cancel
Then the screen is shared-play S1
```

### US5.2: Confirm resign

- **Proves**: C3

```gherkin
Given Bottom player is on shared-play S2 EX.confirm resign
When Bottom activates Confirm
Then the screen is shared-result
```
