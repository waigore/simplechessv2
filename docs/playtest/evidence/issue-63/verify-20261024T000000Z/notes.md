# Verification run — issue #63 (`PER.R7` rework of PR #624)

Environment: **Graphical (native macOS window) + headless**, Godot `4.7.2.stable.official.ed1daf0bf`.
Build: `origin/main` at `614746c` (includes the merged #624 rework), clean detached worktree.
Scope: independent verification per `verify-project-issue`, judged against the issue's
acceptance criteria and the demo contract (`docs/demos.md`, `docs/demo-style-assets.md`).

This run did not implement the change and posted no earlier comment on #63. PR #624 was
authored and merged by the same `gh` identity this session runs as, so the independence
that matters here is the one this run actually exercised: none of the numbers below are
taken from the implementation comment or from the build's own probe. The coordinate
placement is measured from rendered pixels this run produced and diffed against a frame
this run rendered with the coordinate pass disabled.

## What was run

| Step | Command | Log |
|------|---------|-----|
| Import | `godot --headless --path demos/shared-game --import --quit` → exit 0 | [logs/import.log](logs/import.log) |
| Headless autodrive | `DEMO_AUTODRIVE=1 godot --headless --path demos/shared-game` → `[demo] PASS` | [logs/autodrive.log](logs/autodrive.log) |
| Graphical autodrive | `DEMO_SHOT_DIR=… DEMO_AUTODRIVE=1 godot --path demos/shared-game --resolution 720x1280 --rendering-driver metal` → `[demo] PASS`; writes both screenshots and runs the rendered-ink check | [logs/graphical-autodrive.log](logs/graphical-autodrive.log) |
| Headless drawing probe | `DEMO_COORD_PROBE=1 DEMO_AUTODRIVE=1 … DEMO_COORD_PROBE_OUT=…` → `[demo] PASS`; `check_coord_probe.py` → `PASS` | [logs/autodrive-probe.log](logs/autodrive-probe.log), [logs/coord-probe.txt](logs/coord-probe.txt) |
| Labels-off frame | `PROBE_OUT=… godot --path demos/shared-game --script make_nolabels_probe.gd --resolution 720x1280` (hides the `Coordinates` Control, same frame) | [make_nolabels_probe.gd](make_nolabels_probe.gd) |
| Spec lint | `python3 .github/scripts/spec_lint.py` → 0 errors, 1 pre-existing warning | — |

Screenshots: [screenshots/demo-shared-game-exercise.png](screenshots/demo-shared-game-exercise.png),
[screenshots/demo-shared-game-mate.png](screenshots/demo-shared-game-mate.png),
[screenshots/nolabels.png](screenshots/nolabels.png) (the labels-off diff frame).

## `PER.R7` measured from rendered pixels

Method: diff the graphical exercise frame against the same frame with the coordinate pass
hidden. Every differing pixel inside the coordinate regions is coordinate ink, so its
position and its background are exact. Frame 720×1280; 8×8 at x 72..648, y 352..928.

| Region | Ink measured (this run) | `PER.R7` wants | Verdict |
|--------|-------------------------|----------------|---------|
| Left band (ranks 1–8) | ink at **x 37..47**, y 381..823 — one numeral per rank row | inside the left band (x ≈ 25..61), never inside the 8×8 | **Pass** |
| Bottom band (files a–h) | ink at **y 950..964**, x 103..610 — one letter per file column | inside the bottom band (y ≈ 935..977), never inside the 8×8 | **Pass** |
| Square membership | **0** solid ink pixels inside the 8×8, in either region | never inside squares | **Pass** |
| Contrast | ink `PAL.C9` on the `PAL.C1` band `(232, 213, 181)` = **9.95:1** | ≥ 4.5:1 | **Pass** |
| Size | `UIS.T2` face 16.0 px, 18.0 screen px at the 640 px reference frame; line box 23.0 px in a 32.0 px band | ≥ `UIS.T2` at the 640 reference | **Pass** |

The shipped build's own probe agrees with the render rather than with itself: its
predicted rank boxes (x 38.2..48.2) bracket the ink the renderer actually drew (x 37..47).
The prior verification found the opposite — the probe asserted `text_rect` geometry while
the render put the numerals at x 74..80 inside the a-file — so this run checks the
rendered frame, not the computed box, for the finding that failed before.

## Other deliverable checks

- **Assets** — all 20 `assets.json` IDs resolved against `asset_catalog/*.json`: every
  entry `state: approved` with `review.verdict: Pass`, every cited file present under
  `game_assets/` / `audio_runtime/`, no review exemption used. No catalog file changed in
  the rework.
- **Spec citations** — 72 distinct spec IDs cited in `demos/shared-game/README.md` checked
  against `specs/`; all resolve. (`CoordLabels.spots` is not a spec ID: it is a source
  symbol in D13's code-reference column.)
- **README against the build** — the `PER.R7` Included row and D13 state the ink sits on the
  `PAL.C1` inlay bands at 9.95:1 with both bands outside the 8×8, which is what the render
  shows. Question, type (`Engine demo`), issue, included/excluded sets, D1–D14, A1–A4, and
  run steps are present.
- **Isolation** — `demos/shared-game/` is a standalone `project.godot`; no file under
  `game/` references `demos/`. Demo code stays out of `review-code` per `docs/demos.md`.
- **`AES.P1`–`P3`** — every scripted move 0–3 ms against the 150 ms budget
  (`TRAVEL_S`/`RETURN_S` = 0.15 s); piece bodies measured at the one scale, K 0.85,
  Q 0.79, B 0.76, N 0.75, R 0.68, P 0.62 per `FRM.P2`; mahogany board, wooden bevel, rose
  only for check and refusal.

## Findings (non-blocking)

1. The checked-in logs from the implementing run are stale relative to the shipped build:
   [rework-20261024T000000Z/logs/autodrive-probe.log](../rework-20261024T000000Z/logs/autodrive-probe.log)
   records `coordinates 6.5 px glyph ink 9.0 px in a 11.5 px band` and
   [coord-probe.txt](../rework-20261024T000000Z/logs/coord-probe.txt) ranks at x 57.5..60.5,
   while the shipped build prints 16.0 px / 23.0 px in 32.0 px and ranks at x 38.2..48.2.
   No impact on the build. It does make the evidence trail misleading; worth regenerating
   when the demo next changes.
2. `check_coord_probe.py` docstring says ink boxes "are conservative against the band by
   construction", but it reuses `CoordLabels.text_rect`, the wrapper that also positions the
   ink. It is a useful dump checker, not an independent guard; the graphical
   `coord_ink_problems()` path is the guard that measures pixels. Wording only.

Pipeline findings: the rework's own F1 ("this host cannot open a Godot window, a graphical
run is worth doing at verification") is resolved by this run: the graphical autodrive ran
on a native macOS window at 720×1280 and passed.
