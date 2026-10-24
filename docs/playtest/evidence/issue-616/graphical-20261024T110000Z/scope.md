# Scope — issue #616 acceptance run (graphical)

Rows this run does not judge, and why that is not a failure. Index: [`manifest.md`](manifest.md) ·
Judgement: [`notes.md`](notes.md) · Rows that were judged: [`protocols.md`](protocols.md).

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
