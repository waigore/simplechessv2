# Protocol: Pieces common

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-pieces-common`
- **Environment**: Headless only
- **Cites**: `E-pieces` common (I1–I11 board, capture, check, legality)
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | `DBG.3` scenarios for occupied destination capture vs blocked path. |
| S2 | Attempt move that leaves own king in check; confirm illegal. |
| S3 | Deliver check; confirm side-to-move and legality for escapes. |
| S4 | Attempt move onto own piece; confirm illegal. |
| S5 | Confirm only legal destinations accepted for a selected piece. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Capture, check, and self-check rules match common piece stories. |
| P2 | Illegal attempts leave position and clocks unchanged. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Illegal move accepted or legal capture rejected | yes |

## Evidence

Default evidence rules.
