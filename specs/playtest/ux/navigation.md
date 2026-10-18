# Protocol: Navigation

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-navigation`
- **Environment**: Headless and Graphical
- **Cites**: `NAV`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Walk Shared and Puzzle entries from mode-pick per NAV transitions. |
| S2 | Use Back / Stop / Leave where defined; confirm destinations. |
| S3 | Confirm no dead-end screens without an exit control from NAV. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Transitions match `NAV` stories. |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Transition missing or lands on wrong screen | yes |

## Evidence

Default evidence rules.
