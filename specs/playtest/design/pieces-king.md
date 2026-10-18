# Protocol: King and castling

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-pieces-king`
- **Environment**: Headless only
- **Cites**: `E-pieces` king (I12–I22)
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | `DBG.3` king step: one square legal; multi-square illegal. |
| S2 | Castling kingside and queenside when all rights hold; confirm rook and king landings. |
| S3 | Deny castling when king/rook moved, path occupied, in check, or through/into check. |
| S4 | After castling, confirm rights cleared. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | King step and castling form match I12–I22. |
| P2 | Any failed castling condition yields illegal; no partial rook/king move. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Castling allowed when a condition fails, or denied when all hold | yes |

## Evidence

Default evidence rules (Headless: no screenshots).
