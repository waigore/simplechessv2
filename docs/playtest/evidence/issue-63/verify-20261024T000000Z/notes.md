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

- [`per-r7.md`](per-r7.md) — the `PER.R7` measurement from rendered pixels.
- [`checks.md`](checks.md) — the other deliverable checks and the non-blocking findings.

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
