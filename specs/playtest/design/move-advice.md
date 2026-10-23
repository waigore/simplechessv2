# Protocol: Move advice

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-move-advice`
- **Environment**: Headless only
- **Cites**: `F-move-advice` (R1–R9)
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Start Shared game with Advice On while online; wait for advice fields without blocking. |
| S2 | Complete a local move while advice stream is active; measure that move completes without waiting on advice. |
| S3 | Confirm advice clears after move and restarts for new side-to-move when R2 holds. |
| S4 | Turn Advice Off or go offline; confirm advice cleared and evaluation stops. |
| S5 | Enter Puzzle stream; confirm no advice applies (R1). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Local move never waits on advice traffic (`TEL` / timing). |
| P2 | Advice only when On + online in Shared; cleared on Off/offline/end/puzzle. |
| P3 | Best move / eval target side-to-move only; time-capped search. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Local move blocked by advice | yes |
| F2 | Advice appears in Puzzle stream or when Off/offline | yes |

## Evidence

Default evidence rules. Log timing for P1.
