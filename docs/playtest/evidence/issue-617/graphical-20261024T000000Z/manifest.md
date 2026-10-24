# Evidence manifest — issue #617, acceptance run (graphical + headless)

| Field | Value |
|-------|-------|
| Issue | #617 — Shared-play piece sprites upside down (world Y-flip; demo upright) |
| Environment | `ENV.1`: graphical (native macOS window, Metal/OpenGL 4.1, 720×1280) **and** headless |
| Build | `origin/main` @ `f33b070`, clean detached worktree; Godot `4.7.2.stable.official.ed1daf0bf` |
| Protocol | `PTU-shared-play` (only UX protocol this defect can affect) |
| Coverage mode | issue acceptance criteria |

## Results

`PTU-shared-play` — **pass** in both environments.

| Story | Cited elements | Headless | Graphical |
|-------|----------------|----------|-----------|
| `UI-shared-play.US1` — both seats move on their turn, resign confirm | `SPC.E1`, `CAM-board.M2`, `TEL.1`–`TEL.5` | pass | pass |
| `UI-shared-play.US2` — board reads as the plane the player sees | `SPC.E1`, `SPC.A1`, `PER.R2` | not-judged (no display) | pass |
| `ACT-bottom-player.US1` | `ENV.1`, `SIT.4` | pass | pass |
| `ACT-top-player.US1` | `ENV.1`, `SIT.4` | pass | pass |

Protocol steps:

| Step | Graphical observation | Result |
|------|-----------------------|--------|
| S1 | Bottom seat selected then placed via real board taps; `e2`→`e4` landed, side to move flipped to black | pass |
| S2 | Top-side player moved at the rotated seat; `e7`→`e5` landed at `seat bottom`, and `d2`→`d4` / `d7`→`d5` at `seat top` | pass |
| S3 | Resign opened the confirm sheet; Cancel returned to S1; Confirm ended the game on the result screen | pass |
| S4 | Board, promotion chooser, and board frame render per screen story. Coordinate chips render as empty rounded boxes at 720×1280 (notes, non-blocking) | pass |
| S5 / SIT.4 | One timed local move (`c2`→`c4`): worst frame `4.18 ms`, budget `16.67 ms` | pass (P3) |
| S6 / SIT.5 | `assert_telemetry` over this run's own log: `shared.start` `UI-shared-play.US1`, `shared.move` `UI-shared-play.US1.3`, `shared.resign` `UI-shared-play.US1.1` → `pass` | pass (P4) |

Defects: none.

## The defect's own acceptance criteria

| The defect's own acceptance criteria (issue "Expected behavior") | Result |
|---|---|
| Seat Bottom: no raster art mirrored; pieces upright — crowns/bases up, White ranks 1–2 at the near edge (`screenshots/01`) | pass |
| Seat Top: art is Bottom's rotated 180°, nothing left-right reversed — board rotated 180°, pieces upright at that edge, knights facing the same screen direction as Bottom (`screenshots/08`, `09`) | pass |
| Promotion chooser (2×2) not mirrored — queen, rook, bishop, knight upright and in `PROMOTE_ORDER` (`screenshots/05`) | pass |
| Board backdrop shown as authored — frame/table margin grain reads as one surface with the corrected pieces (`screenshots/01`, `04`) | pass |
| Root cause fixed at the three sprite sites, not by moving the world flip — headless log keeps `world_scale=(94.4, -94.4)` at both seats, `seat_rotation=0.0000` / `3.1416` (`CAM-board.M2`) | pass |
| Regression gate present and discriminating — `gdscript_tests.py test` 26 passed; `_check_art_orientation` / `_check_orientation` wired into `_run()` | pass |

## Paths

Notes [`notes.md`](notes.md); every script, log, and screenshot path: [`paths.md`](paths.md).
