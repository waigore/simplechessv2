# Glossary — chess terms

Authoring rules: [`.agents/specs/rules/design/glossary.md`](../../../.agents/specs/rules/design/glossary.md).

Part of [`glossary.md`](../glossary.md).

| Term | Definition | Detailed in |
|------|------------|-------------|
| Castling | One king move that also moves the same-color rook, under its conditions | [`entities/pieces/king.md`](../entities/pieces/king.md) |
| Check | The side to move's king is attacked | [`entities/pieces/common.md`](../entities/pieces/common.md) |
| Checkmate | Side to move is in check and has no legal move (Shared-game loss) | [`end-conditions.md`](../end-conditions.md) |
| En passant | Pawn capture of an opponent pawn that just moved two squares, on the next move only | [`entities/pieces/pawn.md`](../entities/pieces/pawn.md) |
| Fifty-move rule | Draw after fifty moves each with no capture and no pawn move | [`end-conditions.md`](../end-conditions.md) |
| Legal move | Pseudo-legal piece move; mover's king not left in check | [`entities/pieces/common.md`](../entities/pieces/common.md) |
| Piece | King, queen, rook, bishop, knight, or pawn | [`entities/pieces.md`](../entities/pieces.md) |
| Promotion | A pawn reaching the last rank must become a queen, rook, bishop, or knight | [`entities/pieces/pawn.md`](../entities/pieces/pawn.md) |
| Side to move | The color whose turn it is to move | [`loops/two-player-game.md`](../loops/two-player-game.md) |
| Stalemate | Side to move is not in check and has no legal move (draw) | [`end-conditions.md`](../end-conditions.md) |
| Threefold repetition | Draw when same position, side to move, and rights occur thrice | [`end-conditions.md`](../end-conditions.md) |
