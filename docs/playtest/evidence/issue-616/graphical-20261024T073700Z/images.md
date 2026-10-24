# Images — issue #616, graphical acceptance run (re-recorded for #742)

A graphical run's screenshots must be rendered frames. These are. Index: [`manifest.md`](manifest.md) ·
Environment and drive: [`checks.md`](checks.md).

## Distinct, rendered content

All 19 files carry 556–4148 distinct colours, and between 3.7% and 77.4% of their pixels differ from
the frame background. They contain legible text and card borders: `ModePick` draws "Local", "Untimed",
"Puzzles" and the mode cards; `phone-02-shared-setup.png` draws "Local" and the seat controls at the
panel x 35–355.

## Geometry visible in the pixels

At 1280×720, `ModePick`'s rendered card border spans x 493–786 — centre 639.5 against the frame centre
640 — matching the `x 480, width 320` row after the card's own inset. `phone-02`'s card border spans
x 35–355, the panel row for the 390×844 frame.

## Pairwise: one expected duplicate

The one genuinely identical pair is `caps-frame-3239.png` and `phone-01-mode-pick.png`. That is the
drive, not a defect: `_capture_caps` runs immediately after the phone pass, whose last step leaves
mode-pick on screen, so the liveness capture is a capture of mode-pick. The superseded folder had the
same pair for the same reason, and this run reproduces it from a rendered session.

## Comparisons to the superseded folder

Re-rendering on this host uses a different rasteriser and font build, so bytes differ; that is expected
and is not a finding. Structurally the two folders agree, which is what a re-run of the same drive on
the same build should do:

| | Result |
|---|---|
| Ink bounding box per file | **19 / 19 identical** between this run and `graphical-20261024T110000Z` |
| Distinct colours per file | within 4% (e.g. `w1280-03` 3779 → 3889; `w1600-05` 1343 → 1459) |
| Grayscale correlation, sampled files | `w1280-01` 0.908 · `phone-02` 0.913 · `w1280-03` 0.992 |
| Pixels differing by > 16/255 | 0.9%–2.5% (text antialiasing and font rasterisation) |
