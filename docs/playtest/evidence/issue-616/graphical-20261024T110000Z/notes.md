# Notes — issue #616 acceptance run (graphical)

What was run, the geometry table and the checks: [`run.md`](run.md),
[`readings-and-checks.md`](readings-and-checks.md). Run index: [`manifest.md`](manifest.md). Rows not
judged here: [`scope.md`](scope.md). Non-blocking marks: [`marks.md`](marks.md).

Unattended `issue-workflow-accept-agent` run (parallel id 1, `Assigned issue: none`). #616 was picked
because it is the highest-leverage `status:pending-acceptance` typed issue: it is a leaf defect under
epic #34, it already failed verification twice on guard quality, and the headless half recorded its
only remaining gap as the graphical re-run this folder supplies.

**Independence.** This session did not implement #616 and posted no comment here before this run.
Every number below comes from a detached worktree at `origin/main` `4aa6aba` in the rendered session
described in [`run.md`](run.md); none is taken from the implementation or verification comments.

## Judgement

- **`#616` AC1–AC7 all pass** on this build, and AC1–AC3 now pass on a rendered frame as well as a
  headless one. Every panel's centre x equals its parent's, and no panel moves to a fixed x at any of
  the three frame sizes.
- **`PTU-mode-pick` P5** — the legibility leg the headless run could not judge — **passes**. `O12`
  applied a real 390×844 frame (`frame_height_px=844`, `rendered_text_scale=1.31875`), every visible
  label and body string renders at 21 px or more against the `UIS.T2` need of 21 px for that frame,
  and nothing clips or overflows the 390 px width.
- **`PTU-shared-setup`** and **`PTU-shared-result`** pass their single graphical row (P1): controls
  match the story and draw inside the frame, centered.
- **`PTU-exceptions` S3** passes: the resign confirm interrupts, and Cancel returns to shared play
  with the session intact (screenshot `w1280-03-resign-confirm.png`, and the same sitting's result
  state in `w1280-04-shared-result.png`).
