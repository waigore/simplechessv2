# Notes — #478 graphical run `20261025T205830Z`

Unattended `issue-workflow-implement-agent` run for #478.

The nine wave-1 UX protocols re-run on the same commit as the
[headless run](../headless-20261025T205500Z/notes.md), with the screenshots each
protocol requires. The design protocols are headless-only. Rows:
[manifest.md](manifest.md).

## Result

**5 pass, 2 fail, 2 not-judged** over the nine UX protocols; 15 pass, 2 fail,
5 not-judged over the 20 UX story rows. `errors=[]`, no `SCRIPT ERROR`, 267
`TEL.*` lines, 28 screenshots under `screenshots/`. The two `not-judged` protocols
(`PTU-shared-play`, `PTU-exceptions`) carry the same crafted-position gaps as the
headless leg.

This leg judges what headless cannot:

- `controls-point.md#US3` — **pass** here, `not-judged` headless (pointing needs a
  display). `PTU-controls` is therefore `pass` in this leg.
- `LOC.US1.3` piece-name rows on `shared-play` — read against the Copy table that
  owns them (`shared-play` keys `queen`, `rook`, `bishop`, `knight` stay the `en` value
  in all three locales). The on-screen promotion chooser (`C6`) is a board surface and
  draws no `Queen` label, so the Copy table is the correct reading, not a text node.

Both failures are the same story row the headless leg fails —
`screens/mode-pick-unavailable.md#US1`, filed as **#846** — so the two legs agree.

## Screenshots and #846

Screenshot 03 (`mode-pick-quit-confirm.png`) shows the state the story describes: S3
with only Confirm and Cancel focused and the mode buttons gone. The build hides them
correctly at rest; #846 is that the input rail still acts on them while S3 is up, which
a screenshot taken at rest cannot show. That is why the row is judged by driving the
controls rather than by looking at a still, and why both legs fail it identically.

## AC 8 — art opened at run time

From `logs/static.json` (`TEL.*` `report.assets`), read before protocol step 1:

- boot group: **11 of 11 opened**, unresolved **0**
- wave-1 `play` group: **19 of 19 opened**, unresolved **0**
- `boot_outcome` `0`, `session_playable` `true`, `log_counts` `{}`

Identical to the headless run, so both legs judged the same rendered surface.

## Driver

`logs/w400_sweep.gd` is the run's driver, kept verbatim. Run it with:

```
W400_KIND=graphical W400_OUT=<dir> godot --path game --script res://_w400/w400_sweep.gd
```

Screenshots are numbered in run order so the manifest table reads top to bottom with
the run.
