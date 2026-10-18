# Protocol: Progression

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-progression`
- **Environment**: Headless only
- **Cites**: `PRG` (A1, P1, P2, M1, F1, Z1–Z3)
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Solve a puzzle; quit; reopen; confirm Player Elo and Last mode committed (P1/P2/M1). |
| S2 | Confirm recent solved IDs cap (≤20) and affect deal avoidance when applicable. |
| S3 | Fail a puzzle; confirm stream continues (F1) and Elo commit rules. |
| S4 | Confirm Shared has no long-term progression axes (Z*). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Elo and Last mode persist across sittings per PRG. |
| P2 | Failure continues stream; Shared has no meta progression. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Persist fields missing after reopen or Shared invents progression | yes |

## Evidence

Default evidence rules (Headless: no screenshots).
