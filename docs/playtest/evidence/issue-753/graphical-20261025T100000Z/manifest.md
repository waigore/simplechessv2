# Evidence manifest — issue #753, acceptance run (graphical)

| Field | Value |
|-------|-------|
| Issue | #753 — the S3 (`EX.error`) board gate refused all gestures |
| Environment | `ENV.2`: graphical — native macOS window, Metal, `720×1280`, Godot `4.7.2.stable.official.ed1daf0bf` |
| Build | `origin/main` @ `4e50418` (PR #798 merge), clean detached worktree; same build as the headless run |
| Session id (`TEL.3`) | `sess-1792867206447-56378-playtest-374126` (see `logs/drive.log`) |
| Protocols | `PTU-exceptions` (`EX.US1`, step S1 → `EX.US1.5`) and `PTU-controls` (`IN.US1`, `IN.US2`, `IN.US3`) |
| Coverage mode | `full` (intersected with issue scope) |
| Defects | none |

## Results

Both protocols — **pass** on Graphical; with the [headless run](../headless-20261025T100000Z/manifest.md), every required environment is present.

| Story row | Judging protocol | Headless | Graphical |
|-----------|------------------|----------|-----------|
| `EX.US1` (`exceptions.md#US1`), reached `US1.5` | `PTU-exceptions` | pass | pass |
| `IN.US1` (`controls.md#US1`) | `PTU-controls` | pass | pass |
| `IN.US2` (`controls-drag.md#US2`) | `PTU-controls` | pass | pass |
| `IN.US3` (`controls-point.md#US3`) | `PTU-controls` | pass | pass |

## Steps (rendered observations)

| Step | Graphical observation | Screenshot | Result |
|------|-----------------------|------------|--------|
| Shared start | Board drawn, `White to move`, chrome row (`Advice On / Resign / Offer draw`) | `01-shared-play-s1-start` | pass |
| `PTU-exceptions` S1 | `EX.error` panel: **"Advice unavailable. Play continues."** with a **Dismiss** button, over a live board | `02-s3-exerror-panel` | pass |
| `PTU-controls` C1 in S3 | Tapping `e2` selects it (highlight + legal-target dots) with `EX.error` up | `03-s3-selected-e2` | pass |
| `PTU-controls` S1/S4 in S3 | After tap-place and drag moves the board shows the moved pieces, `EX.error` and Dismiss still up, service offline | `04-s3-after-tap-and-drag-moves` | pass |
| `PTU-exceptions` Then / `EX.US1.5` | After Dismiss the panel is gone, play is `S1`, and the board is usable | `05-s1-after-dismiss` | pass |
| End of run | Second real failure reproduced and driven again; final state rendered | `06-final-state` | pass |
| `IN.US3` | Pointer over Dismiss fires `IN.point` only; Tab chain `AdviceToggle → Resign → OfferDraw → …` | — | pass |

All 38 assertions in the drive are `ok:` in `logs/drive.log`; `FAILURES []`.

## Screenshot method

`/usr/sbin/screencapture` cannot capture this host's display (Screen Recording is not granted to the automation process). The screenshots are the **Godot process's own rendered framebuffer** (`root.get_texture().get_image()` → PNG, 720×1280) from a rendered, non-headless session of this build — the #617 method.

## Paths

| Artifact | Path |
|----------|------|
| Manifest | [`manifest.md`](manifest.md) |
| Notes | [`notes.md`](notes.md) |
| Graphical drive script | [`drive_graphical.gd`](drive_graphical.gd) |
| Graphical drive log (`TEL.*` included) | [`logs/drive.log`](logs/drive.log) |
| Shared S1 start | [`screenshots/01-shared-play-s1-start.png`](screenshots/01-shared-play-s1-start.png) |
| S3 `EX.error` panel | [`screenshots/02-s3-exerror-panel.png`](screenshots/02-s3-exerror-panel.png) |
| S3 selection | [`screenshots/03-s3-selected-e2.png`](screenshots/03-s3-selected-e2.png) |
| S3 after tap + drag moves | [`screenshots/04-s3-after-tap-and-drag-moves.png`](screenshots/04-s3-after-tap-and-drag-moves.png) |
| After Dismiss (S1) | [`screenshots/05-s1-after-dismiss.png`](screenshots/05-s1-after-dismiss.png) |
| Final state | [`screenshots/06-final-state.png`](screenshots/06-final-state.png) |
| Headless drive + log | [`../headless-20261025T100000Z/`](../headless-20261025T100000Z/) |
