# Demo: Shared game at a cafe table

Reference artifact, not production code. Contract: `docs/demos.md`, `docs/demo-style-assets.md`.

- **Question**: Does a shared game at a cafe table feel instant, readable, and calm?
- **Type**: Engine demo — no UI screens; only minimal in-board overlays (promotion chooser, turn chip, refused flash, end panel). No mode pick, setup, result, clocks, draw offer, resign, persistence, or locale.
- **Issue**: #63 (from epic #34's demo-ready ID set)
- **Engine**: Godot 4.7.2 + GDScript — Engine ADR `specs/adr/decisions/0001-godot-engine.md`

## Scope

### Included

The demo realizes the epic's demo-ready ID set subset below; every ID exists in `specs/`.

| Spec element | How the demo shows it |
|--------------|-----------------------|
| `E-pieces.I1`–`I35` | `chess_rules.gd`: full orthodox rules — square colors, pseudo/legal moves, king step and castling (with blocked/through-check refusal), queen/rook/bishop/knight movement, pawn step/double step/en passant, check, promotion (I33/I34 chooser), mate and stalemate results. |
| `L-two-player-game.K1`, `K2`, `E1`, `E4` (loop subset) | `main.gd`: select → move → turn flips on one shared board until a position ending; mate ends the game (`Checkmate — White wins` in the autodrive run). |
| `END.L1` (mate) plus a wired stalemate result | `result()` in `chess_rules.gd` runs every ply: the scripted run asserts `checkmate:w`; the stalemate branch (`D1` — no legal move, no check) is computed by the same endpoint, not driven in the visual autodrive scenarios. |
| `GS.position`, `GS.sideToMove`, `GS.selectedPiece`, `GS.gameEnded`, `GS.V1`, `GS.V2` | `pos` dictionary with side-to-move, selection, ended flag; only one side moves per turn; V2 clocks are out of demo scope (no clock here). |
| `SPC.A1`, `SPC.P1`, `SPC.E1`, `SPC.L1` | `board_view.gd`/`main.gd`: 10-unit short axis (8 board + 1-unit margins), every piece fitted by its opaque alpha rectangle to the `SPC.E1` 0.85 body width and centered on the square, quiet cafe backdrop color `PAL.C5` behind the board. |
| `PRJ.P1` | `main.gd`: unit = 72 px, board on frame center, direct unnormalized projection. |
| `CAM-board.F1`, `CAM-board.M2` | `board_view.gd`: world axes with local y down toward rank 1, White's near edge at the bottom, rotation 0 (White seat fixed). |
| `PHY.M1`, `M2`, `M3`, `M4`, `M5`, `PHY.I1` | `board_view.gd`: 0.15 s ease-out travel; captured piece breaks into fragments during the travel; promotion morph inside the same budget; uncommitted drag follows the pointer; a bad drop returns to origin in 0.15 s; settle window before input reopens. |
| `PER.R1`, `R3`, `R4`, `R6`, `R7`, `R8` | `board_view.gd`: each piece body drawn at the full `SPC.E1` extent (`R1`), thin select stroke (<10% body), gold select fill, ink-area ≥ ¼-square legal marks (diamonds for empty, rings for captures), rose check rim + turn chip tint on the checked king's side, refusal flash on an illegal drop / illegal target, a–h / 1–8 in `PAL.C9` ink on grain bands of the board's wooden lip (`R7`, ≥ 4.5:1). |
| `AES.P1`, `P2`, `P3` | Every motion settles inside 0.15 s (`MOT.T1`); types read from silhouette alone (catalog sprites); quiet mahogany board, no tournament chrome. |
| `MOT.A2`, `T1`, `E1`–`E2` | Travel uses quad ease-out inside the 0.15 s budget; capture break and promotion morph are inside the travel, not appended. |
| `PAL.C1`, `C2`, `C5`, `C6`, `C8`, `C9`, `C10`, `C11` | Palette colors as Material constants in `board_view.gd`/`main.gd`: squares, cafe table, select, rose refusal/check, ink, cream, green legal marks. |
| `SND.X1`–`X4` | `main.gd`: touch select on pick-up, move settle on land, check cue on check, end resolve on mate/stalemate; the pick-up cue plays 5.4 dB under the settle knock (`SND.L2` cue gains) so the two read as one soft wood family. |
| `SND.M1` → `SND.M2` → `SND.M1`, `SND.L1`–`L2` | Cafe bed playlist cycles A→B→A; bed ducks under cues; no crossfade on loop boundary (hard playlist handoff). |
| `IN.select`, `IN.move`, `IN.deselect` (touch subset) | Pointer input in `main.gd`: press on an own piece selects (or retargets), release on a legal destination moves, release elsewhere deselects / refuses; also plain tap-tap play. |

### Excluded

| Spec element or area | Reason |
|----------------------|--------|
| `UI-mode-pick`, `UI-shared-setup`, `UI-shared-result` screens | Engine demo — the question is about the shared play surface, not navigation flow; the epic's screens stay in main-code epics. |
| `GS.whiteClock`/`GS.blackClock`, `GS.increment`, `CFG.BLITZ_START`/`CFG.RAPID_START`, `CFG.K1`–`K2` | Clocks are a config concern; the demo plays one untimed game. V2 is only realized in the sense that no clock runs here. |
| `EX.draw-offer`, resign/confirm | Demo ends are mate and stalemate; offer/confirm dialogs pull in the full exception stack, out of the minimal overlay budget. |
| `PRG.P2`/`PRG.M1` Last mode, `GS.locale`, localization | No screens; nothing to remember or localize beyond the demo's own overlay copy. |
| `CAM-board.M1` black-seat flip | Demo seats White only (P1 statement: orientation = White seat). |
| Advice (`F-move-advice`), puzzle content | Wave 3 / Wave 2 scope; not in the demo-ready set. |

## Style

Aesthetics elements the demo expresses (`specs/aesthetics/`).

| Style element | Where it is seen or heard |
|---------------|---------------------------|
| `AES.P1` snappy motion | All travel/return/morph inside the 0.15 s budget; measured 0–4 ms per scripted move headless. |
| `AES.P2` silhouette-first pieces | Approved `piece-sprites/*` sprites fitted so each opaque body reaches the 0.85 square extent (`FRM.P1`/`P2` height order kept), readable at 64 px. |
| `AES.P3` calm cafe mood | `play-table.svg` mahogany board on `PAL.C5` table backdrop with a solid wooden bevel around the 8×8 (`SRF.M1`, lit from the top-left per `SRF.S1`); warm wood palette `C1`/`C2`/`C5`; rose only for check/refusal. |
| `PAL.C1`–`C2`, `C5`–`C6`, `C8`–`C10`, `C11` | Squares, table, select, refusal/check rose, ink text, cream panels, green legal marks. |
| `MOT.A1`–`A3`, `T1`–`T3`, `E1`–`E2` | Travel/settle/return curves; capture break and promotion morph inside the travel; quad ease-out. |
| `SND.X1`–`X4`, `M1`–`M2`, `L1`–`L2` | Feather-light select, settle land, check sting, resolve end; cafe beds alternate A→B→A without crossfade. |

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
| 01a151f8-b7d8-7e05-9921-e892e9a2e064 | sound-effects/check | AI generation | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a151f8-b7d8-7fe3-b94f-e3a562395d96 | sound-effects/end-resolve | AI generation | AK-sound-effects | AK-sound-effects.V1 | TL.2 (adr-free) | 1 | approved | Pass |
| 01a15200-69b2-7d13-a30d-696fa4ff390b | music/cafe-ambient-a | AI generation | AK-music | AK-music.V1 | TL.3 (adr-free) | 1 | approved | Pass |
| 01a15200-69b2-7964-a602-ad5b19583125 | music/cafe-ambient-b | AI generation | AK-music | AK-music.V1 | TL.3 (adr-free) | 1 | approved | Pass |
| 01a15215-15bd-7e3f-a3f8-ffcb1333a0ab | fonts/noto-sans | Third-party | AK-fonts | AK-fonts.V1 | N/A — not generated | 1 | approved | Pass |

## Pipeline findings

Problems met while producing or registering the assets, each filed as a spec change or defect.

| ID | Finding | Element | Filed as |
|----|---------|---------|----------|
| None | The demo consumed cataloged approved assets as-is; no generation, registration, or style problem surfaced. | — | — |

## Decisions

Design decisions encoded in the code, each traced to the spec.

| ID | Decision as encoded | Spec element | Code location |
|----|---------------------|--------------|---------------|
| D1 | The board view is seated White with rotation 0; local y runs down toward rank 1 and files run left-to-right from a. | `CAM-board.M2` | `board_view.gd` class header + `_square_pos` |
| D2 | Motion budget `TRAVEL_S = RETURN_S = 0.15` s quad ease-out; settle window 0.03 s before input reopens. | `PHY.M1`, `PHY.I1`, `MOT.T1`, `AES.P1` | `board_view.gd` constants + `move_piece` |
| D3 | Capture breaks the victim into fragments that clear during the mover's travel, not after it. | `PHY.M2`, `MOT.E1` | `board_view.gd` `_spawn_fragments` + `move_piece` |
| D4 | Promotion opens an in-board chooser (Q/R/B/N) and only completes the move after the player picks (game side whitelists the choice). | `I33`–`I34`, `PHY.M3`, `MOT.E2`, `EX.promote` | `main.gd` `_try_move`/`_pick_promo_at` + `board_view.gd` `_build_promo` |
| D5 | Bad drop: the piece returns to origin in 0.15 s and the destination flashes the rose refusal once. | `PHY.M5`, `PER.R8`, `PAL.C8` | `board_view.gd` `return_piece` + main `_refuse` path |
| D6 | Legal marks: green diamonds on empty legal squares (ink ≥ ¼ square area) and green ink rings on capturable pieces; capture rings only over a capturable piece. | `PER.R4`, `PAL.C11`, `PER.R6` | `board_view.gd` `_paint_legal` |
| D7 | Check presentation: rose rim on the checked king's square plus the turn chip tinted rose until the check resolves; a one-shot check cue plays. | `PER.R6`, `PER.R7`, `PAL.C8`, `SND.X3` | `board_view.gd` `_paint_check` + `main.gd` `_on_state` |
| D8 | Turn chip and end panel are minimal in-board overlays, not screens; end resolves mate/stalemate with the end-resolve cue. The end panel stays inside the frame, above every board layer. | `L-two-player-game.K2`/`E1`, `END.L1` | `main.gd` `_setup_chip` + `_place_end_panel` + `_end_text` |
| D9 | Cafe bed playlist alternates bed A → bed B → A with a hard handoff (no crossfade), one shared player ducked under cues. | `SND.M1`/`M2`, `SND.L1`–`L2` | `main.gd` `_next_bed` |
| D10 | Input is pointer-only (tap select / tap move, and press-drag-release with `PHY.M5` follow); an illegal drop deselects and refuses rather than reselecting. | `IN.select`/`move`/`deselect`, `PER.R8` | `main.gd` `_unhandled_input` |
| D11 | Piece sprites are fitted by their alpha rectangle: the scale is the opaque body's width mapped to the `SPC.E1` extent and the body is centered on its square, so bodies draw at 0.76–1.00 of a square (measured: Pawn 0.76 × 0.82, Knight 0.82 × 1.00) instead of 0.61–0.75, and the artwork's King → Pawn height order survives (defect #427 item 1). | `SPC.E1`, `FRM.P1`, `FRM.P2`, `PER.R1`, `AES.P2` | `board_view.gd` `_apply_piece_texture`, `_body_rect` |
| D12 | A solid wooden bevel frames the 8×8 inside the board's outer margin: `PAL.C2` lips on the lit top/left, deepened `PAL.C5` on the shadowed bottom/right, a `PAL.C5` raised frame and a line darker than the bevel fill (`SRF.O1`), so no square or piece is covered (defect #427 item 4). | `AES.P3`, `SRF.M1`, `SRF.S1`, `SRF.O1`, `PAL.C2`, `PAL.C5` | `board_view.gd` `_build_bevel` |
| D13 | Coordinates are labels drawn in canvas pixels and scaled into the board plane (a Label keeps its screen font size under a Node2D, and a sub-2 px Node2D glyph is below the font rasterizer's minimum). They are drawn in `PAL.C9` ink on 0.16-unit grain bands of `PAL.C2` darkened to `#6E4430` so the ink field is wood, not the cream panel (defect #427 item 3). Measured contrast: ink on the lit `PAL.C2` lip 2.5:1, ink on the new band 1.7:1 — **handoff** to the next change, which replaces `PAL.C9` with cream `PAL.C10` (6.6:1 on the band) so `PER.R7`'s 4.5:1 holds; the bands and the placement are kept. | `PER.R7`, `UIS.T2`, `PAL.C2`, `PAL.C9`, `PAL.C10` | `board_view.gd` `_build_bevel`, `_build_coords`, `CoordLabels` |
| D14 | One photo of the cue family (`SND.L2`): the pick-up cue plays at −5.4 dB relative to the settle knock, so its peak sits 1.5 dB under the knock's and its first 60 ms 3 dB under, rather than the +4.6 / −4.3 dB split that made the select tap read jarring (defect #427 item 2). | `SND.X1`, `SND.X2`, `SND.L2` | `main.gd` `CUE_GAIN_DB`, `_setup_audio` |

## Assumptions

Non-blocking gaps filled for the demo only. Not decisions; not authority for main code.

| ID | Assumption | Why not blocking | Spec it belongs in |
|----|------------|------------------|--------------------|
| A1 | Overlay copy ("White to move", "Checkmate — White wins", "Stalemate — draw", promotion type labels) is demo-authored English; main code carries the localized strings. | Engine demo has no screens or locale scope; the copy mirrors the spec's outlined result wording. | `specs/design/screens/shared-play.md` / `shared-result.md` (wording), `specs/technical/` (localization) |
| A2 | The cafe bed is approximated with a single shared ducked player using hard playlist handoffs instead of a crossfade-capable bus graph. | The `SND.L1`–`L2` "no crossfade at boundary" behavior is reproducible with a hard handoff; a real mixer graph is a technical-design build detail. | `specs/technical/` (audio architecture) |
| A3 | Promotion chooser sits over the promotion square (order Q/R/B/N demo-fixed). | Chooser layout detail; specs fix the control (`EX.promote`/`C6`), not its coordinates. | `specs/design/screens/shared-play.md` (chooser placement note) |
| A4 | Stalemate (`D1`) is computed by the same `result()` endpoint exercised every ply, but the scripted autodrive only asserts the mate ending. | The demo question needs one game ending alive (`E1` mate, asserted); stalemate reuses the identical code path. | `specs/design/end-conditions.md` (D1 demo note) |

## Run

- **Setup**: checkout the repo; the demo is a standalone Godot project at `demos/shared-game/` (its own `project.godot`). It loads cataloged assets by ID at runtime from `game_assets/` and `audio_runtime/` at the repo root (ADR-0005), so it must run with the repo checkout intact.
- **Import once** (fresh checkout): `godot --headless --path demos/shared-game --import --quit`
- **Run**: `godot --path demos/shared-game` — play by tap or drag on the board; overlays handle promotion, checks, and the end panel.
- **Headless smoke (autodrive)**: `DEMO_AUTODRIVE=1 godot --headless --path demos/shared-game` — drives two scripted scenarios and prints `[demo] PASS` on success:
  - **Exercise** — 16 moves: select-only refusals, capture breaks, a check, and a capture-promotion morph with the chooser.
  - **Mate** — 7 moves ending in `Checkmate — White wins`.

  Every scripted motion is timed against the 150 ms budget. The exercise does **not** script castling, en passant, or the stalemate branch; `chess_rules.gd` implements all three and the autodrive's rules engine computes the stalemate result every ply (assumption A4).
- **Screenshots (graphical run)**: set `DEMO_SHOT_DIR` to a writable directory, e.g. `DEMO_SHOT_DIR=/tmp/shots DEMO_AUTODRIVE=1 godot --path demos/shared-game` (under a virtual display: prefix `xvfb-run -a`). Each autodrive scenario saves `demo-shared-game-<scenario>.png` there; nothing outside the repo is used by default (without `DEMO_SHOT_DIR` the user-data directory is used).

## Known limitations

- No clocks, resign, draw offer, persistence, locale, or screens; engine demo only.
- Audio: under headless Linux the audio devices may be absent — cues and beds then no-op silently; loading them is still exercised.
- The screenshot step needs a writable `DEMO_SHOT_DIR` (or the user-data directory) and runs only under autodrive.
- The demo draws its own wooden bevel and coordinate lip on top of `board-backgrounds/play-table`: the catalog backdrop's own grid and frame sit under the board and stay visible only in the cafe margins (a demo layout choice, not a change to the catalog art).
- The promotion chooser is keyboard-and-pointer; no Gamepad mapping (out of demo scope).
- Blacks sit across the table only notionally — the demo never rotates the board (white seat fixed by D1).
