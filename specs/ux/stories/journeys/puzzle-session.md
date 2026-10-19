# Stories: Puzzle session

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`journeys/puzzle-session.md`](../../journeys/puzzle-session.md)
- **Spec key**: `J-puzzle-session`
- **Glossary terms**: [Journey](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| N1 | Start mode-pick | US1.1 |
| N2 | End mode-pick | US1.2 |
| S1 | Enter puzzle | US1.1 |
| S2 | Leave confirmed | US1.2 |
| B1 | Cancel leave | US1.3 |

## US1: Puzzle path

As Bottom player, I enter and leave the stream so that practice fits one session.

### US1.1: Enter

- **Proves**: N1, S1

```gherkin
Given Bottom player is on mode-pick
When Bottom activates Puzzle stream
Then the screen is puzzle-play
```

### US1.2: Leave

- **Proves**: N2, S2

```gherkin
Given Bottom player is on puzzle-play
When Bottom activates Leave stream and Confirm
Then the screen is mode-pick
```

### US1.3: Cancel leave

- **Proves**: B1

```gherkin
Given leave confirm is open on puzzle-play
When Bottom activates Cancel
Then the screen stays puzzle-play
```

