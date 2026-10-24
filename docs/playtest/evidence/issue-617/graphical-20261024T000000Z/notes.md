# Notes — issue #617 acceptance run

**Build:** `origin/main` @ `f33b070`, clean detached worktree, Godot `4.7.2.stable.official.ed1daf0bf`.
**Protocol:** `PTU-shared-play` (UX; requires Headless **and** Graphical). Verdict: **pass** in both.

## What was judged

The defect claims shared-play raster art is mirrored: upside down at White seat Bottom, left-right reversed at Seat Top, and likewise the 2×2 promotion chooser and backdrop. Acceptance asked one question: **is any raster art mirrored relative to the plane the player sees, at either seat?**

### Seat Bottom

`screenshots/01-seat-bottom-start.png` — White on ranks 1–2 at the near edge; every crown, base, and knight head points up the screen. After S1 (`02`) the `e2` pawn sits on `e4`, still upright.

### Seat Top

`screenshots/08`, `09` — the board is rotated 180° (`CAM-board.M2`), White at the far edge, Black near. Every piece is upright to the viewer there, and both knights face the same screen direction as at Bottom: Top is Bottom rotated 180°, not mirrored. This is the half the filing did not name, and the one a naive "not upside down" fix would have missed.

### The other two sprite sites

`screenshots/05` — the 2×2 chooser (queen, rook, bishop, knight in `PROMOTE_ORDER`) renders upright and correctly ordered. `screenshots/01` — the backdrop's frame/table margin sits above the corrected pieces and reads as one surface.

### Root cause addressed at the right site

The headless log keeps `world_scale=(94.4, -94.4)` at **both** seats, `seat_rotation=0.0000` (Bottom) and `3.1416` (Top): sprites cancel the flip in their own local transform, the decision the issue settled. Nothing was fixed by moving the world flip.

## How the run was driven

Both drive scripts run the shipped `main.tscn` on the real paths:

- controls are clicked as `InputEventMouseButton` at the bound `control_id`, not by calling handlers;
- board moves are tap-select then tap-destination through `Presentation._on_pointer_down/_on_pointer_up`, the entry points a finger reaches;
- seat changes follow resign → result → *Play again* → setup → seat toggle → Start.

### Screenshot method

Out-of-process `/usr/sbin/screencapture` cannot capture this host's display (Screen Recording not granted). Screenshots are the **Godot process's own rendered framebuffer** (`root.get_texture().get_image()` → PNG, 720×1280) from a rendered, non-headless session of the same build.

## Situational tools

- **`SIT.4`** — one timed local move (`c2`→`c4`), 32 frame samples: worst `4.18 ms` against the `16.67 ms` budget, no hitch over one frame. Apple M5, native macOS window; this run's S5/P3 observation.
- **`SIT.5`** — `assert_telemetry` over this run's own log: `pass` for `shared.start` (`UI-shared-play.US1`), `shared.move` (`.US1.3`), `shared.resign` (`.US1.1`).

## Non-blocking observations (not defects here)

1. **Coordinate chips render as empty rounded boxes** at 720×1280 in `01`–`03`, `08`–`09`. Chip geometry is untouched by this defect, so this is recorded, not filed; on release it would belong to a coordinate-legibility issue.
2. **Two regression groups assert the same thing.** `_check_art_orientation` and `_check_orientation` both cover this defect (a restore plus a re-implementation). Test-only duplication; already a `[CONT]` suggestion.
3. **Web is out of scope**, as the issue states — Web cannot show board art until #630 lands.
