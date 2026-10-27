# Notes — issue #616, independent acceptance re-run

## What this run accepted, and what it did not re-judge

The acceptance question after #742 is narrow: is the folder that carries the graphical half what it
says it is, and do the six panels draw centred on the build that is on `main` today. Both were answered
by re-running the committed drive on a clean worktree — see [`reproduction.md`](reproduction.md) — and
by decoding the resulting PNGs rather than trusting the log rows.

Protocol rows for `PTU-mode-pick` (P3, P4) and `PTU-exceptions` (S1, S2) remain `not-judged` in the
inherited folder. No `#616` deliverable reaches those rows: they judge screens the placement defect does
not touch, and the folder states that scope. That is not a fail and files no defect; a `full` sweep of
every protocol row belongs to the playtest sweep task, not to this defect.

## Non-blocking marks

- **Oversized content still overflows a narrow frame.** The guard's synthetic widened copy (1141 px at
  a 390 px frame) stays centred but exceeds the frame on both sides — measured again here through the
  drive's `outside_frame` rows, which stay `0` because the shipped copy fits. Clamping oversized content
  would be a new behaviour with no spec row behind it, so it is a separate issue if wanted, not this
  defect.
- **`SessionRouter.show_save_failure` still forces `stage = STAGE_MODE_PICK` after a failed puzzle
  commit**, where `specs/technical/failures.md` (T2, M2) and `specs/ux/screens/puzzle-play.md` S3 put the
  player in puzzle play with a dismissible dialog. No `#616` criterion covers it; it is `EX.save-failure`
  routing and remains unowned. Recorded here so it is not lost.
- The judged source range includes a newer `main` (`4e4b724`) than the folder's build stamp
  (`cbce7cd`). The intervening commits touch documentation and unrelated code only — `git log` over the
  four placement files shows `place_centered` unchanged since `efded68` (#695).
- Godot is not on `PATH` on this host; the runs used `~/.godot-cache/Godot_v4.7.2-stable_linux.x86_64`,
  the version the folder names.
