# #546 verification — notes

Verify pass (`issue-workflow-verify-agent`, parallel id 1, unattended) on `origin/main`
`161b4a9`, clean detached worktree, Godot `4.7.2.stable.official.ed1daf0bf`.

## What was re-derived rather than taken from the record

The issue's last two passes agree that the seam is landed: the 2026-10-24 verify pass on
`e47b8ef`, the 2026-10-25 acceptance pass on `f1a62f0` that failed `S6` on #837, and the
2026-10-25 implement pass on `161b4a9` that re-measured it after #848/#847. This pass did
not reuse their probes or their numbers. It wrote its own probe and re-measured on the
current default branch, because the #837 fix (`f320535`, PR #848) landed *after* both
earlier verdicts and is the only thing that could have changed the outcome.

## The one place a naive reading of the render misleads

A per-string width test flags the mode-pick title: at 37 px the string
`Choose how to play` measures 340 px in a 272 px box (`text_w=340` vs box width 272), which
looks like horizontal clipping on first pass. It is not. `UiChrome.style_label` sets
`AUTOWRAP_WORD_SMART`, so the title lays out as **2 lines** and its own minimum height grows
from 99 px (desktop 32 px font) to 111 px (phone 37 px font); `get_line_count()` equals
`get_visible_line_count()` (2/2), so nothing is hidden. The focused measurement:

```
DESKTOP-1280 rect=[P: (504.0, 104.0), S: (272.0, 99.0)]  font_px=32 lines=2 visible_lines=2
PHONE-390x844 rect=[P: (59.0, 104.0), S: (272.0, 111.0)] font_px=37 lines=2 visible_lines=2
```

The screenshot (`screenshots/s6-phone-390x844.png`) confirms the wrap renders as two
readable lines with no glyph cut. `F3` ("clipped or sub-`UIS.T2` text at phone width") does
not fire.

## #837 does not reproduce on this build

`set_viewport` collapses the debug chrome before it measures
(`game/playtest_seams.gd` `_collapse_debug_panel`), and the report carries
`"debug_panel_visible":false`. On the render, the only playtest chrome is the collapsed
`Show seams` header at the top-left; its rect does not intersect the mode-pick panel
(`overlaps_panel=false`, overlap area 0). The acceptance run's failure — panel over the
copy — is gone.

## Coverage command could not run locally

`gdscript_tests.py coverage` stops with *"gdtoolkit==4.5.0 is required"* because it imports
`gdtoolkit` as a module while this machine has only the 4.5.0 CLIs (`gdformat`, `gdlint`)
on `PATH` for Python 3.11. The `Coverage` CI check on the deliverable PRs was green and the
deliverable adds four lines of test and a small seam branch, so the ratio is not in doubt;
recording the gap rather than claiming a number this pass did not measure.

## Delivered landing points (read, then re-measured)

| Deliverable | Commit / PR |
|---|---|
| `O12 set_viewport` initial seam | `1d3a164` (PR #593) |
| frame-true reflow | `152260e` → `e91d6cf` (PR #716) |
| rendered-frame report | `d8a3cb2` (PR #652), `614746c` (PR #653) |
| #837 chrome collapse | `f320535` (PR #848), `4de4459` (PR #847) |
| `S13` tests in the shared `_check_playtest` | in the above, plus `game/playtest_seams_measure_test.gd` |
