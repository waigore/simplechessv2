# Entity: Pieces

Authoring rules: [`.agents/specs/rules/design/entities.md`](../../../.agents/specs/rules/design/entities.md).

- **Kind**: object
- **Serves**: Clear board, Instant play. Scope: Shared game and Puzzle stream use the same piece rules.
- **Glossary terms**: [Piece](../glossary.md)

## Purpose

Define the board, every piece type, capture, check, and every legal move — including castling, en passant, and promotion — so legality is fully specified in this repo (FIDE Laws of Chess movement and check, without variants).

## Properties

| ID | Property | Meaning | Parameter |
|----|----------|---------|-----------|
| P1 | Color | White or Black | — (from `GS.position`) |
| P2 | Type | King, Queen, Rook, Bishop, Knight, or Pawn | — |
| P3 | Origin square | File and rank the piece occupies | — |
| P4 | Has moved | Whether this unit has moved earlier this game | — (castling / double-step rights) |

## Lifecycle and states

| ID | State | Entered when | Behavior in state | Exits to |
|----|-------|--------------|-------------------|----------|
| S1 | On board | Setup or promotion | May move per type rules | S2; S3 (pawn) |
| S2 | Captured | Opponent captures it | Out of play | — |
| S3 | Promoting | Pawn completes a move to the last rank | Must become Q, R, B, or N of the same color before the move ends | S1 as the new type |

## Interactions

| ID | Interacts with | Trigger | Outcome |
|----|----------------|---------|---------|
| I1–I11, I35 | Board and other pieces | Attempted move | [common.md](pieces/common.md): board, square colors, capture, attack, check, legality |
| I12–I22 | King and rook | King step or castling | [king.md](pieces/king.md) |
| I23–I27 | Queen, rook, bishop, knight | Officer move | [officers.md](pieces/officers.md) |
| I28–I34 | Pawn | Pawn move, en passant, or promotion | [pawn.md](pieces/pawn.md) |

Qualified IDs are `E-pieces.I1` … `E-pieces.I35`.

## Placement and availability

Shared-game start (orthodox opening): White ranks 1–2, Black 7–8; back rank a–h: rook, knight, bishop, queen, king, bishop, knight, rook; pawns on the rank in front. Puzzle stream: `GS.position` as dealt. No Chess960 or other variants.

## Experience intent

Piece types stay readable by shape (Clear board). A legal place completes at once on the device (Instant play).
