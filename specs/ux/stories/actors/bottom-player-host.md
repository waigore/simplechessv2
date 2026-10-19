# Stories: Bottom player host controls

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`actors/bottom-player.md`](../../actors/bottom-player.md)
- **Spec key**: `ACT-bottom-player`
- **Glossary terms**: [Actor](../../glossary.md)

## Coverage

Part of [`bottom-player.md`](bottom-player.md). The coverage table lives there.

## US3: Host controls on modes and setup

As Bottom player, I operate the mode and setup controls so that I can start the mode we want.

### US3.1: Puzzle stream from mode pick

- **Proves**: C1

```gherkin
Given Bottom player is on mode-pick S1
When Bottom activates UI-mode-pick.C2
Then the screen is puzzle-play
```

### US3.2: Quit from mode pick

- **Proves**: C1

```gherkin
Given Bottom player is on mode-pick S1
When Bottom activates UI-mode-pick.C3
Then EX.confirm shows End this session?
```

### US3.3: Switch locale from mode pick

- **Proves**: C1

```gherkin
Given Bottom player is on mode-pick S1 and GS.locale is en
When Bottom activates UI-mode-pick.C4
Then R3 shows 繁體中文
```

### US3.4: White seat on setup

- **Proves**: C1

```gherkin
Given Bottom player is on shared-setup S1 and GS.whiteSeat is Bottom player
When Bottom activates UI-shared-setup.C1
Then GS.whiteSeat is Top player
```

### US3.5: Clock on setup

- **Proves**: C1

```gherkin
Given Bottom player is on shared-setup S1 and GS.clock is Untimed
When Bottom activates UI-shared-setup.C2
Then GS.clock is Blitz
```

### US3.6: Increment on setup

- **Proves**: C1

```gherkin
Given Bottom player is on shared-setup S1 and GS.clock is Blitz and GS.increment is 3 s
When Bottom activates UI-shared-setup.C3
Then GS.increment is 5 s
```

### US3.7: Advice on setup

- **Proves**: C1

```gherkin
Given Bottom player is on shared-setup S1 and GS.advice is On
When Bottom activates UI-shared-setup.C4
Then GS.advice is Off
```

### US3.8: Back from setup

- **Proves**: C1

```gherkin
Given Bottom player is on shared-setup S1
When Bottom activates UI-shared-setup.C6
Then the screen is mode-pick S1
```
