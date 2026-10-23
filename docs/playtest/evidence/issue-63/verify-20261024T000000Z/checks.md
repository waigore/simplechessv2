# Other deliverable checks and findings

Part of the [issue #63 verification run](notes.md). The `PER.R7` measurement from rendered
pixels is in [`per-r7.md`](per-r7.md).

## Deliverable checks

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
