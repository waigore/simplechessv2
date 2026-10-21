# Notes

Headless acceptance playtest for #53 against `CMP-chess-rules` on merged `main` (Godot 4.7.2). Scenarios load via `load_position` / `reset_opening` on the domain position (`SIT.1` / DBG.3 equivalents owned by earlier seams).

## PTD-pieces-king

- **S1**: King one-square steps legal; multi-square rejected (`I12`).
- **S2**: Kingside and queenside castling when rights hold; king and rook landings match `I13`–`I15`.
- **S3**: Castling refused when king/rook moved (`I16`/`I17`/`P4`), path or destination occupied (`I18`, including own/enemy on `g1`/`g8`), in check (`I19`), or through/into check (`I20`). Refused castle leaves F1/F2 unchanged (`I21`).
- **S4**: After a legal castle, that side's castling rights clear (`I22`).

Independent probe from the prior verification fail: after `e2-e4`, `e7-e5`, `f1-e2`, `b8-c6`, `legal_targets("e1")` does not offer `g1` and `try_move("e1","g1")` is false; the knight on `g1` remains.

## PTD-pieces-officers

- **S1–S2**: Rook/bishop/queen slide along empty rays; stop before own piece; capture first enemy; cannot jump (`I23`–`I26`).
- **S3–S4**: Knight L-jumps with capture on landing; queen combines rook+bishop rays (`I24`, `I27`).

## PTD-pieces-pawn

- **S1**: Single push on empty; double from start rank only when clear (`I28`, `I29`).
- **S2**: Diagonal capture only; forward capture illegal (`I30`). Black forward per `I2` / `common.md` PS1.10.
- **S3**: En passant removes the passed pawn from its own square (`I3`, `I31`); available only the move after the double step (`I32`); `I9` / PS1.3 pseudo-legal before the self-check filter.
- **S4**: Promotion to Q/R/B/N of the mover's color before the move ends (`I33`, `I34`); no pawn left on the last rank; king promotion refused.

## Suite

`python3 .github/scripts/gdscript_tests.py test` — 6 headless unit tests passed (includes the three PTD checks above). Checkmate/stalemate/`END.*`/`O3`/`F6` remain out of scope (#54). Promotion chooser UI remains out of scope (#94).
