# Protocol: Pawn

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-pieces-pawn`
- **Environment**: Headless only
- **Cites**: `E-pieces` pawn stories
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | Single push on empty; double push from start rank only when path clear. |
| S2 | Diagonal capture only; forward capture illegal. |
| S3 | En passant when applicable; unavailable otherwise. |
| S4 | Promotion on last rank; confirm chosen piece replaces pawn. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Push, capture, en passant, and promotion match pawn stories. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Illegal pawn move accepted or legal promotion/en passant denied | yes |

## Evidence

Default evidence rules (Headless: no screenshots).
