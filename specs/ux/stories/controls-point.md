# Stories: Controls point and focus

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`controls.md`](../controls.md)
- **Spec key**: `IN`
- **Glossary terms**: [Binding](../glossary.md)

## Coverage

Part of [`controls.md`](controls.md). The coverage table lives there. This file proves `IN.point`, B7, and F1 on each screen with one input per scenario.

## US3: Web point and focus order

As an actor on Web, I move the pointer so `IN.point` fires and focus order matches that screen.

### US3.1: Mode-pick

- **Proves**: IN.point, B7, F1

```gherkin
Given mode-pick S1 on Web
When the actor moves the pointer over Shared game
Then IN.point activates and no other action activates and focus order follows C1 then C2 then C3 then C4
```

### US3.2: Shared-setup

- **Proves**: IN.point, B7, F1

```gherkin
Given shared-setup S1 on Web
When the actor moves the pointer over White seat
Then IN.point activates and no other action activates and focus order follows C1 then C2 then C3 then C4 then C5 then C6
```

### US3.3: Shared-play

- **Proves**: IN.point, B7, F1

```gherkin
Given shared-play S1 on Web
When the actor moves the pointer over Advice
Then IN.point activates and no other action activates and focus order follows C1 then C10 then C2 then C3 then C4 then C5 then C6 then C7 then C8 then C9
```

### US3.4: Shared-result

- **Proves**: IN.point, B7, F1

```gherkin
Given shared-result S1 on Web
When the actor moves the pointer over Play again
Then IN.point activates and no other action activates and focus order follows C1 then C2
```

### US3.5: Puzzle-play

- **Proves**: IN.point, B7, F1

```gherkin
Given puzzle-play S1 on Web
When the actor moves the pointer over Reveal
Then IN.point activates and no other action activates and focus order follows C1 then C2 then C3 then C4 then C5 then C6
```
