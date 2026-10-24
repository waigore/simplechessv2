# Manifest

- **Issue**: 794 — Puzzle-play R2 Elo and result cue wrap to one letter per line
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, macOS Metal
  (Apple M5, Compatibility renderer), shipped playtest scene `game/main.tscn`, frame 1280×720.
- **Build / session id**: `origin/main` at `017a763` (the squash of PR #802, "Keep puzzle-play R2
  on one line (#794)"). `TEL.3` session `sess-1792862689938-27441-playtest-386259`
  (`logs/probe-graphical-1280x720.log`).
- **Timing (`SIT.4`)**: **not judged** in this run. #794 is a text-layout defect; no frame-time
  sample is claimed here. `PTU-puzzle-play` P3 belongs to the #333 sweep.
- **Coverage mode**: partial — one defect, one row. Only `UI-puzzle-play` S5 / `US2` (R2) is
  judged here; the #333 acceptance run owns the whole screen and its other rows stay `fail`
  there until #793 and #795 land.
- **Deal source**: `DBG.3` — dealt records injected into the live session, as
  `game/puzzle_play_test.gd` does; the seams build's catalog peer answers no read by default.
  Entry is the real `C2` control from mode pick. The network deal path is not exercised.

## Results

| Story / step | Outcome | Notes |
|--------------|---------|-------|
| `PTU-puzzle-play` S5 — `GS.playerElo` reads on one line (`US2`) | **pass** | `Elo 1000` at `[P: (568, 12), S: 127×48]`, `autowrap=0`, `align=1`, text needs 127.0 px. `screenshots/r2-1280x720-on-deal.png` |
| `PTU-puzzle-play` S5 — `cue_solved` reads on one line | **pass** | `Solved` at `99×48`. `screenshots/r2-1280x720-solved.png` |
| `PTU-puzzle-play` S5 — `cue_wrong` reads on one line | **pass** | `Wrong move` at `192×48`. `screenshots/r2-1280x720-wrong.png` |
| `PTU-puzzle-play` S5 — `cue_failed` reads on one line | **pass** | `Failed` at `89×48`. `screenshots/r2-1280x720-failed.png` |
| `PTU-puzzle-play` S5 — `cue_abandon` reads on one line | **pass** | `Abandoned` at `174×48` (C4 Abandon → END.L6). `screenshots/r2-1280x720-abandoned.png` |
| `PTU-puzzle-play` S5 — R2 re-measures after an S13 reflow | **pass** | `PlayerElo` `108×48`, `autowrap=0` after `_style_all()`; the fix survives restyle |
| `PTU-puzzle-play` S5 — no regression to R3 or the board | **pass** | strip `[P: (16, 12), S: 1248×144]`, board `[P: (0, 189), S: 1280×531]`; no overlap |
| `PTU-puzzle-play` S3 / `US5` — leave with confirm returns to mode pick | **pass** | `leave-returned_to_mode_pick=true`; unaffected by this change, judged as context |
| **Protocol** `PTU-puzzle-play`, S5 in scope | **pass** | every in-scope `US2` state judges `pass`; headless agrees |

## Paths

- `notes.md`
- `logs/probe-graphical-1280x720.log` — measurements, telemetry, results
- `probe/zz_accept794_probe.gd` — throwaway acceptance probe (not shipped in `game/`)
- `screenshots/` — 5 frames, one per R2 state, from this build
