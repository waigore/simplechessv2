# Notes — issue #617 acceptance run

**Build:** `origin/main` @ `f33b070`, clean detached worktree, Godot `4.7.2.stable.official.ed1daf0bf`.
**Protocol:** `PTU-shared-play` (UX; requires Headless **and** Graphical). Verdict: **pass** in both.

## What was judged

The defect claims shared-play raster art is mirrored: upside down at White seat Bottom, left-right reversed at White seat Top, and the same on the 2×2 promotion chooser and the board backdrop. Acceptance asked a single question of the running build: **is any raster art mirrored relative to the plane the player sees, at either seat?**

### Seat Bottom

`screenshots/01-seat-bottom-start.png` — White on ranks 1–2 at the near edge. Every crown, base, and knight head points up the screen. Nothing is inverted. After the S1 move (`02-seat-bottom-after-bottom-move.png`), the `e2` pawn sits on `e4` and still reads upright.

### Seat Top

`screenshots/08-seat-top-start.png` and `09-seat-top-after-moves.png` — the whole board is rotated 180° (`CAM-board.M2`), White now at the far edge and Black near. Every piece is upright to the viewer at that edge, and both knights face the same screen direction they do at seat Bottom (i.e. seat Top is exactly seat Bottom rotated 180°, not mirrored). This is the half of the bug the original filing did not name, and it is the half that would have survived a naive "make it not upside down" fix.

### The other two sprite sites

`screenshots/05-promotion-chooser-bottom.png` — the 2×2 chooser (queen, rook, bishop, knight in `PROMOTE_ORDER`) renders with every glyph upright and correctly ordered.
`screenshots/01-seat-bottom-start.png` — the backdrop's frame/table margin sits directly above the corrected pieces and reads as one consistent surface.

### Root cause addressed at the right site

The headless log records `world_scale=(94.4, -94.4)` at **both** seats, with `seat_rotation=0.0000` (Bottom) and `3.1416` (Top). The world flip and the seat rotation are intact; the sprites cancel the flip in their own local transform, exactly the decision the issue settled. Nothing was fixed by moving the world flip.

## How the run was driven

`drive_graphical.gd` (graphical) and `drive_headless.gd` (headless) run the shipped `main.tscn` components and drive the real paths:

- panel controls are clicked as `InputEventMouseButton` at the centre of the button carrying the bound `control_id` — not by calling handlers directly;
- board moves are tap-select then tap-destination through `Presentation._on_pointer_down/_on_pointer_up`, the same entry points a player's finger reaches;
- seat changes go through the real flow: resign → result → *Play again* → setup → seat toggle → Start.

### Screenshot method

Out-of-process `/usr/sbin/screencapture` cannot capture the display on this host (`could not create image from display` — Screen Recording is not granted to the automation process). Screenshots are therefore the **Godot process's own rendered framebuffer** (`root.get_texture().get_image()` → PNG, 720×1280) from a rendered, non-headless session of the same build. This is the same pixels the window displays; the playtest debug overlay was switched off for the captures except where it appears in the chrome strip.

## Situational tools

- **`SIT.4` (performance)** — one timed local move (`c2`→`c4`) with 32 frame samples: worst `4.18 ms` against the `16.67 ms` budget; no hitch longer than one frame. Device: Apple M5, native macOS window, Godot `4.7.2`; one sample set, recorded as the S5/P3 observation for this run.
- **`SIT.5` (observability)** — `assert_telemetry` over this run's own log returned `pass` for `shared.start` (`UI-shared-play.US1`), `shared.move` (`UI-shared-play.US1.3`), and `shared.resign` (`UI-shared-play.US1.1`). The log window read is `logs/graphical-drive.log`, session `sess-*` recorded in each `TEL.3`.

## Non-blocking observations (not defects for this issue)

1. **Coordinate chips render as empty rounded boxes** at the 720×1280 viewport in these captures (`01`–`03`, `08`–`09`). The chip geometry and seat compensation are untouched by this defect and are not part of its criteria, so this is recorded, not filed. If it reproduces on the release build it belongs to a coordinate-legibility issue, not to #617.
2. **Two regression groups assert the same thing.** `_check_art_orientation` and `_check_orientation` both cover this defect (the artefact of a restore plus a re-implementation). They agree on this build and are test-only duplication; the verify pass already flagged it as a `[CONT]` suggestion. No action here.
3. **Web is out of scope**, as the issue states — the Web build cannot show board art until #630 lands. This run does not re-confirm Web.
