# Stories: Shared session

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`journeys/shared-session.md`](../../journeys/shared-session.md)
- **Spec key**: `J-shared-session`
- **Glossary terms**: [Journey](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| N1 | Start mode-pick | US1.1 |
| N2 | Exit stop or play again | US1.2 US1.3 |
| S1 | Shared game | US1.1 |
| S2 | Start | US1.1 |
| S3 | Resign to result | US1.5 |
| S4 | Stop | US1.2 |
| B1 | Play again | US1.3 |
| B2 | Setup back | US1.4 |

## US1: Shared path

As Bottom player, I walk Shared session so that a game can finish and restart.

### US1.1: Into play

- **Proves**: N1, S1, S2

```gherkin
Given Bottom player opens a session on mode-pick
When Bottom activates UI-mode-pick.C1
Then the screen is shared-setup
When Bottom activates UI-shared-setup.C5
Then the screen is shared-play
```

### US1.2: Stop after result

- **Proves**: N2, S4

```gherkin
Given Bottom player is on shared-result after a finished game
When Bottom activates Stop
Then the screen is mode-pick
```

### US1.3: Play again

- **Proves**: N2, B1

```gherkin
Given Bottom player is on shared-result
When Bottom activates Play again
Then the screen is shared-setup
```

### US1.4: Back from setup

- **Proves**: B2

```gherkin
Given Bottom player is on shared-setup before Start
When Bottom activates Back
Then the screen is mode-pick
```

### US1.5: Resign to result

- **Proves**: S3

```gherkin
Given Bottom player is on shared-play S1 and Bottom seat is side to move
When Bottom activates UI-shared-play.C4 and then activates Confirm
Then the screen is shared-result
```

