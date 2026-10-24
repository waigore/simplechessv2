# Demo: Optional Advice at a cafe table

Reference artifact, not production code. Contract: `docs/demos.md`, `docs/demo-style-assets.md`.

- **Question**: Does optional advice appear calmly within `CFG.ADVICE_TIME_MS` and never delay a local move?
- **Type**: Engine demo — the shared board with the Advice band and the `EX.error` line; no mode pick, setup, result, or clock screens.
- **Issue**: #376 (from epic #36's demo-ready ID set)
- **Engine**: Godot 4.7.2 + GDScript — Engine ADR `specs/adr/decisions/0001-godot-engine.md`

## Scope

### Included

Each element below answers part of the demo question; every ID exists in `specs/`.

| Spec element | How the demo shows it |
|--------------|-----------------------|
| `F-move-advice.R1`, `R2`, `R3` | `main.gd` `advice_allowed()` / `_start_advice()`: advice runs only in the Shared game, only while `GS.advice` is On *and* `GS.online` is true; evaluation starts by itself — there is no ask action. |
| `F-move-advice.R4`, `R5` | `_apply_tick()` writes `GS.adviceBestMove` (from/to) and `GS.adviceEval` (centipawns, White's view) together and nothing else; the stream is for the side to move only. |
| `F-move-advice.R6`, `I1` | `_commit()` clears advice and starts the move in the same frame; the O1 request for the new position is opened after the commit. The autodrive prints “commanded in N ms … (advice O1 in flight meanwhile)”. |
| `F-move-advice.R7`, `CFG.ADVICE_TIME_MS` | `ADVICE_TIME_MS = 2000` is the demo's configured cap, handed to the peer as O1 `time_ms`; the peer stops by it (`DemoSimPeer.schedule`), the client never caps. |
| `F-move-advice.R8`, `X1`, `X4` | Move complete and game end call `_stop_advice()` (O2 + O3) at once; after a move the new position is evaluated again (`X1` resumes). |
| `F-move-advice.R9`, `X2`, `X3` | `toggle_advice()` Off, and `go_offline()`, clear advice and stop the stream; `D1` (Advice Off → no display) is the same path. |
| `F-move-advice.D1` | Advice Off shows no marks and no eval; Puzzle stream does not exist in this demo, so `R1` is realized by the “Shared game only” gate. |
| `GS.advice`, `GS.online`, `GS.adviceBestMove`, `GS.adviceEval`, `GS.H2`, `GS.V3` | `main.gd` fields `advice_on`, `online`, `advice_best_move`, `advice_eval`; both advice fields are always set and cleared together, so neither is knowable alone; no advice runs outside a Shared game. |
| `L-two-player-game.K2` with `I1` | Tap-tap play on the shared board; a local move never awaits advice. |
| `UI-shared-play.R3`, `C3`, `S3` | The Advice band under the board holds the one shared toggle (`Advice On` / `Advice Off`, plus the `UIS.I1` glyph) and the eval; `S3` is the `EX.error` line with `Dismiss` underneath while the board stays playable. |
| `EX.error` (`FAIL.T1`) | `show_error()` on a simulated backend failure and on a connection loss: “Advice unavailable. Play continues.”, the board stays playable, Dismiss returns to S1 without a silent retry. |
| `PER.R5` with `PER.R1`, `PER.R3`, `PER.R4`, `PER.R6` | `board_view.gd` `set_advice_move()`: from/to corner brackets and an arrow in `PAL.C7` on the square rims (off the body centre), fading in over `ADVICE_FADE_S`; both marks together stay under 10% of a piece body. Selection, legal marks, and the turn chip behave as in demo #63. |
| `PAL.C7`, `PAL.C10`, `PAL.C9`, `PAL.C8` | Advice teal for the marks and the eval, cream panels, ink text, rose error ink. |
| `UIS.T2`, `UIS.I1` | Eval and error copy at ≥ `T2` body size; the Advice glyph is `UIS.I1` `icons/advice`. |
| `CTR-advice-stream` O1–O3, E1–E2, G1, G3 | O1 = `{"api_key", "fen", "time_ms"}` printed by `_start_advice()`; E1 ticks (`best_move_uci`, `eval_cp`, `depth`, `time_ms`) drive the marks; O2/E2 cancel on move, Off, offline, and end. No client UCI, no Stockfish endpoint. |
| `SCH-advice-update` F1–F6, L2, I3 | F1/F2 from `best_move_uci`, F3/F4/F5/F6 carried by the tick; L2 writes only the advice fields; a tick from a cancelled stream is dropped (`_stream_id` guard in `poll_advice()`). |
| `CMP-advice-backend` R1–R4 (simulated) | `sim_peer.gd` stands in for the backend as the sole answerer, stops by the requested cap, and streams one move per position. It is never a UCI peer. |
| `CMP-advice-client` (simulated) | `main.gd` keeps the client half: reads the cap, sends O1, applies E1, drops stale E1, clears on O2/O3. |
| `specs/technical/sequences/advice-stream.md` S1–S7, B1–B3 | The same order on one node: start → request → (simulated search) → updates → fields → marks → end, with B1 (error), B2 (local move during a stream), B3 (Off). |
| `specs/design/experience/feedback.md` “Advice ready” | Best move and eval appear in the band with a calm fade; the move was never delayed. |
| `AES.P1`–`P3` | Snappy moves (motion inside 0.15 s), silhouette-first pieces, calm cafe mood: quiet wood, teal only for advice, rose only for check and error. |
| `ADR-0002` validation rows | Autodrive proves move-while-advice-in-flight, stream stops by 2000 ms, and no client Stockfish endpoint (no UCI path exists in the demo). |

### Excluded

| Spec element or area | Reason |
|----------------------|--------|
| `UI-mode-pick`, `UI-shared-setup`, `UI-shared-result` screens | Engine demo: the question is about advice on the play surface, not navigation. |
| Clocks (`GS.whiteClock`, `CFG.BLITZ_START`, …), draw offer, resign | Not needed to answer the question; demo #63's engine subset is reused as-is. |
| Puzzle stream (`F-move-advice.R1` in action, `CFG.K3`) | Wave 2 mode; the demo stays in a Shared game, so it only realizes “Shared game only”. |
| The real advice backend, its host, API key, and network transport (ADR-0002, #112, #373) | The epic allows a simulated local peer; no Stockfish endpoint ships in the demo. |
| Promotion, castling, and en passant *advice* | In the move set (the rules engine supports them) but not exercised by the scripted line. |
| Persistence, locale, telemetry files | No screens; the demo logs in the player's console instead. |

## Style

Aesthetics elements the demo expresses (`specs/aesthetics/`).

| Style element | Where it is seen or heard |
|---------------|---------------------------|
| `AES.P1` snappy motion | All travel inside the 0.15 s budget; the autodrive reports each move's command time. |
| `AES.P2` silhouette-first pieces | Catalog `piece-sprites/*` fitted by opaque alpha body to the `SPC.E1` extent. |
| `AES.P3` calm cafe mood | Mahogany board on the `PAL.C5` table, cream band, teal only for advice, rose only for check and error. |
| `PAL.C1`, `C2`, `C5`–`C11` | Squares, table, select, check/error rose, ink, cream, legal green, advice teal. |
| `MOT.A1`–`A3`, `T1`–`T3`, `E1`–`E2` | Travel, settle, return, capture break, promotion morph (demo #63's engine). |
| `SND.X1`–`X4`, `M1`–`M2`, `L1`–`L2` | Touch select, settle, check, end; cafe beds A→B→A without crossfade. |
| `UIS.I1`, `T2` | Advice glyph (`icons/advice`), body-size eval and error copy. |

## Assets

Every asset the demo shows or plays. All are cataloged with a `review-asset` Pass or a person-granted review exemption. Asset root is `game_assets/` (ADR-0005); Ogg Opus masters are served through `audio_runtime/` Vorbis copies (`AST.O3`).

| Asset ID | Handle | Source type | Kind spec | Coverage rule | Tool role (ADR) | Version | State | Review |
|----------|--------|-------------|-----------|---------------|-----------------|---------|-------|--------|
| 01a15dab-051c-75dc-8624-91f1c45f98f7 … 01a15dab-051c-73c8-9edc-c4e82957f267 (12 piece sprites) | piece-sprites/{k,q,r,b,n,p}-{white,black} | AI generation (agent-supplied) | AK-piece-sprites | AK-piece-sprites.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a14f8e-1cfa-7e93-bc94-ef0e7b4e3855 | board-backgrounds/play-table | AI generation (agent-supplied) | AK-board-backgrounds | AK-board-backgrounds.V1 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a15dc4-969f-7a81-9d34-29765e8dd787 | icons/advice | AI generation (agent-supplied) | AK-icons | AK-icons.V5 | TL.1 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-7ae6-84af-767ba53d09f6 | sound-effects/touch-select | AI generation (agent-supplied) | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-710a-b767-92c9137bfd63 | sound-effects/move-settle | AI generation (agent-supplied) | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-7e05-9921-e892e9a2e064 | sound-effects/check | AI generation (agent-supplied) | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-7fe3-b94f-e3a562395d96 | sound-effects/end-resolve | AI generation (agent-supplied) | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a15200-69b2-7d13-a30d-696fa4ff390b | music/cafe-ambient-a | AI generation (agent-supplied) | AK-music | AK-music.V1 | TL.3 (adr-free) | 1 | approved | Pass |
| 01a15200-69b2-7964-a602-ad5b19583125 | music/cafe-ambient-b | AI generation (agent-supplied) | AK-music | AK-music.V1 | TL.3 (adr-free) | 1 | approved | Pass |
| 01a15215-15bd-7e3f-a3f8-ffcb1333a0ab | fonts/noto-sans | Third-party (person-supplied) | AK-fonts | AK-fonts.V1 | N/A — not generated | 1 | approved | Pass |

Every one is already in `demos/shared-game/assets.json` with the same review verdict; this demo copied the manifest and added `icons/advice`. No asset was produced or changed for this demo.

## Pipeline findings

Problems met while producing or registering the assets, each filed as a spec change or defect.

| ID | Finding | Element | Filed as |
|----|---------|---------|----------|
| None | The demo consumed cataloged approved assets as-is; no generation, registration, or style problem surfaced. | — | — |

## Decisions

Design decisions encoded in the code, each traced to the spec.

| ID | Decision as encoded | Spec element | Code location |
|----|---------------------|--------------|---------------|
| D1 | Advice chrome is a band under the board (toggle, eval) and an error line under that; the board area itself carries only the from/to brackets and the arrow. | `UI-shared-play.R3`, `PER.R1`, `PER.R5` | `main.gd` `_setup_advice_controls`, `board_view.gd` `set_advice_move` |
| D2 | The advice stream is a time-ordered tick list drained in `_process`; a tick whose stream id was cancelled is dropped. | `SCH-advice-update.I3`, `CTR-advice-stream.O2/O3` | `main.gd` `poll_advice`, `_stream_id` |
| D3 | Advice clears and the move starts in the same frame, before any O1 for the new position is built. | `F-move-advice.R6`, `R8`, `I1` | `main.gd` `_commit` |
| D4 | Offline and a backend error both show the S3 line; the same page keeps playing and Dismiss clears the line without retrying. | `F-move-advice.R9`, `X3`, `EX.error`, `FAIL.T1` | `main.gd` `go_offline`, `simulate_failure`, `_dismiss_error` |
| D5 | The marks use corner brackets on the square rims plus a centre-line arrow, teal `PAL.C7`, under 10% body coverage, fading in over 0.12 s. | `PER.R5`, `PER.R1`, `PAL.C7`, `UIS.M2` | `board_view.gd` `_add_advice_square`, `_add_advice_arrow`, `ADVICE_FADE_S` |
| D6 | The peer deepens in three ticks (depth 6 → 12 → 18 at 5% / 35% / 85% of the cap), so advice visibly settles rather than snapping in. | `F-move-advice.R7`, `feedback.md` “Advice ready” | `sim_peer.gd` `TICKS`, `schedule` |

## Assumptions

Non-blocking gaps filled for the demo only (tuning, copy, layout details; never art or sound). Not decisions; not authority for main code.

| ID | Assumption | Why not blocking | Spec it belongs in |
|----|------------|------------------|--------------------|
| A1 | The simulated peer plays the short line 1. e4 e5 2. Nf3 Nc6 3. Bb5 with plausible evals from a table keyed by side and half-move, instead of searching. | The demo question is about calm arrival and never delaying a move, not about move quality; the epic explicitly allows a simulated peer. | `specs/technical/components/advice-backend.md` (a simulated peer for demos) |
| A2 | The eval copy is signed pawns with two decimals (`+0.50`), and the demo has no principal line or mate wording. | Copy detail: `PER.R5` fixes that an eval shows at ≥ `UIS.T2`, not its word form. | `specs/ux/screens/shared-play.md` Copy |
| A3 | An advice band *under* the board holds the toggle and the eval. | Layout: `UI-shared-play.R3` names the region's contents, not its coordinates. | `specs/ux/mockups/screens/shared-play.html` |
| A4 | The peer's tick schedule (depths and times) is demo tuning. | `F-move-advice.R7` only says updates may deepen until the cap. | `specs/technical/sequences/advice-stream.md` |
| A5 | The `api_key` printed in the O1 log is the literal `demo-simulated-peer`; there is no secret in the demo. | The peer accepts anything; the real key belongs to the deployed backend (#373). | `specs/technical/contracts/advice-stream.md` Wire |
| A6 | `board_view.gd`, `chess_rules.gd`, and `asset_loader.gd` are copied from `demos/shared-game` (demo #63) with the advice marks added, rather than imported. | Main code never imports demos, and demos do not import each other either; copying keeps each demo runnable on its own. | — (demo convention) |

## Promotion act

Filled by `require-demo-promotion`. Incomplete until every included element is keep or drop and any conflict spec PR has merged.

| Element | Choice | Note |
|---------|--------|------|
| `F-move-advice.R1`–`R3` | keep | none |
| `F-move-advice.R4`, `R5` | keep | none |
| `F-move-advice.R6`, `I1` | keep | none |
| `F-move-advice.R7`, `CFG.ADVICE_TIME_MS` | keep | none |
| `F-move-advice.R8`, `X1`, `X4` | keep | none |
| `F-move-advice.R9`, `X2`, `X3` | keep | none |
| `F-move-advice.D1` | keep | none |
| `GS.advice`, `online`, `adviceBestMove`, `adviceEval`, `H2`, `V3` | keep | none |
| `L-two-player-game.K2` with `I1` | keep | none |
| `UI-shared-play.R3`, `C3`, `S3` | keep | none |
| `EX.error` (`FAIL.T1`) | keep | none |
| `PER.R5` with `R1`, `R3`, `R4`, `R6` | keep | none |
| `PAL.C7`, `C10`, `C9`, `C8` | keep | none |
| `UIS.T2`, `I1` | keep | none |
| `CTR-advice-stream` O1–O3, E1–E2, G1, G3 | keep | none |
| `SCH-advice-update` F1–F6, L2, I3 | keep | none |
| `CMP-advice-backend` R1–R4 (simulated) | keep | Simulated peer is the demo stand-in; real backend stays out of demo scope |
| `CMP-advice-client` (simulated) | keep | none |
| `advice-stream` S1–S7, B1–B3 | keep | none |
| `feedback.md` “Advice ready” | keep | none |
| `AES.P1`–`P3` | keep | none |
| `ADR-0002` validation rows | keep | none |

Act: complete

## Run

- **Setup**: checkout the repo; the demo is a standalone Godot project at `demos/advice/` (its own `project.godot`). It loads cataloged assets by ID at runtime from `game_assets/` and `audio_runtime/` at the repo root (ADR-0005), so run it with the repo checkout intact.
- **Import once** (fresh checkout): `godot --headless --path demos/advice --import --quit`
- **Run**: `godot --path demos/advice` — tap a White piece, tap its destination; tap the `Advice On` switch in the band to turn advice Off; tap `Dismiss` on the error line.
- **Headless smoke (autodrive)**: `DEMO_AUTODRIVE=1 godot --headless --path demos/advice` — prints `[demo] PASS` when every check holds:
  1. **Calm** — advice is ready at ~100 ms (first tick) and deepens to its final tick near the 2000 ms cap; the ready time is printed against that budget.
  2. **Move never waits** — e2e4 is commanded while the first stream is open; advice clears on the move and the new position is evaluated for Black (e7e5), its marks on the new squares.
  3. **Off** — Advice Off clears the marks and eval and closes the stream; On resumes.
  4. **Offline** — the connection drops mid-evaluation: advice clears, the S3 line shows, reconnect resumes.
  5. **Failure** — a simulated backend failure clears advice and shows the S3 line; a local move still lands; Dismiss returns to S1.
  6. **End** — the game ends (checkmate) while advice shows: advice clears.
- **Screenshots (graphical run)**: set `DEMO_SHOT_DIR` to a writable directory, e.g. `DEMO_SHOT_DIR=/tmp/shots DEMO_AUTODRIVE=1 godot --path demos/advice` (under a virtual display: prefix `xvfb-run -a`). Saves `demo-advice-advice-ready.png`, `demo-advice-advice-offline.png`, and `demo-advice-advice-end.png`.

## Known limitations

- No screens, clocks, result screen, promotion advice, or real backend: the peer is a scripted table, not a search.
- The O1 request is printed, not sent: there is no network transport and no API key in the demo (ADR-0002).
- Under headless Linux the audio devices may be absent, so cues and beds no-op silently.
- The demo's evals are plausible, not engine-grade.
- The board is seated White only (no flip), like demo #63.
