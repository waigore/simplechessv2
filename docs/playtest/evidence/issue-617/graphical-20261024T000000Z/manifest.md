# Evidence manifest — issue #617, acceptance run (graphical + headless)

| Field | Value |
|-------|-------|
| Issue | #617 — Shared-play piece sprites upside down (world Y-flip; demo upright) |
| Environment | `ENV.1`: graphical (native macOS window, Metal/OpenGL 4.1, 720×1280) **and** headless |
| Build | `origin/main` @ `f33b070`, clean detached worktree; Godot `4.7.2.stable.official.ed1daf0bf` |
| Protocol | `PTU-shared-play` (only UX protocol this defect can affect) |
| Coverage mode | issue acceptance criteria; protocol steps S1–S6 |

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
| S4 | Board, promotion chooser, and board frame render per screen story. Coordinate chips render as empty rounded boxes at this 720×1280 viewport (see notes, non-blocking) | pass |
| S5 / SIT.4 | One timed local move (`c2`→`c4`): worst frame `4.18 ms`, budget `16.67 ms` | pass (P3) |
| S6 / SIT.5 | `assert_telemetry` over this run's own log: `shared.start` `UI-shared-play.US1`, `shared.move` `UI-shared-play.US1.3`, `shared.resign` `UI-shared-play.US1.1` → `pass` | pass (P4) |

Defects: none.

## The defect's own acceptance criteria

| Criterion (issue "Expected behavior") | Graphical evidence | Result |
|---|---|---|
| Seat Bottom: no raster art mirrored; pieces upright | `screenshots/01-seat-bottom-start.png` — White ranks 1–2 at the near edge, every piece crown/head up, dark squares and coordinates read normally | pass |
| Seat Top: art is Bottom's rotated 180°, nothing left-right reversed | `screenshots/08-seat-top-start.png`, `screenshots/09-seat-top-after-moves.png` — board rotated 180°, White at the far edge and Black near, pieces upright to the viewer at that edge; asymmetric knights face the same screen direction at both seats | pass |
| Promotion chooser (2×2) not mirrored | `screenshots/05-promotion-chooser-bottom.png` — queen, rook, bishop, knight in the 2×2 all upright | pass |
| Board backdrop shown as authored | `screenshots/01-seat-bottom-start.png`, `04-resign-confirm.png` — frame/table margin grain reads consistently with the corrected pieces | pass |
| Root cause fixed at the three sprite sites, not by moving the world flip | headless log: `world_scale=(94.4, -94.4)` retained at both seats, `seat_rotation=0.0000` / `3.1416` (`CAM-board.M2`) | pass |
| Regression gate present and discriminating | `gdscript_tests.py test` → 26 passed on this build; group `_check_art_orientation` / `_check_orientation` wired into `_run()` | pass |

## Paths

| Artifact | Path |
|----------|------|
| Graphical notes | [`notes.md`](notes.md) |
| Graphical drive script | [`drive_graphical.gd`](drive_graphical.gd) |
| Graphical runner | [`run_graphical.sh`](run_graphical.sh) |
| Graphical drive log (session excerpt, `TEL.*` included) | [`logs/graphical-drive.log`](logs/graphical-drive.log) |
| Seat Bottom start | [`screenshots/01-seat-bottom-start.png`](screenshots/01-seat-bottom-start.png) |
| Seat Bottom after S1 move | [`screenshots/02-seat-bottom-after-bottom-move.png`](screenshots/02-seat-bottom-after-bottom-move.png) |
| Seat Bottom after both seats moved | [`screenshots/03-seat-bottom-after-both-moves.png`](screenshots/03-seat-bottom-after-both-moves.png) |
| Resign confirm (S3) | [`screenshots/04-resign-confirm.png`](screenshots/04-resign-confirm.png) |
| Promotion chooser | [`screenshots/05-promotion-chooser-bottom.png`](screenshots/05-promotion-chooser-bottom.png) |
| Resign result screen | [`screenshots/06-resign-result.png`](screenshots/06-resign-result.png) |
| Shared setup, White seat Top | [`screenshots/07-seat-top-setup.png`](screenshots/07-seat-top-setup.png) |
| White seat Top start | [`screenshots/08-seat-top-start.png`](screenshots/08-seat-top-start.png) |
| White seat Top after moves | [`screenshots/09-seat-top-after-moves.png`](screenshots/09-seat-top-after-moves.png) |
| Headless drive script | [`../headless-20261024T000000Z/drive_headless.gd`](../headless-20261024T000000Z/drive_headless.gd) |
| Headless drive log | [`../headless-20261024T000000Z/logs/headless-drive.log`](../headless-20261024T000000Z/logs/headless-drive.log) |
