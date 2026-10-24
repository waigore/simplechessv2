# Manifest — issue #793, defect run (graphical)

Index for this run. The probe and its logs: [`probe/`](probe/README.md). Judgement text and the
readings behind it: [`notes.md`](notes.md).

- **Issue**: #793 — puzzle-play `StreamConfirm` (S2) and `SaveFailure` (S3) prompts do not paint over
  the board
- **Environment**: `ENV.2` graphical (`DisplayServer` = `macOS`, Godot `4.7.2.stable.official`)
- **Build / session id**: local playtest tree on branch `defect/793-puzzle-prompt-paint` at base
  `8cdfd45`, the shipped `game/main.tscn` in a rendered session with the playtest seams alive; not a
  published build, no `TEL.3` id. Run id `graphical-20261025T002000Z`.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run.
- **Coverage mode**: `full` for the two prompts (S2 leave confirm, S3 save failure) and the shared-play
  resign control
- **Screenshots**: `screenshots/` — 9 PNG files. Prompts are additionally saved with
  `BoardPresentation` hidden (`-noboard`); see the reading limit in [`notes.md`](notes.md) before
  treating a saved frame as what the display showed.

## Results

| Unit | Outcome |
|------|---------|
| #793 fault 1 — prompt band clears the board | pass — `StreamConfirm` and `SaveFailure` sit in `Presentation.OVERLAY_Z` (20) above every board layer (`Board` 1, `Pieces` 3, `Overlays` 4, `AdviceMarks` 5+4, dragged piece 10) |
| #793 fault 2 — focused control label stays legible | pass — `UiChrome.style_button` writes `COLOR_INK` for focus / hover / pressed / hover-pressed; `font_focus_color` was the near-white default (`#f2f2f2` on `#f7f1e8`, 1.0 contrast) |
| Guard — `ChromePaintTest` fails before, passes after | pass — fails on the base commit (`prompt z 0 does not clear the board layer AdviceMarks (z 9)`, `ConfirmStream's label as f2f2f2 in font_focus_color: 1.0 contrast`), passes with the fix |
| Guard — `ChromePlacementTest` (`#616`) still passes | pass — 2 frames, print / widen / children-inside |
| `Code lint` | pass — `gdlint game` "no problems found", `gdformat --check game` 63 files unchanged |
| `Unit tests` | pass — 29/29 |
| `Coverage` | pass — 86.5% (4661/5389), threshold 80 |

Defects: none filed from this run. The run is the fix for #793 itself.
