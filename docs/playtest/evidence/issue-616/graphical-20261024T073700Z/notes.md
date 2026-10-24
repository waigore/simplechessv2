# Notes — issue #616 graphical acceptance run (re-recorded for #742)

Index: [`manifest.md`](manifest.md). What was judged here: the graphical half of the `#616`
acceptance criteria and the four UX protocols whose surfaces this defect changes.

## What was judged

The three desktop/phone frames driven through real controls, on `origin/main` `cbce7cd`. All six panels
are centred on their containing rect at all three sizes, at their unchanged vertical tops, and no
control inside them draws outside the frame. The four protocols split into two `pass`, two `not-judged`
on rows no `#616` deliverable reaches ([`protocols.md`](protocols.md)).

The screenshots are rendered frames, and the geometry is visible in them: the rendered `ModePick` card
border at 1280×720 spans x 493–786, centre 639.5 against the 640 frame centre
([`checks.md`](checks.md) *Images*).

## Why this run replaces the superseded folder

#742 rejected `graphical-20261024T110000Z` as a headless session labelled graphical. Measuring the
committed images on this host does not support that: they carry 552–4003 distinct colours and legible
copy, and a fresh re-render of the same drive reproduces **their ink bounding box in all 19 files**,
with grayscale correlation 0.908–0.992. Two of #742's sub-claims are true but were misread — the
`caps-frame` / `phone-01` pair is byte-identical because the drive captures mode-pick twice, and the
geometry does reproduce headless because geometry is layout, not rendering.
[`corrections.md`](corrections.md) records each claim and its measurement.

This folder is nevertheless the one acceptance should cite: it names its environment from the engine,
its drive cannot write into another run's folder, and it fails rather than capturing when it runs
headless. The superseded folder's hard-coded output path is what made the environment claim hard to
falsify, and that is the real defect #742 found.

## Non-blocking marks

- This run's rasteriser is Mesa llvmpipe under `xvfb-run`, not a physical GPU. It is `ENV.2` — a full
  rendered session with real text rasterisation — but its antialiasing and font hinting differ from
  the superseded run's. Bytes therefore differ while layout does not.
- `SIT.6` is exercised through `O12` on the local playtest build, as the superseded run did, not on the
  published Web build that `PTU-mode-pick` S6 names. Web publication of this commit is out of scope for
  this defect.
- `caps-frame-3239.png` duplicates `phone-01-mode-pick.png` by construction. It is a liveness reading,
  not a nineteenth distinct judged state.
