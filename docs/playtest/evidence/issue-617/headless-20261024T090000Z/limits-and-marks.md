# Limits and marks — issue #617 acceptance run (headless)

Sections moved out of [`notes.md`](notes.md) to keep that file inside the
`docs/` word limit. Read them together.

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
