# Notes — issue #616 acceptance run (headless)

Unattended `issue-workflow-accept-agent` run (parallel id 1, `Assigned issue: none`).
#616 was discovered as the only `status:pending-acceptance` typed issue without an open
blocker, with its fix merged on `main`.

**Independence.** This session did not implement #616 and posted no comment here before this
run. No geometry number below is taken from the implementation or verification comments: every
one comes from a clean detached worktree at `origin/main` `2ccea5c`.

## What was run

`probe_616_acceptance.gd` instantiates `res://main.tscn`, drops the `PlaytestHarness`, and drives
the six panels open **through `SessionRouter` controls** (C1, C2, C5, C4, cancel, confirm, and one
failed puzzle commit with `force_write_failure`) at 1280×720, 1600×900 and 390×844. It records
`get_global_rect()` of each panel and of its parent, and counts the panel's descendant controls
whose drawn rect leaves the frame.

`mutant_616.gd` reinstates the filed defect on one screen panel (`ModePick`, parent
`ScreenHost`) and one dialog (`ResignConfirm`, parent `SharedPlayPanel`) to confirm AC4 is a real
constraint, not an artefact of the probe.

## Results

| Frame | `ModePick` | `SharedSetup` | `SharedResult` | `ResignConfirm` | `StreamConfirm` | `SaveFailure` |
|---|---|---|---|---|---|---|
| 1280×720 | x 480, top 80 | x 480, top 60 | x 480, top 120 | x 500, top 200 | x 500, top 220 | x 500, top 220 |
| 1600×900 | x 640, top 80 | x 640, top 60 | x 640, top 120 | x 650, top 200 | x 660, top 220 | x 660, top 220 |
| 390×844 | x 35, top 80 | x 35, top 60 | x 35, top 120 | x 52.5, top 200 | x 55, top 220 | x 55, top 220 |

`centre_dx` is 0.0 and the top deltas 0.0 for every row, so AC1–AC3 hold. At 390×844 the shipped
copy leaves every panel inside the 390 px frame (`ModePick` 35–355) and no descendant control of
any judged panel draws outside the frame (checked on all three frames).

Mutant: `MEASURE ModePick rect=[P: (40.0, 80.0)] dx=440.0`, `MEASURE ResignConfirm
rect=[P: (40.0, 200.0)] dx=460.0`. Re-imposing the old pattern still produces the filed symptom,
so the shipped placement (not the probe) is what makes AC1–AC3 hold.

Guard (AC5): with `place_centered` short-circuited to `PRESET_TOP_LEFT` + `position = (40, top)`
for `ModePick`, the suite fails on `ModePick drawn centre x off by 440.0 px at (1280.0, 720.0)`
and the file was restored (`git status --porcelain` empty afterwards).

`Code lint` was not run by this session: `gdformat`/`gdlint` are not installed on this machine and
the install was outside the run's scope. AC7 was judged from the merged PR file lists (code files
only, no `specs/` file, no layout, content or node-name change); CI lint status on the merged PRs
was not re-read here.

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
