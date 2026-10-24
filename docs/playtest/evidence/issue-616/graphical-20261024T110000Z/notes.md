# Notes — issue #616 acceptance run (graphical)

What was run, the geometry table and the checks: [`run.md`](run.md). Run index: [`manifest.md`](manifest.md).

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

## Not judged here, and why that is not a failure

- `PTU-mode-pick` P3 (Switch locale) and P4 (`EX.loading` window, `SIT.4`): no step of this run
  switched locale or timed the loading window. They are not `#616` deliverables, and the verdict for
  `PTU-mode-pick` stays `not-judged` for that reason rather than being claimed whole.
- `PTU-exceptions` S1 (offline while Advice On) and S2 (illegal move attempt): not driven here. They
  do not touch panel placement and the headless folder already records the S3 leg.
- `PTU-shared-play` and `PTU-puzzle-play`: their `SIT.4` / `SIT.5` rows ask for frame timing and a
  telemetry read over a full move, which this run does not own. They are out of scope for a defect
  that only moves chrome, and the folder does not claim them.
- **Web (`ADR-0009` published URL).** The build under test is the local playtest tree, not the
  published page, because the commit is not on the published `main` build. The 390×844 reading was
  applied through `O12`, the same seam the Web playtest build exposes for `SIT.6`, but a published-URL
  re-run remains the stronger reading if the owner wants one.

## Non-blocking marks

- **The debug panel is in the screenshots.** The playtest debug panel is a shipped seam (`G1`) and the
  same `#617` drive leaves it on screen; it overlaps the phone-width captures (`phone-01`,
  `phone-03`) because at 390 px it is a large share of the frame. Nothing it overlaps is a judged
  control — the overflow count stays 0 and the 21 px reading is taken with the panel present.
- **`SaveFailure` shows dimmed puzzle chrome behind it.** `w1280-06` renders "E S I O 1" where the
  puzzle status line should be. That is the failed-commit state on `main`, not chrome placement, and
  the headless folder already records the related `EX.save-failure` routing question
  (`SessionRouter.show_save_failure` forcing `STAGE_MODE_PICK`). No `#616` criterion covers it.
- **A widened panel whose content exceeds the frame** still centres correctly and overflows both
  sides; shipped copy does not do this at any of the three sizes (`outside_frame=0` everywhere).
- **The first drive attempt is kept in the folder** ([`run.md`](run.md): "First attempt, and why it is in the folder").
  It printed `fails=0` and would have passed a weaker process with 12 non-evidence images. The
  visibility requirement plus the captured-state line is what caught it, which is worth keeping as a
  record for the next graphical drive.
- **Prior-comment facts, corrected.** The headless folder says `body_text_px=21` is reached at 390×844
  and this run confirms it; what it could not judge was the *rendered* size, which is now 21 px. The
  headless folder also says "`gdformat`/`gdlint` are not installed on this machine"; they are, under
  `/Library/Frameworks/Python.framework/Versions/3.11`, and this run ran both green.
