# Notes — issue #617 acceptance run (headless)

## What was run

Build `origin/main` `3f81b59` in a clean detached worktree, Godot
`4.7.2.stable.official.ed1daf0bf`. The probe is
[`probe_art_orientation.gd`](probe_art_orientation.gd), copied into `game/` for the run and
run with `PROBE_LOG=<this folder>/logs/art-orientation.log godot --headless --path game
--script res://probe_617.gd`.

The probe loads the **catalogued** art (`n-white.png` &c.) through the shipped
`AssetResolver`, hosts the real `BoardPresentation` in a 720×1280 `Control`, lays the camera
out, binds the assets with `provide_assets()`, then renders the start position at each seat
and reads the sprite's composed **global** transform. It then drives `PlaytestSeams` and reads
`TEL.1`–`TEL.5` back with `assert_telemetry()`.

## What it proves

1. **Seat space is correct.** At both seats every sampled piece (`e1`, `e8`, `a1`, `h8`, `d1`,
   `d8`) has a negative local Y scale, a **positive global determinant**, and global rotation
   `0.0000` at seat Bottom and `3.1416` at seat Top. That is exactly `CAM-board.M2`, and it is
   the half of the #672/#673 fix that holds.
2. **Art orientation on screen is still wrong.** The art's own top edge (local `y = -1`)
   lands **right and above** the sprite centre at seat Bottom — it must be left and above —
   and right and below at seat Top. At Bottom the image is therefore drawn mirrored about its
   centre line: the world Y flip `(#617)` was meant to cancel is only partly cancelled.
3. **The art itself is the remaining variable, and the knights are stored upside down.** The
   widest ink row of every piece PNG should be its base, low in the image (Godot draws PNG row
   0 at the sprite's local top). Pawn 0.72, bishop 0.79, rook 0.76, queen 0.81, king 0.89 — all
   upright as stored. Knight **0.42** (white) and **0.38** (black): its widest row is its top,
   so the two knight PNGs carry the piece base-at-the-top of the image.

A horizontal mirror plus a vertical mirror about the centre compose to a 180° rotation, so for
five of the six kinds the composed sprite is not flipped at seat Bottom — which is why the
unit regression gate (`_check_art_orientation` / `_check_orientation`) passes: it asserts
scale signs, determinant and rotation, not which way the artwork faces.

## What this run cannot judge

- **Visual confirmation.** The measurements above are transforms and PNG ink rows, not
  pixels on a display. `PTU-shared-play` P2 is `not-judged` until a graphical run of this same
  build writes screenshots under `../graphical-<run-id>/screenshots/`; P3 (`SIT.4` frame
  timing) is also a graphical-run item. Story outcomes `UI-shared-play.US1`/`US2` and the
  operator steps S1–S3 (`ACT-bottom-player.US1`, `ACT-top-player.US1`) were not driven here.
- **Web.** The Web build cannot show board art until #630 lands (recorded on #617 and
  re-measured in `docs/playtest/evidence/issue-630/`).

## Non-blocking marks

- `_board_sprite` (backdrop) and the promotion chooser sprites take the same local scale from
  the same helper, so they carry the same composed orientation as the pieces; the probe
  sampled board pieces only.
- The probe hosts the presentation without an authored scene, because a `BoardPresentation`
  built in code does not receive `_ready()`; the camera is laid out by an explicit
  `_layout_camera()` call. `_ready()`'s only extra work is the letterbox rect and the
  `resized` connection, neither of which affects the sprite transforms measured here.
- Engine shutdown prints `ObjectDB instances were leaked at exit` / dummy texture RID
  warnings; the same warnings appear in the pre-existing suite runs and are not produced by
  this diff.
