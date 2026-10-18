# Protocol: Exceptions

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-exceptions`
- **Environment**: Headless and Graphical
- **Cites**: `EX`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Trigger offline while Advice On in Shared; confirm calm clear of advice UI. |
| S2 | Trigger illegal move attempt; confirm no crash and clear rejection feedback per EX. |
| S3 | Interrupt leave/resign confirm with cancel; remain on prior screen. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Exception stories in `EX` hold without trapping the actor. |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Exception crashes, traps, or skips required confirm | yes |

## Evidence

Default evidence rules. Graphical: screenshot exception/confirm states.
