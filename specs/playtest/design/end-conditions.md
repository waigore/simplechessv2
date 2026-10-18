# Protocol: End conditions

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-end-conditions`
- **Environment**: Headless only
- **Cites**: `END` (L1–L5, D1–D5, W1, P1)
- **Situational tools**: `SIT.1`, `SIT.3`

## Steps

| ID | Action |
|----|--------|
| S1 | `DBG.3` to checkmate position; complete mating move; confirm L1 win/loss. |
| S2 | Resign as side to move; confirm L2. |
| S3 | `DBG.3` to stalemate / agreement / repetition / fifty-move setups; confirm draws D1–D4 as applicable. |
| S4 | Blitz: force clock to zero with mate material vs without; confirm L3 vs D5. |
| S5 | Puzzle: solve W1; fail L4 after wrong then complete; reveal L5; confirm mutual exclusion. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Precedence P1 holds: position endings before clock; clocks stop on end. |
| P2 | Shared endings match L*/D* tables; puzzle W1/L4/L5 never true together. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Wrong ending applied or clocks keep running after end | yes |
| F2 | Puzzle win and fail marks collide | yes |

## Evidence

Default evidence rules (Headless: no screenshots). Include `SIT.3` dump on fail.
