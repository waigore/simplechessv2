# Protocol: Navigation

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-navigation`
- **Environment**: Headless and Graphical
- **Cites**: `NAV.US1`, `NAV.US2`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Walk Shared and Puzzle entries from mode-pick per `NAV.US1` transitions. |
| S2 | Use Back / Stop / Leave where defined; confirm destinations per `NAV.US1` and that Cancel stays put per `NAV.US2`. |
| S3 | Confirm no dead-end screens without an exit control from `NAV.US1`. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Transitions match `NAV.US1`; guarded transitions stay put per `NAV.US2`. |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Transition missing or lands on wrong screen | yes |

## Evidence

Default evidence rules.
