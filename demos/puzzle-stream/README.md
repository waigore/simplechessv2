# Demo: Puzzle stream at a cafe table

Reference artifact, not production code. Contract: `docs/demos.md`, `docs/demo-style-assets.md`.

- **Question**: Does the solo stream deal at the player's level, reset a wrong move without ending the stream, and drift `GS.playerElo` gently?
- **Type**: Gameplay demo — a played stream with the puzzle-play screen's three regions (board, Elo and status, stream actions), a minimal mode pick, and the confirm/promote/reject overlays. No setup, result, clocks, advice, save-failure state, or localization.
- **Issue**: #335 (from epic #35's demo-ready ID set)
- **Engine**: Godot 4.7.2 + GDScript — Engine ADR `specs/adr/decisions/0001-godot-engine.md`

## Scope

### Included

Every ID below exists in `specs/` and is part of epic #35's demo-ready set. The catalog stand-in is the epic's sanctioned exception: a small recorded-format slice in place of the host-served snapshot (`F-puzzle-catalog` R1, ADR-0008).

| Spec element | How the demo shows it |
|--------------|-----------------------|
| `F-puzzle-catalog.R1`–`R5`, `I1`–`I3`, `X1`–`X2`, `D1` | `catalog_service.gd` reads `fixtures/catalog-slice.txt` one record per line in the recorded format (`R3`); no client catalog, no Elo bands, no sitting-sized inventory (`R1`, `R2`). The deal ladder is `I1`/`D1`: inside ±`CFG.ELO_MATCH_RANGE` and not in `GS.recentSolved`, then widen by `CFG.ELO_BAND_WIDEN` step by step, then allow a recently solved id, widening again — the first rung with any member wins. `R5` (mate-in-one accepts any legal checkmating move) is shown by `demo0002`, whose presented position has two mating moves. `I3` appends the `PuzzleId` to `GS.recentSolved` on `W1` only and trims to `CFG.ELO_RECENT_WINDOW`. `X1` (a record with no move after the first) is not dealt; `X2` (an unreadable slice) deals nothing and leaves `GS.playerElo` alone — the autodrive points the same reader at `fixtures/missing-slice.txt`. |
| `L-puzzle-stream.K1`–`K4`, `E1` | `main.gd`/`stream_session.gd`: entering the stream deals one puzzle at Player Elo (`K1`); the Solving side moves, required replies play at once, a mate-in-one step accepts any mate (`K2`); the result cue appears, Elo updates once, and exactly one next puzzle is dealt (`K3`); Leave stream keeps Player Elo and scores the open puzzle nothing (`K4`, `E1`). |
| `DIF.Y1`, `DIF.C1` | `progression.gd`: classic Elo update with `CFG.ELO_K` — `W1` is a win, `L4`/`L5`/`L6` a loss, `E = 1 / (1 + 10^((puzzleElo − playerElo)/400))`, `playerElo += K × (S − E)`. Autodrive: W1 vs 900 → 1007.2, L6 vs 900 → 987.2, even-Elo W1 → 1010, even-Elo L6 → 990. No hand-set Elo anywhere (`DIF.C1`). |
| `END.W1`, `END.L4`–`L6`, `END.P1` | `stream_session.gd` judges the four endings: sequence completed clean (`W1`), completed after a Wrong move (`L4`), reveal (`L5`), abandon (`L6`). `END.P1` holds because the session has one outcome per puzzle and clears it on the next deal. |
| `GS.puzzleId`, `GS.puzzleElo`, `GS.requiredSequence`, `GS.sequenceIndex`, `GS.solvingSide`, `GS.wrongMoveOnPuzzle`, `GS.playerElo`, `GS.recentSolved`, `GS.lastMode`, `GS.position`, `GS.sideToMove`, `GS.selectedPiece`, `GS.V1`, `GS.V3`, `GS.H1`, `GS.Q1` | The session object holds exactly those fields; `UCI` strings are the required sequence, `index` is the sequence index, the presented side to move is the solving side, and the wrong-move flag sticks until the next deal. `GS.Q1` is shown by the candidate-set check (two deals can differ, both are members). `GS.V3` holds by construction: the demo contains no advice field. `GS.H1` is realized only in the sense that the demo never shows the recorded line; the reveal action is `L5`, not a line display. |
| `E-pieces.I1`–`I35` | `chess_rules.gd`, copied from `demos/shared-game/` unchanged in behavior: orthodox moves, check, castling (now gated on the record's castling rights), en passant, promotion, mate and stalemate. Rule generation is not the demo's question; it is reused so the judging is real. |
| `CFG.ELO_START`, `CFG.ELO_K`, `CFG.ELO_MATCH_RANGE`, `CFG.ELO_RECENT_WINDOW`, `CFG.ELO_BAND_WIDEN`, `CFG.K3` | One `CFG` dictionary in `main.gd` (1000 / 20 / 100 / 20 / 50) feeds both the deal and the Elo update. Untimed throughout: no clock, no advice, nothing but calm practice (`CFG.K3`). |
| `PRG.A1`, `PRG.P1`–`P3`, `PRG.M1`, `PRG.F1`, `PRG.Z1` | One Player Elo axis advanced only by puzzle results (`A1`, `F1`, `Z1`); Player Elo, last mode, and `GS.recentSolved` are bound when the stream is entered and kept across a leave/re-enter inside the run (`P1`–`P3`, in memory — see assumption A1); Elo commits once per result, `GS.recentSolved` with each `W1` (`M1`). |
| `FL-mode-pick.P1`, `P3`, `T2`, `T4`, `U1` | `main.gd` opens on a minimal mode pick (`P1`); choosing Puzzle stream enters the stream (`T2`/`P3`); Leave returns there (`T4`, `U1` re-entry deals at the committed Elo). |
| `UI-mode-pick.C2` | The one live mode button on the demo mode pick. |
| `UI-puzzle-play.R1`–`R3`, `C1`–`C6`, `S1`–`S5` | Region R1 is the board with edge coordinates, selection, and legal marks; R2 holds `Elo <n>` and the result cue (`Solved`, `Wrong move`, `Failed`, `Abandoned`); R3 holds Reveal, Abandon, Leave stream. C1–C5 drive play, reveal, abandon, and leave; C6 is the in-board promotion chooser; S1 is the default state, S2 the named confirm for reveal/abandon/leave, S4 the promotion chooser (the move is judged only after the type commits), S5 the refusal flash that is not a wrong puzzle move. S3 (`EX.save-failure`) is excluded — see Excluded. |
| `J-puzzle-session.N1`–`N2`, `S1`–`S2`, `B1` | Mode pick → puzzle play in one tap (`N1`, `S1`), Leave stream + Confirm → mode pick (`S2`, `N2`), Cancel stays in play (`B1`). |
| `NAV.T2`, `T9` | One tap from the mode pick into the stream; Leave stream is always on screen and returns to mode pick. |
| `IN.select`, `IN.move`, `IN.deselect`, `IN.activate`, `B2`–`B3`, `B8`–`B11` | `main.gd` pointer input: press a solving-side piece to select and mark legal places, release on a target to move, plain tap-tap also plays, press elsewhere deselects, a drag follows the pointer and a refused drop returns the piece (`S5`, not a wrong move). |
| `EX.confirm`, `EX.promote`, `EX.rejected`, `EX.save-failure` | One named confirm panel for reveal/abandon/leave; the promotion chooser; the rose refusal flash on an illegal place. `EX.save-failure` is in the set but not reachable here: nothing is saved (A1), so S3 cannot occur. |
| `CAM-board.F1`–`F2`, `M2` | `board_view.gd`: world axes with local y down toward rank 1, and the puzzle orientation of `M2` — Solving side White faces the player at 0°, Solving side Black turns the board 180° at deal with no motion. Coordinates stay upright and name their own board file/rank. The autodrive round-trips all 64 squares in both orientations and checks a1↔h8. |
| `SPC.P1`–`P2`, `E1`–`E2`, `L1`–`L4`, `PRJ.P1`, `PRJ.V1`, `PHY.M1`–`M5`, `I1`–`I3` | Shared with the wave-1 demo: 10-unit short axis, 0.85 × 0.85 piece extent, one uniform scale, 72 px unit, board on the frame center, 0.15 s ease-out travel, capture break, promotion morph, drag follow, refusal return, settle window before input reopens. |
| `PER.R1`–`R4`, `R6`–`R8` | Piece bodies at their `FRM.P2` heights inside the extent, thin select stroke with gold fill, ≥ ¼-square green legal marks (diamonds empty, rings capture), rose check rim plus the check cue, cream coordinate labels inside the wooden bands, refusal flash. The autodrive prints and bounds the measured bodies and coordinate ink boxes every run. |
| `AES.P1`–`P3`, `MOT.T1`–`T3`, `PAL.C11` | Everything settles inside the 0.15 s budget; types read from silhouette; quiet mahogany table, no chrome; green legal marks. |
| `SND.X1`–`X3`, `SND.X5`, `SND.M1`–`M2`, `SND.L1`–`L2` | Feather-light select, settle on land, check sting, soft `X5` fail tap on a Wrong move; cafe bed alternates A → B → A with a hard handoff, ducked under cues. Puzzle results are the R2 status cue only — `SND.X4` stays with shared-game endings. |
| `SCH-puzzle-catalog` F1–F13, ADR-0008 | `fixtures/catalog-slice.txt` holds four records with every F-field, one snapshot id, and `any_checkmate_wins` derived from `themes` when absent. See `fixtures/README.md`. |

### Excluded

| Spec element or area | Reason |
|----------------------|--------|
| `EX.save-failure`, `UI-puzzle-play.S3` | The demo keeps Player Elo, last mode, and `GS.recentSolved` in memory for the run (assumption A1); a failed save cannot happen, so its state would be faked. |
| Host serving of the snapshot (#328, #329), the full export | The catalog stays on the host by ADR-0008; the demo reads a four-record recorded-format slice instead, and the slice is never treated as an inventory. |
| Localization (`en`, `zh-Hant`, `ja`) | Demo copy is literal English; the screen's Copy table is the source for the strings used. |
| Shared game, clocks, `END.L1`–`L3`, draws | Wave-1 scope; the stream never ends the session. |
| Advice (`F-move-advice`, `CFG.K3`) | Forbidden in this mode; `GS.V3` holds because nothing advice-shaped exists. |
| Setup, result, and settings screens, `PAL.C6`, `SND.X4` | Not part of the stream's played surface; the demo has no game result to resolve. |

## Style

Aesthetics elements the demo expresses (`specs/aesthetics/`).

| Style element | Where it is seen or heard |
|---------------|---------------------------|
| `AES.P1` snappy motion | Every travel, return, and morph inside the 0.15 s budget; the autodrive replays the moves and measures nothing slower. |
| `AES.P2` silhouette-first pieces | Approved `piece-sprites/*` at one uniform `FRM.P1` scale; measured bodies K 0.40 × 0.85, Q 0.40 × 0.79, B 0.39 × 0.76, N 0.48 × 0.75, R 0.40 × 0.68, P 0.38 × 0.62, printed each run and bounded to `SPC.E1`. |
| `AES.P3` calm cafe mood | Mahogany `board-backgrounds/play-table` on the `PAL.C5` table ground, warm wood palette, cream panels, rose only for check/refusal/failure; no clocks, no advice, no tournament chrome; the cafe bed never stops for a result. |
| `PAL.C1`, `C2`, `C5`, `C8`, `C9`, `C10`, `C11` | Squares, table, select, rose check/refusal/negative cue, ink text, cream panels, green legal marks. |
| `MOT.T1`–`T3` | Quad ease-out travel, settle, and return inside the one budget. |
| `SND.X1`–`X3`, `SND.X5` | Soft wood family; the wrong-move tap is the only negative sound and it plays once per Wrong move. |
| `SND.M1`–`M2`, `SND.L1`–`L2` | Cafe beds alternate A → B → A on a hard handoff, under all cues; the select tap sits 5.4 dB under the settle knock. |
| `PER.R7` contrast | Coordinate labels measured at 6.5 px ink inside the 11.5 px wooden band at 7.38:1; the autodrive prints the boxes and fails if one leaves its band. |

## Assets

Every asset the demo shows or plays. All are cataloged with a `review-asset` Pass. Asset root is `game_assets/` (ADR-0005); Ogg Opus masters are served through `audio_runtime/` Vorbis copies (`AST.O3`).

| Asset ID | Handle | Source type | Kind spec | Coverage rule | Tool role (ADR) | Version | State | Review |
|----------|--------|-------------|-----------|---------------|-----------------|---------|-------|--------|
| 01a15dab-051c-75dc-8624-91f1c45f98f7 | piece-sprites/k-white | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-7392-9318-e8b69bf7abf2 | piece-sprites/k-black | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-7023-973b-0b37ef3aa1b3 | piece-sprites/q-white | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-784b-859a-1d347edf39f0 | piece-sprites/q-black | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-7c3f-94fc-ce51926b3549 | piece-sprites/r-white | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-73b7-bad0-e6df05f4d2b6 | piece-sprites/r-black | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-73ff-96fa-a75c6719313a | piece-sprites/b-white | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-7061-9aaf-f2ba5a069413 | piece-sprites/b-black | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-7155-b8ec-6de860bae114 | piece-sprites/n-white | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-72b6-8859-f3edab33c514 | piece-sprites/n-black | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-7db1-8f3e-9cb5e68058d8 | piece-sprites/p-white | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dab-051c-73c8-9edc-c4e82957f267 | piece-sprites/p-black | AI generation | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a14f8e-1cfa-7e93-bc94-ef0e7b4e3855 | board-backgrounds/play-table | AI generation | AK-board-backgrounds | AK-board-backgrounds.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-7ae6-84af-767ba53d09f6 | sound-effects/touch-select | AI generation | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-710a-b767-92c9137bfd63 | sound-effects/move-settle | AI generation | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-7e05-9921-e892e9a2e064 | sound-effects/check | AI generation | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-759c-89c5-e1be5eecb2b2 | sound-effects/puzzle-fail | AI generation | AK-sound-effects | AK-sound-effects.V5 | TL.2 (adr-free) | 1 | approved | Pass (SND.X5 SS1 soft anchor, PO listened) |
| 01a15200-69b2-7d13-a30d-696fa4ff390b | music/cafe-ambient-a | AI generation | AK-music | AK-music.V1 | TL.3 (adr-free) | 1 | approved | Pass |
| 01a15200-69b2-7964-a602-ad5b19583125 | music/cafe-ambient-b | AI generation | AK-music | AK-music.V1 | TL.3 (adr-free) | 1 | approved | Pass |
| 01a15215-15bd-7e3f-a3f8-ffcb1333a0ab | fonts/noto-sans | Third-party | AK-fonts | AK-fonts.V1 | N/A — not generated | 1 | approved | Pass |

## Pipeline findings

Problems met while producing or registering the assets, each filed as a spec change or defect.

| ID | Finding | Element | Filed as |
|----|---------|---------|----------|
| None | The demo consumed cataloged approved assets as-is; no generation, registration, or style problem surfaced. The fixture slice is demo content, not an asset, and its records were re-derived until every line was legal (see `fixtures/README.md`). | — | — |

## Decisions

Design decisions encoded in the code, each traced to the spec.

| ID | Decision as encoded | Spec element | Code location |
|----|---------------------|--------------|---------------|
| D1 | The deal ladder is a candidate set, and the deal is its first member: prefer ids outside `GS.recentSolved`, in band then widening by `CFG.ELO_BAND_WIDEN` step by step; only then allow a recently solved id, again in band then widening. Widen is a numeric window growth, never a named band. | `DIF.Y1`, `F-puzzle-catalog.I1`, `D1`, `GS.Q1` | `catalog_service.gd` `candidate_set`/`deal`, `_in_band` |
| D2 | A deal presents the position after the record's first (opponent) move; the required sequence is the rest, alternating solving side and required reply; odd steps play at once for the other side. | `F-puzzle-catalog.R3`, `L-puzzle-stream.K2`, `I2` | `stream_session.gd` `open_puzzle`, `try_move` |
| D3 | A Wrong move costs nothing on the same puzzle: the session restores the stored presented position, resets the index, sets `GS.wrongMoveOnPuzzle`, plays the soft fail tap once, and deals nothing. The retried sequence then scores `L4`. | `L-puzzle-stream.K2`, `END.L4`, `END.P1`, `SND.X5` | `stream_session.gd` `try_move`, `start_pos`; `main.gd` `_commit_player_move` |
| D4 | Mate-in-one (F13 `any_checkmate_wins`, derived from `themes` when absent) matches the recorded first step or any legal checkmating move; the required sequence itself is never rewritten. | `F-puzzle-catalog.R5`, `I3` | `stream_session.gd` `try_move` (`_is_checkmate`), `catalog_service.gd` `open` |
| D5 | Elo is committed once per result by the session, then exactly one next puzzle is dealt; the progression math lives beside the session and returns values the session commits rather than computing them inline. | `DIF.Y1`, `PRG.M1`, `L-puzzle-stream.K3` | `progression.gd` `score`, `stream_session.gd` `score`, `main.gd` `_finish` |
| D6 | Leave stream (confirmed) keeps Player Elo, clears the open puzzle without scoring `L6`, and returns to mode pick; re-entering deals at the kept Elo and history. | `L-puzzle-stream.K4`, `E1`, `PRG.P1`, `J-puzzle-session.B1` | `main.gd` `_leave`, `_enter_stream` |
| D7 | The puzzle view turns 180° at deal when the Solving side is Black: pieces, overlays, and the input mapping use the turned point, while the wooden bevel and squares stay as drawn (they are symmetric) and the coordinate labels stay upright, naming their own board file/rank. | `CAM-board.M2`, `F1`–`F2`, `PER.R7` | `board_view.gd` `place_point`, `set_orientation`, `index_from_unit`, `CoordLabels.spots` |
| D8 | A place the piece rules refuse is `EX.rejected` — the piece returns, the square flashes rose, and the selection clears — and is never judged as a wrong puzzle move. | `EX.rejected`, `UI-puzzle-play.S5`, `PER.R8`, `IN.deselect` | `main.gd` `_release_at` |
| D9 | Promotion opens the in-board chooser and only judges the move after the type commits. | `UI-puzzle-play.S4`, `EX.promote`, `C6` | `main.gd` `_execute_move`, `_pick_promo_at`, `_finish_promoted_move` |
| D10 | The result is a status cue in R2, not a screen and not an end cue: `Solved`/`Failed`/`Abandoned` text for one beat, then the next deal. `SND.X4` stays with shared-game endings. | `UI-puzzle-play.R2`, `SND` X4/X5 rows, `AES.P3` | `main.gd` `_finish`, `_set_cue` |
| D11 | The cafe bed alternates A → B → A on a hard handoff and is never stopped by a result or a leave. | `SND.M1`–`M2`, `SND.L1`–`L2` | `main.gd` `_setup_audio`, `_on_bed_finished`, `_leave` |
| D12 | Castling is offered only when the record's castling-rights field still grants it and the king and corner rook are unmoved, so a fixture position can never castle without rights. | `E-pieces.I1`–`I35` (rules reused unchanged) | `chess_rules.gd` `castle_rights`, `fen_codec.gd` |

## Assumptions

Non-blocking gaps filled for the demo only (tuning, copy, layout details; never art or sound). Not decisions; not authority for main code.

| ID | Assumption | Why not blocking | Spec it belongs in |
|----|------------|------------------|--------------------|
| A1 | Player Elo, last mode, and `GS.recentSolved` live in memory for the run: re-entering the stream keeps them, quitting the process forgets them. No save, so `EX.save-failure` (S3) cannot occur. | The demo question is the deal, the reset, and the drift inside one sitting; the commit path of `PRG.P1`–`P3` is main-code work with its own durability row. | `specs/technical/components/puzzle-session.md` (commit/restore path), `specs/design/progression.md` (demo note) |
| A2 | The order of the two relax rules is widen-not-recent fully first, then allow-recent with widening again. | `DIF.Y1`/`I1` say "widening and/or allowing a recent id until one is found" without ordering the two; any order yields a legal in-window pick as soon as the slice has one. | `specs/design/difficulty.md` (`DIF.Y1` relax order) |
| A3 | Demo-authored copy beyond the `UI-puzzle-play` Copy table: the `Your move` prompt, `No puzzle available` for `X1`/`X2`, `Elo <n>` formatting, and the mode pick's `Puzzles` / `Shared game (stub)` labels. | The screen's Copy table fixes the result cues, the confirm strings, and the actions, which are used verbatim; the prompt and the no-puzzle line are demo chrome. | `specs/ux/screens/puzzle-play.md` (R2 copy), `specs/ux/screens/mode-pick.md` |
| A4 | The board turns by drawing pieces, overlays, and input at the turned point rather than rotating the view node, and the coordinate labels stay upright rather than upside down. | `CAM-board.M2` fixes which side faces the player, not how the turn is implemented; the squares and bevel are symmetric, so the shown board is identical. | `specs/view/cameras/board.md` (`M2` implementation note) |
| A5 | The demo opens on a mode pick with one live mode; leaving the stream returns to it without re-dealing the last puzzle as recent. | `FL-mode-pick.P1`/`T2`/`T4` and `J-puzzle-session.N1`–`N2` need a mode pick to exist; the demo only needs the one path into the stream. | `specs/ux/screens/mode-pick.md` (demo note) |

None of A1–A5 blocks the demo question. A1 and A2 are the two that touch main-code behavior and should be confirmed and written into `specs/` before implementation leaves on #332 and #331 rely on them.

## Run

- **Setup**: checkout the repo; the demo is a standalone Godot project at `demos/puzzle-stream/` (its own `project.godot`). It loads cataloged assets by ID at runtime from `game_assets/` and `audio_runtime/` at the repo root (ADR-0005), so it must run with the repo checkout intact.
- **Import once** (fresh checkout): `godot --headless --path demos/puzzle-stream --import --quit`
- **Run**: `godot --path demos/puzzle-stream` — tap `Puzzle stream`, then play: tap a solving-side piece and a legal square (or drag it), Reveal / Abandon / Leave stream after confirming.
- **Headless smoke (autodrive)**: `godot --headless --path demos/puzzle-stream` (or `DEMO_AUTODRIVE=1` in a windowed run, which also plays the motion paths) — prints `[demo] PASS` on success and exits non-zero on any failed check. It covers:
  - the slice's four records (F1–F13 fields, snapshot id, derived mate-in-one mark), `X1` (a record with no step after the first is not dealt) and `X2` (an unreadable path deals nothing and leaves Player Elo alone);
  - the deal ladder at Player Elo 1000 — in-band candidates, the 1150 id only after widening, recent ids skipped, a recent deal still preferring the band, and both deals being candidate-set members (`GS.Q1`);
  - `CAM-board.M2` round-tripping all 64 squares in both orientations, the measured piece bodies, and the 16 coordinate ink boxes;
  - the session battery: a clean solve (`W1` → Elo 1007.2), a wrong move that resets the board and index without ending the stream, the retried sequence scoring `L4` (Elo down), a mate-in-one accepted by its alternate mating move (`R5`), reveal (`L5`), abandon (`L6` → Elo 987.2), leave (`K4`) keeping Elo, and the even-Elo formula and recent-window trim;
  - the demo question end to end through the view path: deal at 1000, solve, Elo drifts up, the next deal is the in-band mate-in-one, a wrong move resets it, the retried loss drifts Elo down, and leaving keeps Elo.
- **Screenshots**: not produced by this demo; run it windowed to see it.

## Known limitations

- No persistence: Player Elo, last mode, and `GS.recentSolved` reset when the process exits (A1), so `EX.save-failure`/S3 never appears.
- The fixture slice is four records; the deal ladder is real but shallow — the widen rung is reached only when the three in-band ids are all recently solved, and two deals in a row may legitimately repeat a puzzle that was played but not solved.
- No localization: all copy is the English Copy table plus the demo chrome listed in A3.
- The mode pick is a stub with one live mode; there is no Setup, Result, or Settings screen, and no Shared game.
- Advice, clocks, and every shared-game ending are absent by scope, not by omission.
- The reveal action scores `L5` and deals the next puzzle; it does not display the recorded line (`GS.H1` stays hidden).
- The FEN reader takes the board, the side to move, and the castling field; an en passant target and the halfmove/fullmove counters are ignored. A record whose line needed an en passant capture would therefore fail to apply its first move and be treated as not dealt (`X1`); no fixture record is like that.
- Audio is muted in the headless smoke (the dummy driver only leaks playbacks at exit); a windowed run plays cues and the cafe bed.
