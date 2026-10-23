# Demo: Puzzle stream at a cafe table

Reference artifact, not production code. Contract: `docs/demos.md`, `docs/demo-style-assets.md`.

- **Question**: Does the solo stream deal at the player's level, reset a wrong move without ending the stream, and drift `GS.playerElo` gently?
- **Type**: Gameplay demo — the two screens the stream needs (mode pick, puzzle play), their controls, three `EX.confirm` verbs, the promotion state, and the save-failure state. No shared game, setup, result, clocks, advice, or locale switch.
- **Issue**: #335 (from epic #35's demo-ready ID set)
- **Engine**: Godot 4.7.2 + GDScript — Engine ADR `specs/adr/decisions/0001-godot-engine.md`; catalog stance per ADR-0008 and ADR-0013.

## Scope

### Included

Every ID below exists in `specs/`.

| Spec element | How the demo shows it |
|--------------|-----------------------|
| `L-puzzle-stream.K1`, `K2`, `K3`, `K4` | `main.gd` + `puzzle_stream.gd`: mode pick deals per `DIF.Y1`; a Solving-side move is judged, a required reply plays at once, an ending updates Elo and the next puzzle deals; leaving returns to mode pick. |
| `L-puzzle-stream.E1` | Leave stream is a player choice, not a win or loss (`_scenario_leave`, `PRG.Z1`). |
| `DIF.Y1` | `DemoPuzzleStream._select`: within ±`CFG.ELO_MATCH_RANGE` (100) of `playerElo`, preferring ids outside `recent_solved` (cap 20), then widening by `CFG.ELO_BAND_WIDEN` (50) and/or allowing a recent id; `_apply_ending` runs `E = 1/(1+10^((puzzleElo−playerElo)/400))`, `playerElo ← playerElo + 20 × (S − E)`; `Puzzle Elo` never changes. A deal is asserted inside the band. |
| `DIF.C1` | The demo has no hand-set Elo control; only W1/L4/L5/L6 write it. |
| `END.W1` | A completed sequence with no Wrong move on that puzzle is a win (S = 1) and the id joins `recent_solved`. |
| `END.L4` | Completing the sequence after a Wrong move is a loss; the demo prints the drop. |
| `END.L5` | Reveal (C3 → Confirm) is a loss with S = 0. |
| `END.L6` | Abandon (C4 → Confirm) is a loss with S = 0, then the Elo update and a new deal. |
| `END.P1` | W1 is the only S = 1 row; the four endings are never co-true — each closes the puzzle before the next deals. |
| `F-puzzle-catalog.R1` | The catalog is the fixture slice `catalog_slice.json`; no export bytes are in the demo (`ADR-0008`), and the host decision is untouched. |
| `F-puzzle-catalog.R2`, `R3`, `I1` | The slice records carry the served snapshot id `2026-10-05` and the recorded columns; a deal applies the first move and presents that position; `GS.puzzleId`/`GS.puzzleElo`/`GS.requiredSequence` come from the record; selection reads `playerElo` and `recentSolved`. |
| `F-puzzle-catalog.R4` | A non-mate puzzle accepts only the recorded step (`0002`, `0003`, `0005`). |
| `F-puzzle-catalog.R5` | `0001` and `0004` are marked `mateIn1`; the demo solves `0001` with `Qb8#`, a mate the record does not name, and the run asserts the solve. |
| `F-puzzle-catalog.I2`, `I3`, `X1`, `X2` | Even steps play as replies; a solve appends the PuzzleId; a record with fewer than two moves or an unreachable host deals nothing and leaves the Elo alone. |
| `E-pieces.I1`–`I35` | `chess_rules.gd` (copied from the wave-1 demo): the full orthodox rules judge every scripted and played move. |
| `FL-mode-pick.P1`, `P3`, `T2`, `T4` | Mode pick → Puzzle stream in one tap (`T2`), Leave stream → mode pick (`T4`); the board is unreachable on mode pick. |
| `PRG.A1`, `P1`, `M1`, `P3`, `F1`, `Z1` | Player Elo drifts per result and is never reset by leaving; `playerElo`, Last mode, and `recentSolved` commit to `user://` after each result and re-entry restores them; `recentSolved` trims to `CFG.ELO_RECENT_WINDOW`; a shared game carries nothing (no shared game here); stopping is the player's. |
| `GS.puzzleId`, `puzzleElo`, `requiredSequence`, `sequenceIndex`, `solvingSide`, `wrongMoveOnPuzzle`, `playerElo`, `recentSolved`, `lastMode`, `position`, `sideToMove`, `selectedPiece` | `DemoPuzzleStream` carries exactly these fields; they clear together on a new deal or on leave, while Elo and `recentSolved` survive. |
| `GS.V1` | Only the side to move moves: an own-piece test runs before a place, and the reply plays for the other side. |
| `GS.V3` | No advice fields exist in the demo (`CFG.K3`). |
| `GS.H1` | `required_sequence` is the data, but the UI never shows it; only the position and the Solving side are exposed (`R1`, `R2`). |
| `GS.Q1` | `_select` picks at random among the candidate set; the autodrive seeds the pick so a run is reproducible. |
| `CFG.ELO_START`, `ELO_K`, `ELO_MATCH_RANGE`, `ELO_RECENT_WINDOW`, `ELO_BAND_WIDEN`, `K3` | `puzzle_stream.gd` constants at the design defaults; no advice in this mode. |
| `SPC.P1`, `P2`, `E1`, `L1`; `PRJ.P1`, `V1`; `CAM-board.F1`, `M2`; `PHY.M1`–`M5`, `I1`–`I3`; `PER.R1`–`R4`, `R6`–`R8`; `AES.P1`–`P3`; `MOT.T1`–`T3` | `board_view.gd` (copied from the wave-1 demo): 10-unit board with 1-unit margins, 72 px per unit, White seat with rank 1 nearest, 0.15 s quad ease-out travel with settle, capture fragments, bad-drop return, select frame and legal marks, refusal flash. The copied view still measures its piece bodies against `SPC.E1`/`FRM.P2` and its coordinate labels against `PER.R7` every run. Board orientation stays White's: a Black-side puzzle would need `CAM-board.M2`'s 180° turn, which this demo does not do (see Known limitations). |
| `SND.X1`, `X2`, `X3`, `X5`, `M1`, `M2`, `L1`, `L2` | Touch-select on pick-up, move-settle on each landing (including the required reply), end-resolve on a result, and `X5 puzzle-fail` on a Wrong move; the cafe bed alternates A → B → A under the cues. `X3` (check) is not cued in puzzle play — the puzzle-play feedback set names `SND.X5` only — so `check.ogg` stays unused. |
| `UI-mode-pick.R1` (C2), `C2` | Mode pick offers Puzzle stream and shows it as Last mode; one tap enters the stream (`NAV.T2`). |
| `UI-puzzle-play.R1` | The board region: position, edge coordinates, selection and legal marks; deselect clears. |
| `UI-puzzle-play.R2` | Elo and status: `Elo <n>` always, the result cue (`Solved`, `Wrong move`, `Failed`, `Abandoned`), and the side to move with the puzzle's rating. |
| `UI-puzzle-play.R3`, `C1`–`C5` | Reveal, Abandon, Leave stream in their own region below the board, plus the board controls (select, place). |
| `UI-puzzle-play.S1`, `S2`, `S3`, `S4`, `S5` | Default; the named `EX.confirm` panel for C3/C4/C5 with Confirm/Cancel; the save-failure panel over the S1 board; the Q/R/B/N chooser on a last-rank pawn; the danger flash with the selection kept. |
| `UI-puzzle-play.C6` | The tapped promotion type commits first, then the puzzle judges the move. |
| `EX.confirm` | Reveal, Abandon, and Leave each name their action and wait for Confirm; Cancel returns to S1 (B1 for leave). |
| `EX.promote` | S4 chooser in Q/R/B/N order; the move is judged only after the type is committed. |
| `EX.rejected` | An illegal place flashes `PAL.C8` and is *not* a Wrong move: no reset, no deal. |
| `EX.save-failure` | A failed write restores the prior committed Elo and raises the S3 panel. |
| `J-puzzle-session.N1`, `N2`, `S1`, `S2`, `B1` | Starts on mode pick, `C2` into puzzle play, `C5` + Confirm back to mode pick, Cancel stays. |
| `NAV.T2`, `T9` | Both transitions are scripted and asserted. |
| `IN.select`, `IN.move`, `IN.deselect`, `B2`, `B3`, `B8`–`B11` | Tap-tap and press-drag-release; a tap of the selected piece keeps the selection; pressing off a destination deselects; a bad drop returns the piece and flashes. |
| `PAL.C1`, `C2`, `C5`, `C6`, `C8`, `C9`, `C10`, `C11` | Squares, table, select, refusal/check rose, ink, cream panels, legal marks — the copied board view plus the cream HUD and action bar. |
| `SCH-puzzle-catalog` F1–F13 with ADR-0008 | The fixture slice carries F1–F13 per record (`any_checkmate_wins` derived from `themes`), and the run checks every record: legal FEN, legal move order, and a real mate for each `mateIn1`. |

### Excluded

| Spec element or area | Reason |
|----------------------|--------|
| Shared game, `L-two-player-game`, `END.L1`–`L3`, `D1`–`D5`, clocks, resign, draw offer, `UI-shared-*` | Another mode (epic #34); the demo question is the solo stream only. |
| Advice (`F-move-advice`, `CFG.K3`), `GS.adviceBestMove`/`adviceEval` | Forbidden in this mode; wave 3. |
| Locale (`GS.locale`, `UI-mode-pick.R3`/`C4`, `LOC`) | The copy is demo-authored English (assumption A2); no locale switch, as the wave-1 demo. |
| `CAM-board.M2` 180° turn for a Black-side puzzle | Out of the demo question; it would need view work the wave-1 board has no path for. The slice only deals White-side puzzles, which is not the same as restricting the stream (see A6). |
| `EX.loading` (cold open) | No loading gate; assets load from the local asset root. |
| `UI-puzzle-play.S3` retry | S3 offers Dismiss only, exactly as the screen spec says; no retry button. |
| Real host catalog service (`CTR-puzzle-catalog-read`, `CMP-catalog-service`) | The demo stands in the fixture slice; serving the snapshot is task #329 and defect #528's territory. |

## Style

Aesthetics elements the demo expresses (`specs/aesthetics/`).

| Style element | Where it is seen or heard |
|---------------|---------------------------|
| `AES.P1` | Every travel is an ease-out inside the 0.15 s budget, and the result cue appears within 0.45 s of the ending. |
| `AES.P2` | Approved `piece-sprites/*` bodies at the one shared `FRM.P1` scale, readable by silhouette alone. |
| `AES.P3` | Mahogany board on the `PAL.C5` cafe table, cream HUD panels, rose only for refusals; no tournament chrome. |
| `PAL.C1`–`C2`, `C5`–`C6`, `C8`–`C11` | See the included table. |
| `MOT.T1`–`T3` | Travel, settle, and return curves. |
| `SND.X1`–`X3`, `X5`, `M1`–`M2`, `L1`–`L2` | Soft cue family under the cafe bed; `X5` is the one negative cue and stays `−3 dB`. |

## Assets

Every asset the demo shows or plays. All are cataloged with a `review-asset` Pass or a person-granted review exemption. Asset root is `game_assets/` (ADR-0005); Ogg Opus masters are served through `audio_runtime/` Vorbis copies (`AST.O3`).

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
| 01a151f8-b7d8-7fe3-b94f-e3a562395d96 | sound-effects/end-resolve | AI generation | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-759c-89c5-e1be5eecb2b2 | sound-effects/puzzle-fail | AI generation | AK-sound-effects | AK-sound-effects.V5 | TL.2 (adr-free) | 1 | approved | Pass — `SND.X5` soft anchor |
| 01a15200-69b2-7d13-a30d-696fa4ff390b | music/cafe-ambient-a | AI generation | AK-music | AK-music.V1 | TL.3 (adr-free) | 1 | approved | Pass |
| 01a15200-69b2-7964-a602-ad5b19583125 | music/cafe-ambient-b | AI generation | AK-music | AK-music.V1 | TL.3 (adr-free) | 1 | approved | Pass |
| 01a15215-15bd-7e3f-a3f8-ffcb1333a0ab | fonts/noto-sans | Third-party | AK-fonts | AK-fonts.V1 | N/A — not generated | 1 | approved | Pass |

## Pipeline findings

Problems met while producing or registering the assets, each filed as a spec change or defect.

| ID | Finding | Element | Filed as |
|----|---------|---------|----------|
| None | The demo consumed cataloged approved assets as-is, including `sound-effects/puzzle-fail`, which is already the approved `SND.X5` soft anchor; no generation or registration was needed. | — | — |

## Decisions

Design decisions encoded in the code, each traced to the spec.

| ID | Decision as encoded | Spec element | Code location |
|----|---------------------|--------------|---------------|
| D1 | The catalog is a hand-cut recorded-format slice (`catalog_slice.json`, six puzzles, ratings 880–1150) that stands in for the host-served snapshot; nothing in the demo fetches or ships the export. | `F-puzzle-catalog.R1`, `ADR-0008`, epic #35 Notes | `catalog_slice.json`, `main.gd` `_load_catalog` |
| D2 | A deal applies the record's first move and presents that position; `solvingSide` is the side to move there; a Wrong move restores *that* position, not the record's labels. | `F-puzzle-catalog.R3`, `GS.solvingSide`, `GS.sequenceIndex` | `puzzle_stream.gd` `deal`, `_wrong_move` |
| D3 | The whole move list is checked against the running position at deal time; a record with an unplayable entry is refused (`bad_move`) and deals nothing. | `F-puzzle-catalog.X1` | `puzzle_stream.gd` `deal` |
| D4 | Selection prefers an unsolved candidate inside ±100 Elo, widens by 50 and/or allows a recent id, and otherwise falls back to any usable record. The pick is random within the set. | `DIF.Y1`, `GS.Q1`, `F-puzzle-catalog.I1` | `puzzle_stream.gd` `_select` |
| D5 | Elo moves by `20 × (S − E)` with `E` from the puzzle's fixed rating; only W1 appends to `recentSolved`; both persist to `user://puzzle-stream-demo-save.json` after each result and on entry. | `DIF.Y1`, `F-puzzle-catalog.I3`, `PRG.A1`/`M1`/`P3` | `puzzle_stream.gd` `_apply_ending`, `save_document`, `main.gd` `_commit_save` |
| D6 | A mate-in-one step accepts any checkmating move (found by applying each legal move and asking the rules for mate); the recorded mate is not required. | `F-puzzle-catalog.R5`, `END.W1` | `puzzle_stream.gd` `_matches_expected` |
| D7 | A Wrong move resets the board and shows the `Wrong move` cue; it does not deal. Reveal and Abandon confirm, then show `Failed` / `Abandoned`, then deal. | `L-puzzle-stream.K2`, `END.L4`–`L6` | `main.gd` `_apply_place`, `_confirm_action`, `_after_ending` |
| D8 | Leave stream stops the stream with the open puzzle unscored; the mode pick returns with the Elo unchanged. | `L-puzzle-stream.K4`/`E1`, `NAV.T9`, `PRG.Z1` | `puzzle_stream.gd` `leave`, `main.gd` `_confirm_action` |
| D9 | A place the piece rules refuse flashes the rose rim and is not a Wrong move: no reset, no deal. | `EX.rejected`, `UI-puzzle-play.S5`, `PER.R8` | `main.gd` `_place` |
| D10 | A last-rank pawn opens the Q/R/B/N chooser; the judged move runs only after the type is tapped. | `EX.promote`, `UI-puzzle-play.C6`/`S4`, `I33` | `main.gd` `_place`, `_pick_promo_at` |
| D11 | The HUD sits above the board and the Reveal/Abandon/Leave actions below it, both clear of the 8×8 and inside the frame; the run asserts the rectangles. | `UI-puzzle-play.R1`–`R3`, `SPC.P1` | `main.gd` `_setup_hud`, `_setup_actions`, `_scenario_board_style` |
| D12 | The wrong-move cue is `SND.X5` (`sound-effects/puzzle-fail`) at −3 dB; the select cue stays 5.4 dB under the settle knock. | `SND.X5`, `SND.X1`–`X2`, `SND.L2` | `main.gd` `SFX_IDS`, `CUE_GAIN_DB` |
| D13 | A failed save restores the last committed document (Elo, Last mode, `recentSolved`) and opens the S3 panel; Dismiss returns to S1. | `EX.save-failure`, `UI-puzzle-play.S3`, `PRG.M1` | `main.gd` `_commit_save`, `_dismiss_save_failure` |

## Assumptions

Non-blocking gaps filled for the demo only (tuning, copy, layout details; never art or sound). Not decisions; not authority for main code.

| ID | Assumption | Why not blocking | Spec it belongs in |
|----|------------|------------------|--------------------|
| A1 | The fixture slice's six puzzles are hand-cut: their FENs, moves, and ratings are demo data, not snapshot bytes. | Epic #35's Notes allow a small recorded-format fixture stand-in and keep the host decision unchanged. | `specs/design/features/puzzle-catalog.md` (demo note) |
| A2 | Screen copy is the `puzzle-play.md` and `mode-pick.md` Copy table in English only; the status line "White/Black to move · puzzle <rating>" is demo-added. | Locale is out of scope (task #334 owns the copy); the wording mirrors the Copy table. | `specs/ux/screens/puzzle-play.md` (status-line wording), `specs/ux/localization.md` |
| A3 | The puzzle's rating shows beside the side to move rather than only in a tooltip. | R2 requires Player Elo and the result cue; the puzzle rating is extra context, not a required element. | `specs/ux/screens/puzzle-play.md` (R2 note) |
| A4 | The next deal waits 0.45 s after the result cue. | R2 only says the cue shows "after W1, L4–L6 before next deal"; the pause length is untuned. | `specs/ux/screens/puzzle-play.md` (cue timing) |
| A5 | Reveal shows only the `Failed` cue; the demo does not animate the remaining solution on the board. | K2/L5 require the ending and the cue; the demo question does not need the reveal animation. | `specs/design/loops/puzzle-stream.md` (reveal presentation) |
| A6 | The demo's slice holds White-side puzzles only, so board orientation never turns; the stream itself still deals by rating alone. | A Black-side deal needs the `CAM-board.M2` 180° turn, which is view work outside the demo question. | `specs/view/cameras/board.md` (`CAM-board.M2` demo note) |
| A7 | `DEMO_FORCE_SAVE_FAIL=1` stands in for an unwritable save, so S3 can be shown without a broken disk. | The save path is a demo-local `user://` file; the failure trigger is a test seam. | `specs/technical/` (`SEQ-puzzle-result-commit` failure path) |

## Run

- **Setup**: checkout the repo; the demo is a standalone Godot project at `demos/puzzle-stream/` (its own `project.godot`). It loads cataloged assets by ID at runtime from `game_assets/` and `audio_runtime/` at the repo root (ADR-0005), so it must run with the repo checkout intact.
- **Import once** (fresh checkout): `godot --headless --path demos/puzzle-stream --import --quit`
- **Run**: `godot --path demos/puzzle-stream`
  - Mode pick: tap **Puzzle stream** (shown as Last) to enter; **Quit** ends the session.
  - Puzzle play: tap a piece of the Solving side, then a marked square (or drag it) to place. **Reveal**, **Abandon**, and **Leave stream** each ask first; **Confirm** runs the action, **Cancel** stays.
  - On a last-rank pawn, tap the promotion type; the move is judged after the tap.
- **Headless smoke (autodrive)**: `godot --headless --path demos/puzzle-stream` — prints `[demo] PASS` on success. It drives, in order:
  1. mode pick → C2 → a real `DIF.Y1` deal at `CFG.ELO_START` (asserted inside the band);
  2. a Wrong move on `0002` (a legal non-required move) — the board returns to the deal, `sequenceIndex` is 0, the same puzzle stays open, Elo does not move — then the completion is `END.L4` and Elo drops;
  3. `END.L5` (reveal) on `0003` and `END.L6` (abandon) on `0005`, each lowering Elo and setting its cue;
  4. `END.W1` on the mate-in-one `0001`, solved with `Qb8#` rather than the recorded `Ra8#`, raising Elo and appending the id to `recentSolved`;
  5. `EX.rejected`: an illegal place is refused, is not a Wrong move, and leaves the puzzle open;
  6. Leave stream through `EX.confirm`: back on mode pick, Elo kept, the open puzzle unscored;
  7. `EX.promote`: a last-rank pawn asks for the type, then the place is judged;
  8. the fixture slice: every record's FEN opens, its moves are legal in order, and each `mateIn1` is a real mate;
  9. the copied board view's own measurements (piece bodies against `SPC.E1`/`FRM.P2`, coordinate labels against `PER.R7`) and the HUD/action rectangles against `UI-puzzle-play.R1`–`R3`;
  10. persistence: Elo, Last mode, and `recentSolved` round-trip, `recentSolved` trims to `CFG.ELO_RECENT_WINDOW`, and a failed write keeps the prior Elo and reaches S3.
- **Screenshots (graphical run)**: `DEMO_AUTODRIVE=1 DEMO_SHOT_DIR=/tmp/shots godot --path demos/puzzle-stream` saves `demo-puzzle-stream-mode-pick.png` and `demo-puzzle-stream-puzzle-play.png`.

## Known limitations

- The catalog is a six-puzzle fixture slice, and the autodrive narrows the slice per case so each rule can be shown; the interactive run deals from the whole slice.
- A real host read can fail; the demo's stand-in cannot, so `F-puzzle-catalog X2` is only shown by the deal's refusal paths (`no_record`, `empty_solution`, `bad_move`).
- The board never turns: no Black-side puzzle is in the slice (A6).
- The reveal shows the failure cue but not the remaining moves (A5).
- Persistence is a demo-local JSON file, not the game's `SEQ-persist-document`; the failure trigger is the `DEMO_FORCE_SAVE_FAIL` seam (A7).
- No locale switch, no shared game, no advice, no clocks — out of the demo question.
- Audio: under headless runs the audio devices may be absent, so cues and beds no-op silently; loading them is still exercised.
