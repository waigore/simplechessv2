# Stories: Shared setup

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/shared-setup.md`](../../screens/shared-setup.md)
- **Spec key**: `UI-shared-setup`
- **Glossary terms**: [White seat](../../../design/glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Options visibility | US1.1 US1.2 |
| R2 | Actions | US1.3 |
| C1 | White seat | US1.4 |
| C2 | Clock | US1.5 |
| C3 | Increment when timed | US1.6 US1.7 |
| C4 | Advice | US1.8 |
| C5 | Start | US1.3 |
| C6 | Back | US1.9 |
| S1 | Default | US1.1 US1.2 |

## US1: Configure and start

As Bottom player, I set options so that the Shared game matches our choice.

### US1.1: Options shown

- **Proves**: R1, S1

```gherkin
Given Bottom player opens shared-setup and GS.whiteSeat is Bottom player and GS.clock is Blitz and GS.increment is 3 s and GS.advice is On
When the interface opens
Then the screen is shared-setup S1 And R1 shows GS.whiteSeat Bottom player, GS.clock Blitz, GS.increment 3 s, and GS.advice On And C1–C6 are available
```

### US1.2: Increment hidden when Untimed

- **Proves**: R1, S1

```gherkin
Given Bottom player opens shared-setup and GS.whiteSeat is Top player and GS.clock is Untimed and GS.increment is 3 s and GS.advice is Off
When the interface opens
Then the screen is shared-setup S1 And R1 shows GS.whiteSeat Top player, GS.clock Untimed, and GS.advice Off And Increment is not visible in R1 And C1, C2, C4, C5, and C6 are available And C3 is unavailable
```

### US1.3: Start

- **Proves**: R2, C5

```gherkin
Given Bottom player is on shared-setup S1
When Bottom activates C5
Then the screen is shared-play
```

### US1.4: White seat cycles

- **Proves**: C1

```gherkin
Given Bottom player is on shared-setup and GS.whiteSeat is Bottom player
When Bottom activates C1
Then GS.whiteSeat is Top player
```

### US1.5: Clock cycles

- **Proves**: C2

```gherkin
Given Bottom player is on shared-setup and GS.clock is Untimed
When Bottom activates C2
Then GS.clock is Blitz
```

### US1.6: Increment when timed

- **Proves**: C3

```gherkin
Given Bottom player is on shared-setup and GS.clock is Blitz and GS.increment is 3 s
When Bottom activates C3
Then GS.increment is 5 s
```

### US1.7: Increment unavailable Untimed

- **Proves**: C3

```gherkin
Given Bottom player is on shared-setup and GS.clock is Untimed
When Bottom activates C3
Then GS.increment is unchanged
```

### US1.8: Advice toggle

- **Proves**: C4

```gherkin
Given Bottom player is on shared-setup and GS.advice is On
When Bottom activates C4
Then GS.advice is Off
```

### US1.9: Back

- **Proves**: C6

```gherkin
Given Bottom player is on shared-setup S1
When Bottom activates C6
Then the screen is mode-pick
```

