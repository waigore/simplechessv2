# Notes — issue #616 acceptance run (headless)

What was run, the geometry table, the mutant and the guard run: [`run.md`](run.md). Run index: [`manifest.md`](manifest.md).

Unattended `issue-workflow-accept-agent` run (parallel id 1, `Assigned issue: none`).
#616 was discovered as the only `status:pending-acceptance` typed issue without an open
blocker, with its fix merged on `main`.

**Independence.** This session did not implement #616 and posted no comment here before this
run. No geometry number below is taken from the implementation or verification comments: every
one comes from a clean detached worktree at `origin/main` `2ccea5c`.

## Judgement

Every AC1–AC6 row of `manifest.md` passes on this build. AC7 was judged from the merged PR file
lists; `Code lint` was not run locally (see [`run.md`](run.md)), so AC7 rests on file lists, not on
a local lint run.

## Not judged here

- Everything `PTU-*` needs from a display: `PTU-mode-pick` P5 (`SIT.6` legibility) and P2, plus
  the graphical half of every UX protocol verdict. This defect changes where chrome is drawn, so
  the graphical re-run of `2ccea5c` is required before acceptance; the omission is not a defect.
- Web. The probe ran the desktop headless build; the same `canvas_items` / `expand` frame applies
  on Web and the phone-width frame above covers the geometry, not the rendered Web output.

## Non-blocking marks

- A widened panel whose content exceeds the frame (the guard's synthetic 1141 px copy at 390 px)
  centres correctly but overflows both sides. Shipped copy does not; clamping oversized content
  would be new behaviour with no spec row.
- The `SaveFailure` dialog is reached here by a failed puzzle commit, which also logs the
  expected `persist_store` write error; that is the seam working, not a fault of the placement.
- `SessionRouter.show_save_failure` still forces `stage = STAGE_MODE_PICK` on a failed puzzle
  commit. No `#616` criterion covers it; it is an `EX.save-failure` routing question for its own
  issue.
