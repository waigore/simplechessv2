# Piece rules — king and castling

Authoring rules: [`.agents/specs/rules/design/entities.md`](../../../../.agents/specs/rules/design/entities.md).

## Purpose

N/A — split from [`pieces.md`](../pieces.md). Attack and legality: [common.md](common.md).

## Properties

N/A — split from [`pieces.md`](../pieces.md).

## Lifecycle and states

N/A — split from [`pieces.md`](../pieces.md).

## Interactions

### King non-castling move

- **I12**: The king moves exactly one square in any direction to an empty square or one with an opponent piece (capture). It may not move onto a square attacked by the opponent.

### Castling — form

- **I13**: Castling is one king move that also moves one rook of the same color. The king moves exactly two squares toward that rook along rank 1 (White) or 8 (Black). The rook moves to the square the king crossed.
- **I14**: **Kingside**: White e1→g1 and h1→f1. Black e8→g8 and h8→f8.
- **I15**: **Queenside**: White e1→c1 and a1→d1. Black e8→c8 and a8→d8.

### Castling — conditions (all required)

- **I16**: The king has not moved earlier (`P4` false).
- **I17**: The rook involved has not moved (`P4` false) and is the a- or h-file rook named in I14/I15.
- **I18**: Every square between king and that rook on the rank is empty.
- **I19**: The king is not currently in check.
- **I20**: The square the king crosses and the square it ends on are not attacked by the opponent. The rook's start square may be attacked. On queenside, White b1 / Black b8 may be attacked.
- **I21**: If any of I16–I20 fail, castling is illegal. No castling with a promoted rook or a rook that only later reached the corner. No Chess960 castling.

### After castling

- **I22**: King and rook both have moved (`P4` true). Castling rights for that side are gone for repetition accounting.

## Placement and availability

N/A — split from [`pieces.md`](../pieces.md).

## Experience intent

N/A — split from [`pieces.md`](../pieces.md).
