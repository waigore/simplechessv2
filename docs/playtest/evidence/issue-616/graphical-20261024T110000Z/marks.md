# Non-blocking marks — issue #616 acceptance run (graphical)

Things worth recording that no criterion turns on. Index: [`manifest.md`](manifest.md) · Judgement:
[`notes.md`](notes.md).

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
- **The first drive attempt is kept in the folder** ([`first-attempt.md`](first-attempt.md)).
  It printed `fails=0` and would have passed a weaker process with 12 non-evidence images. The
  visibility requirement plus the captured-state line is what caught it, which is worth keeping as a
  record for the next graphical drive.
- **Prior-comment facts, corrected.** The headless folder says `body_text_px=21` is reached at 390×844
  and this run confirms it; what it could not judge was the *rendered* size, which is now 21 px. The
  headless folder also says "`gdformat`/`gdlint` are not installed on this machine"; they are, under
  `/Library/Frameworks/Python.framework/Versions/3.11`, and this run ran both green.
