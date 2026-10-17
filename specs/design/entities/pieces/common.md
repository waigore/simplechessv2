# Piece rules — board, capture, attack, check, legality

Authoring rules: [`.agents/specs/rules/design/entities.md`](../../../../.agents/specs/rules/design/entities.md).

## Purpose

N/A — split from [`pieces.md`](../pieces.md). Interaction IDs are `E-pieces.I*`.

## Properties

N/A — split from [`pieces.md`](../pieces.md).

## Lifecycle and states

N/A — split from [`pieces.md`](../pieces.md).

## Interactions

### Board

- **I1**: The board is an 8×8 grid. Files a–h (White's left to right). Ranks 1–8 (White's near to far). Each square holds at most one piece.
- **I2**: White's pieces start toward rank 1; Black's toward rank 8. A pawn's forward direction is toward the opponent (White +rank, Black −rank).
- **I35**: Every square is light or dark; orthogonally adjacent squares differ. Square a1 is dark. With files a=1 … h=8, a square is dark when file index + rank is even, otherwise light.

### Capture

- **I3**: A capture lands on a square occupied by an opponent piece and removes that piece in the same move, except en passant ([pawn.md](pawn.md)), which removes the passed pawn from its square.
- **I4**: A move onto a friendly piece is illegal. The king is never captured; an end condition occurs first.

### Attacked squares

- **I5**: A side **attacks** a square if it has a piece that could capture an opposing piece there by its movement rules (pawn captures count; non-capturing pawn steps do not), treating the target as enemy-occupied for the test. Sliders attack through empty squares only; they attack the first occupied square on a ray, not beyond.
- **I6**: When testing attack, ignore whether the attacker would leave its own king in check. Knights jump. Kings attack every adjacent square.

### Check

- **I7**: The side to move is **in check** when their king sits on a square attacked by the opponent (including discovered and double check).
- **I8**: A player may never leave their own king in check (includes moving out of a pin illegally, and castling through or into check).

### Legal move

- **I9**: A **pseudo-legal** move is one movement of one piece of the side to move matching [king.md](king.md), [officers.md](officers.md), or [pawn.md](pawn.md) (including castling, en passant, and promotion).
- **I10**: A **legal move** is a pseudo-legal move after which the mover's king is not in check. No legal move while in check is checkmate; while not in check is stalemate ([end-conditions.md](../../end-conditions.md)).
- **I11**: Only the side to move may move. One legal move is a turn (resign and draw offers are elsewhere). An illegal attempt changes nothing.

## Placement and availability

N/A — split from [`pieces.md`](../pieces.md).

## Experience intent

N/A — split from [`pieces.md`](../pieces.md).
