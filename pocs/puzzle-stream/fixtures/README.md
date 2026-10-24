# Puzzle stream demo — recorded-format fixture slice

This is the **fixture slice** the demo stands in for the host-served
snapshot. It is not a Lichess export and not a catalog inventory: it holds a
few records in the recorded format of [`SCH-puzzle-catalog`](../../../specs/technical/schemata/puzzle-catalog.md)
F1–F13, so `catalog_service.gd` reads them exactly as it would read records
served by the host (ADR-0008: the catalog stays on the host and is not shipped
in the client; `F-puzzle-catalog` R1).

The demo changes no host decision: it reads this slice through the one-record
read `CTR-puzzle-catalog-read` describes, the slice is never parsed into Elo
bands and never sized to a sitting (`F-puzzle-catalog` R2), and
`GS.recentSolved` still stores `puzzle_id` only (`I3`). If the demo cannot read
the slice, no puzzle is dealt — `X2`; the autodrive shows that by pointing the
same reader at a path that does not exist (`fixtures/missing-slice.txt`), with
no special marker in this file.

## File format

- First line: `# snapshot_id 2026-10-05` (F1; ADR-0008 fixes the snapshot the
  demo was recorded against). A slice file holds exactly one snapshot.
- One JSON object per line after it with the record fields F2–F13.
  `any_checkmate_wins` (F13) is optional and derived from `themes` (F9) when
  absent, as `I3` requires; here it is written explicitly so the fixture stays
  readable by hand.
- `moves` (F4) is the recorded line as UCI. The **first** move is the
  opponent's move that leads into the puzzle; the presented position is the
  position after it, and the solving side is the side to move there. The
  remaining moves are the Required sequence (`I2`), alternating solving side
  and opponent.

## The records and what each one exercises

| Id | Rating | What it exercises |
|----|--------|-------------------|
| `demo0001` | 900 | The common case: a three-step required sequence, so the solving side moves, the game plays the required reply at once (`L-puzzle-stream` K2), and the player moves again. Also the Wrong-move reset (K2) and both outcomes from one record (`W1` clean, `L4` after a Wrong move). |
| `demo0002` | 1010 | The mate-in-one exception (`F-puzzle-catalog` R5): the presented position has two legal checkmating moves and either matches the step. |
| `demo0003` | 1150 | Black is the solving side (so `CAM-board.M2` orientation is exercised) and the rating sits outside the ±`CFG.ELO_MATCH_RANGE` window around `CFG.ELO_START` = 1000, so dealing it needs the widen step of `PS1.8`. |
| `demo0004` | 960 | A second puzzle inside the ±100 window (`I1`) with a three-step sequence and a capture at the end, so `GS.Q1` has more than one in-band candidate and a band deal is not forced to one record. |

## Records

Positions were checked against the demo's own `chess_rules.gd`: every `moves`
line is legal in order with the right side to move, the presented position of
`demo0002` has two legal checkmating moves (so `R5` is observable rather than
vacuous), and the other records end on the solving side's last move. The
autodrive replays them through the same read path on every run.

| puzzle_id | fen (before the opponent move) | moves | rating | themes |
|-----------|--------------------------------|-------|--------|--------|
| `demo0001` | `3q1k1r/pp4pp/8/2N5/8/8/8/6K1 b - - 0 1` | `a7a6 c5e6 f8g8 e6d8` | 900 | `fork`, `short` |
| `demo0002` | `6k1/5ppp/8/7n/8/8/8/QK2R3 b - - 0 1` | `h5g3 a1a8` | 1010 | `mateIn1`, `short`, `endgame` |
| `demo0003` | `4r1k1/7p/8/8/8/8/P7/R5K1 w - - 0 1` | `a2a3 e8e1 g1h2 e1a1` | 1150 | `rookEndgame`, `short` |
| `demo0004` | `6kr/5ppp/8/8/8/8/8/3Q2K1 b - - 0 1` | `h7h6 d1d8 g8h7 d8h8` | 960 | `backRank`, `short` |

Castling rights and the en passant field are written as `-` in every record,
so no fixture position offers a castle or an en passant capture.
