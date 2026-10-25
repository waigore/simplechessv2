# Notes — #794 R2 on one line

## What the defect was

`game/puzzle_play_panel.gd` styled `PlayerElo` and `ResultCue` with
`UiChrome.style_label(…, true)`, which sets `AUTOWRAP_WORD_SMART` for every label. Inside the
centred `EloAndStatus` `HBoxContainer` that left both labels with no minimum width, so they
wrapped per character — `1×405` for `Elo 1000`, `1×48` for each cue. The #333 acceptance run
captured it in `../issue-333/graphical-20261024T150000Z/screenshots/puzzle-play-solved.png`.

## What changed (PR #802, `017a763`)

- `game/puzzle_play_panel.gd` — one seam, `_style_r2_line_labels()`, sets `AUTOWRAP_OFF` and
  `HORIZONTAL_ALIGNMENT_CENTER` on both R2 line labels. Called from `_build()` and again from
  `_style_all()`, so an S13 reflow cannot reintroduce the wrap. `UiChrome.style_label` is
  untouched: other screens' body copy depends on its wrap.
- `game/puzzle_play_test.gd` — `_r2_wrap_problem()` asserts `AUTOWRAP_OFF` plus a combined
  minimum size with non-zero width and at most two font heights, wired into the Elo reading and
  each of the four cues.

## What this run judged

Every R2 state on the merged fix at 1280×720 in the shipped playtest scene, driving the real
`C2` entry and committing real moves and controls; deals injected through `DBG.3` as the unit
test does.

| State | Copy | Rect | Autowrap | Align |
|-------|------|------|----------|-------|
| on deal | `Elo 1000` | `127×48` | 0 (off) | 1 (center) |
| solve (W1) | `Solved` | `99×48` | 0 | 1 |
| wrong move (L4) | `Wrong move` | `192×48` | 0 | 1 |
| reveal / confirm (L5) | `Failed` | `89×48` | 0 | 1 |
| abandon (L6) | `Abandoned` | `174×48` | 0 | 1 |
| after `_style_all()` | `Elo 990` | `108×48` | 0 | 1 |

Every width is at or above the text's own width at the applied font size (`Elo 1000` needs
127.0 px and gets 127 px) and every height is one line; the row is `1248×48`, not `1248×405`.

- **Graphical**: all five states read on one line and are legible; the frames are here.
- **Headless**: the same probe on the same build reports the same rects (`VERDICT=pass`), and
  `python3 .github/scripts/gdscript_tests.py test` passes 28/28.
- **No regression**: strip `1248×144`, board `1280×531` at y 189 — no overlap; the board is
  untouched by this change.

## Marks and limits

- `PuzzleStatus`, the third R2 child, still wraps and centres by design (body copy, not a
  single-line phrase); out of this defect's scope.
- `C5 Leave` returns to mode pick, judged for context. `cue_abandon` comes from C4 Abandon
  (END.L6), which is the one judged above.
- Frame timing (`SIT.4`) is not judged here; it belongs to the #333 sweep. Deals are injected,
  so the network deal path is not exercised — the #333 run's limitation, not this defect's.
- Sibling defects **#793** (S2 confirm paints nothing) and **#795** (S4 promotion labels) are
  untouched; their #333 rows stay `fail` until they land.

## Reproduce

The probe is `probe/zz_accept794_probe.gd`; it wrote the frames copied here. Graphical:
`godot --path game --resolution 1280x720 -s res://<probe>.gd`; headless: the same with
`--headless`. Import once first (`--import --quit`).
