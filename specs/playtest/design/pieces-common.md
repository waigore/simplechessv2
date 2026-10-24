# Protocol: Pieces common

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-pieces-common`
- **Environment**: `ENV.1` Headless only
- **Cites**: `E-pieces` common (I1–I11 board, capture, check, legality) and identity/lifecycle (P1–P4, S1–S3, Placement)
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | `DBG.3` scenarios for occupied destination capture vs blocked path. |
| S2 | Attempt move that leaves own king in check; confirm illegal. |
| S3 | Deliver check; confirm side-to-move and legality for escapes. |
| S4 | Attempt move onto own piece; confirm illegal. |
| S5 | Confirm only legal destinations accepted for a selected piece. |
| S6 | `DBG.3` orthodox opening; `DBG.2` inspect the white e2 pawn and e1 king: confirm P1 color, P2 type, P3 origin square, S1 on board, and P4 false. |
| S7 | `DBG.3` a position where a king has P4 true while its castling path and other rights hold; attempt kingside castling; confirm illegal. |
| S8 | `DBG.3` a pawn on e3 with P4 true and e4 empty; attempt e3→e5; confirm illegal. |
| S9 | Capture a piece; `DBG.2` confirm the captured unit is S2, then make a legal move and confirm it stays out of play. |
| S10 | Promote a pawn that reaches the last rank; confirm S3 until Q, R, B, or N is chosen, then S1 as the chosen type. |
| S11 | `DBG.3` orthodox opening; confirm Placement: White ranks 1–2, Black 7–8, back-rank order R N B Q K B N R, pawns on the rank in front. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Capture, check, and self-check rules match common piece stories. |
| P2 | Illegal attempts leave position and clocks unchanged. |
| P3 | P1–P4, S1–S3, and orthodox Placement match their stories; a captured unit is out of play and a promoting pawn cannot end its move before choosing a type. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Illegal move accepted or legal capture rejected | yes |
| F2 | A unit reports the wrong color, type, origin square, or moved flag, a captured unit stays on the board, or promotion resolves without a chosen type | yes |

## Evidence

Default evidence rules ([`evidence.md`](../evidence.md)). The protocol states no extras and waives no screenshot.
