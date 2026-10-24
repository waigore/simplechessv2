# Manifest

- **Issue**: 769 — promote the advice keep list into main code (`PER.R5` mark form)
- **Environment**: graphical (`ENV.2`), Godot 4.7.2.stable.official.ed1daf0bf, macOS arm64 (Apple M5), Metal compatibility renderer, native window. No browser: the run drives the shipped release scene graph, not the exported Web build.
- **Build / session id**: branch `task/769-promote-advice`, off `origin/main` `4f133e8`. Shipped graph: `main_release.tscn` (no `PlaytestSeams`).
- **Coverage mode**: headless (`ENV.1`) units plus one graphical measurement leg (`ENV.2`), limited to the element this task changes.
- **Backend**: none. Advice is switched Off in the probe; the marks are rendered directly through `BoardPresentation.render_advice` (E4), so no Stockfish, UCI, or simulated peer is involved (ADR-0002).

## Results

| Step | Result | Evidence |
|------|--------|----------|
| `PER.R5` mark form is PAL.K9's edge brackets (one stroke per edge midpoint, corners open) | pass | `advice_ui_test.gd` `_marks_fit_the_body_bound`: four edge directions asserted, each stroke on its edge midpoint |
| Marks + arrow cover ≤ 10% of any body | pass | [`ink-run.log`](ink-run.log): twelve pieces, worst `0.13%` (queen and King); every other body `0.00%` |
| Marks and arrow drawn (`PER.R5`) | pass | `advice_ui_test.gd` `_marks_show_and_clear`: `11` strokes = 4 edge brackets per square + a 3-stroke arrow |
| Stroke clears the `UIS.I1` 1.5 screen px floor (3.6 px at `PRJ.P1`) | pass | `_marks_fit_the_body_bound` stroke-floor check |
| Unit tests / Coverage / Code lint | pass | 31 suites; 86.7% statement-line coverage (threshold 80); `gdformat --check` and `gdlint` clean |

## Defects filed

- None. The edge-bracket form is a regression this task repairs, not a new defect.

## Paths

- [`ink_probe.gd`](ink_probe.gd) — the graphical probe
- [`ink-run.log`](ink-run.log) — the run it produced
