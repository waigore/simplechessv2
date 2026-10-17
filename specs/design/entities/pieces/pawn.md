# Piece rules — pawn, en passant, promotion

Authoring rules: [`.agents/specs/rules/design/entities.md`](../../../../.agents/specs/rules/design/entities.md).

## Purpose

N/A — split from [`pieces.md`](../pieces.md). Forward direction: [common.md](common.md) I2.

## Properties

N/A — split from [`pieces.md`](../pieces.md).

## Lifecycle and states

N/A — split from [`pieces.md`](../pieces.md) (promoting state S3).

## Interactions

### Non-capturing moves

- **I28**: One square straight forward to an empty square.
- **I29**: If the pawn has not moved (`P4` false) and is on its starting rank (White 2, Black 7), it may move two squares forward when both the intermediate and destination squares are empty. After any pawn move, `P4` is true.

### Capturing moves

- **I30**: Captures one square diagonally forward onto an opponent piece and removes it ([common.md](common.md) I3).

### En passant

- **I31**: When an opponent pawn has just moved two squares (I29) and lands adjacent on the same rank beside a pawn of the side to move, that pawn may, on the immediately following move only, capture **en passant**: move to the square the opponent pawn passed through, and remove the opponent pawn from its arrival square.
- **I32**: If any other move is played, the en passant right expires. En passant counts as a capture for the fifty-move rule.

### Promotion

- **I33**: When a pawn reaches the last rank (White 8, Black 1) by I28 or I30, as part of the same move it must be replaced by a queen, rook, bishop, or knight of the same color. The player chooses. It may not stay a pawn or become a king.
- **I34**: Underpromotion is allowed. The new piece counts as having moved. Promotion finishes before the opponent's turn and before check is evaluated on the resulting position.

## Placement and availability

N/A — split from [`pieces.md`](../pieces.md).

## Experience intent

N/A — split from [`pieces.md`](../pieces.md).
