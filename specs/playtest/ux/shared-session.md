# Protocol: Shared session journey

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-shared-session`
- **Environment**: Headless and Graphical
- **Cites**: `J-shared-session` (N1–N2, S1–S4, B1–B2)
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | From mode-pick, Shared game → setup → Start → shared-play. |
| S2 | End or resign to shared-result; Stop → mode-pick. |
| S3 | Replay path: Play again → shared-setup. |
| S4 | From setup, Back → mode-pick. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Journey screens and branches match `J-shared-session`. |
| P2 | Headless and Graphical both pass the same control outcomes. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Wrong screen after a journey control | yes |
| F2 | Passes in only one environment | yes |

## Evidence

Default evidence rules. Graphical: screenshot each judged screen.
