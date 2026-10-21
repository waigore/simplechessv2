# Notes

Headless `PTD-pieces-common` S1–S5 against `CMP-chess-rules`. Scenarios were loaded on the domain position because this task does not own session jump (`DBG.3`).

- **S1**: White knight c3 captures the black pawn on d5. White rook a1 steps to a2 and is rejected on a4, blocked by the piece on a3. Position stays put on the reject.
- **S2**: White king e4→e5 walks onto the black rook's rank and is rejected. F1 and F2 stay unchanged.
- **S3**: White rook a2→e2 checks the black king. Side to move becomes Black. e8→e7 is rejected. e8→d8 is legal and the side returns to White.
- **S4**: White rook a4→e4 onto a white pawn is rejected. Position unchanged.
- **S5**: For the selected rook on a1, every square in `legal_targets` is accepted and every other square is rejected.

Clocks are `SCH-play-state` F3 and belong to the session. This run leaves them untouched. Passes P1 and P2 for the position. Castling, en passant, and promotion stay on #53. Mate and stalemate stay on #54.
