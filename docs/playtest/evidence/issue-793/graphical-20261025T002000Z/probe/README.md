## #793 evidence probe

Copy into `game/` to run on a display:

    godot --path game --script res://zz_probe793_prompts.gd -- <out dir> <tag prefix>

Delete it from `game/` afterwards. It drives the real entry paths through
`SessionRouter` (playtest seams alive), repaints from the live flow state, and
saves each frame plus the same frame with `BoardPresentation` hidden
(`-noboard`) so the prompt's own pixels are readable. `run-before.log` came from an
earlier revision of the same probe that also printed tree diagnostics.

Note: on this macOS display the presented frame that gets saved does not
repaint the puzzle panel after the seam-driven state changes, so the saved
frames show the board and chrome from an earlier draw. The rects, flow states
and pixel samples in `notes.md` come from these logs, not from the saved
frames.

`run-after.log` — branch `defect/793-puzzle-paint` with the fix.
`run-before.log` — the same probe with the old placement (`place_centered`, z 0).
