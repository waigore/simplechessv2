# Notes — #641 colour-blind reading of turn, clocks, side, and marks

## What this run judges

Whether each signal in #641's surface table carries a **non-colour** cue on the *published* release — a
cue that still tells the player the same thing once hue is removed. The reader is the full-severity
protanopia and deuteranopia simulation in `simulate.py`. A grayscale read is nowhere a verdict.

Not judged here: palette values, mark forms, placements, or any `K9` question. `PAL.K9` is landed
(#649 accepted 2026-10-24), `K5`/`K6` are the measured on-square rules, and where the shipped renderer
does not yet draw the landed forms, **#792** owns that change. Nothing #192, #649, or #792 already
owns is filed; the one defect here is a signal no form covers at all.

## The build under test

`https://waigore.github.io/simplechessv2/`, served commit `69a03d4` from `Web release` run 40146630737.
Identifiers, HTTP status, and artifact digests are in [`manifest.md`](manifest.md). A local export is
**not** the build under test and none was used: every capture comes from that URL over CDP at a
390 × 844 CSS px phone frame with touch emulation.

The page answered `200`, and the build reached mode pick, shared setup, shared play, and puzzle play,
so no row is `not-judged` for an unreachable build.

## How a row was read

Each row has an un-simulated frame plus `-protanopia.png` and `-deuteranopia.png` generated from that
same frame, so the three pair one-to-one. Every "nothing is painted here" claim is a pixel reading in
[`readings.json`](readings.json): board region x 78–702, y 752–1376 image px, one square 78 image px,
White at the bottom.

Two surfaces needed care before they could be read, and both are recorded rather than guessed:

- **Refused place** is `EX.rejected` / `S5`, reached by placing the selected pawn on an enemy piece it
  cannot take (`e2` → `d7`). Placing it on an *empty* square it cannot reach is `IN.deselect` by
  design, so that tap is not this surface and paints no rejection — an earlier probe of exactly that
  tap is why this folder says which pair it used.
- **Advice** needed `Advice On` in setup, which is the release default (`shared-setup-blitz.png`).

## Where the detail lives

- [`rows.md`](rows.md) — the passing rows, with the carrier each one names
- [`gaps.md`](gaps.md) — last move (`fail`, #888), advice and puzzle side (`not-judged`, with the
  issue and rule each reason names)
- [`contrast.md`](contrast.md) — `K5`/`K6` as drawn and after simulation, plus measured observations
  this run took no verdict on
- [`reproduction.md`](reproduction.md) — commands, versions, and what one browser at one frame size
  cannot prove
- [`manifest.md`](manifest.md) — the filled evidence fields, results table, and paths
