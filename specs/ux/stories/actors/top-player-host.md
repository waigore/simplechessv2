# Stories: Top player other screens

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/top-player.md`](../../actors/top-player.md)
- **Spec key**: `ACT-top-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

Part of [`top-player.md`](top-player.md). The coverage table lives there.

## US3: Whoever touches mode, setup, and result

As Top player, I operate mode, setup, and result controls so that a touch is enough.

### US3.1: Mode pick Shared game

- **Proves**: C5

```gherkin
Given Top player is on mode-pick S1
When Top activates UI-mode-pick.C1
Then the screen is shared-setup
```

### US3.2: Setup Start

- **Proves**: C5

```gherkin
Given Top player is on shared-setup S1
When Top activates UI-shared-setup.C5
Then the screen is shared-play
```

### US3.3: Result Play again

- **Proves**: C5

```gherkin
Given Top player is on shared-result S1
When Top activates UI-shared-result.C1
Then the screen is shared-setup
```

### US3.4: Puzzle stream from mode pick

- **Proves**: C5

```gherkin
Given Top player is on mode-pick S1
When Top activates UI-mode-pick.C2
Then the screen is puzzle-play
```

### US3.5: Quit from mode pick

- **Proves**: C5

```gherkin
Given Top player is on mode-pick S1
When Top activates UI-mode-pick.C3
Then EX.confirm shows End this session?
```

### US3.6: Switch locale from mode pick

- **Proves**: C5

```gherkin
Given Top player is on mode-pick S1 and GS.locale is en
When Top activates UI-mode-pick.C4
Then R3 shows 繁體中文
```

### US3.7: White seat on setup

- **Proves**: C5

```gherkin
Given Top player is on shared-setup S1 and GS.whiteSeat is Bottom player
When Top activates UI-shared-setup.C1
Then GS.whiteSeat is Top player
```

### US3.8: Clock on setup

- **Proves**: C5

```gherkin
Given Top player is on shared-setup S1 and GS.clock is Untimed
When Top activates UI-shared-setup.C2
Then GS.clock is Blitz
```

### US3.9: Increment on setup

- **Proves**: C5

```gherkin
Given Top player is on shared-setup S1 and GS.clock is Blitz and GS.increment is 3 s
When Top activates UI-shared-setup.C3
Then GS.increment is 5 s
```

### US3.10: Advice on setup

- **Proves**: C5

```gherkin
Given Top player is on shared-setup S1 and GS.advice is On
When Top activates UI-shared-setup.C4
Then GS.advice is Off
```

### US3.11: Back from setup

- **Proves**: C5

```gherkin
Given Top player is on shared-setup S1
When Top activates UI-shared-setup.C6
Then the screen is mode-pick S1
```

### US3.12: Stop from result

- **Proves**: C5

```gherkin
Given Top player is on shared-result S1
When Top activates UI-shared-result.C2
Then the screen is mode-pick S1
```
