# Notes — #400 full-coverage sweep

## What was run

The 23 protocols `specs/playtest/playtest.md` §Index lists, on one build (`820f202`, the `#846` fix branch tip):
12 design headless, and 11 UX headless and graphical. Two folders carry the evidence —
[`headless-20261025T230918Z/`](../headless-20261025T230918Z/manifest.md) and
[`graphical-20261025T231024Z/`](../graphical-20261025T231024Z/manifest.md) — and both name the same commit, so no protocol
is judged against a second build (AC3). Design is headless only and UX is headless and graphical (`playtest.md`
§Levels), so the headless folder judges every protocol's rows and the graphical folder re-judges the rows a display
unblocks and writes their screenshots.

## What the sweep found

**No protocol failed.** The `fail` the `#478` wave-1 re-read recorded — `UI-mode-pick.US1.10/1.11/1.13`, the S3 quit
confirm letting C1/C2/C4 through (`#846`) — does not reproduce on `820f202`: C1, C2 and C4 in S3 were all refused.
No `type:defect` was filed (AC7).

**15 judged rows are `not-judged`,** with their reasons in each protocol's `rows-<protocol>.md`: a crafted position the
build offers no seam for, a reading headless cannot take, or a spec review rather than a build observation. Under
`evidence.md` the run is complete with them and the sweep is not accepted while any remains, so the issue stays
`status:pending-acceptance` for a later run.

**One row-level `none`** is copied, never reclassified: `localization.md#US2` (`none — LOC.US2 is out of playtest
scope; judged by spec read`, `#788`). Every design row is judged on the map, so the design run records no `none`.

## Method notes

- The driver is the one `#478` kept, extended for this sweep, and is in each folder as `logs/w400_sweep.gd`.
- Three driver defects were fixed before the recorded runs, none a game reading: `difficulty-repeat` and
  `puzzle-catalog-select` sampled a random record pick while claiming a fixed id (now: the progression's own candidate
  set); `SC-puzzle-stream-visit` asserted an internal session pointer instead of the visit's committed effect (now: one
  C2 → deal → play → leave → mode pick pass, judged on the committed Last mode).
- Graphical judging made three tooling mistakes before it was right: a tap at the board's unframed square centre lands
  off the drawn board (the presentation renders through a seat transform); a "C2 in S4" probe looked for a board gesture
  on a focus sentinel the panel never forwards; and a difficulty-control probe claimed a control the setup panel does
  not build. `IN.US3` now taps the framed centre, the S4 rows use the screen's handlers, and the difficulty row is
  `not-judged` for the missing control.
- **No position seam.** Every crafted-position row is `not-judged` rather than driven through the model. S4 for the
  interface rows came from `shared_session.rules._load_fen`, a private method; those rows judge the screen's controls,
  not the rules that put the pawn there.
- The build logs `puzzle stream: deal read failed (malformed)` on the stream's boot read: the shipped build configures
  no catalog endpoint (`#648` owns whether it ships enabled) and the simulated peer answers the judged deals. Not judged.

No `specs/` file, ADR, player-facing string or gate changed (AC8).
