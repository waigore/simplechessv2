# Manifest

- **Issue**: 794 — Puzzle-play R2 Elo and result cue wrap to one letter per line
- **Environment**: headless (`ENV.1`) — Godot `4.7.2.stable.official.ed1daf0bf, no display,
  shipped playtest scene `game/main.tscn`, frame 1280×720.
- **Build / session id**: `origin/main` at `017a763` (the squash of PR #802). `TEL.3` session
  `sess-1792863153235-30015-playtest-194167` (`logs/probe-headless-1280x720.log`).
- **Timing (`SIT.4`)**: not judged here; #794 is a layout defect.
- **Coverage mode**: partial — one defect, one row (`UI-puzzle-play` S5 / `US2`).
- **Deal source**: `DBG.3` — dealt records injected into the live session, as
  `game/puzzle_play_test.gd` does. Entry is the real `C2` control from mode pick.
- **Harness note**: the probe frees `PlaytestHarness` before adding the scene, as
  `game/puzzle_play_test.gd` does, because `PlaytestHarness._ready()` quits the tree on a
  headless playtest boot (`SEQ-playtest-headless-smoke`). It also skips `frame_post_draw`
  capture, which never fires without a renderer.
- **Screenshots**: **waiting on the graphical run of this same build** —
  [`../graphical-20261024T224500Z/screenshots/`](../graphical-20261024T224500Z/screenshots/).

## Results

| Story / step | Outcome | Notes |
|--------------|---------|-------|
| `PTU-puzzle-play` S5 — `GS.playerElo` reads on one line (`US2`) | **pass** | `Elo 1000` `127×48`, `autowrap=0`, text needs 127.0 px |
| `PTU-puzzle-play` S5 — `cue_solved` on one line | **pass** | `Solved` `99×48` |
| `PTU-puzzle-play` S5 — `cue_wrong` on one line | **pass** | `Wrong move` `192×48` |
| `PTU-puzzle-play` S5 — `cue_failed` on one line | **pass** | `Failed` `89×48` |
| `PTU-puzzle-play` S5 — `cue_abandon` on one line | **pass** | `Abandoned` `174×48` |
| `PTU-puzzle-play` S5 — R2 re-measures after an S13 reflow | **pass** | `PlayerElo` `108×48` after `_style_all()` |
| **Protocol** `PTU-puzzle-play`, S5 in scope | **pass** | every in-scope `US2` state judges `pass`; matches the graphical run state for state |

## Paths

- Screenshots: waiting — `../graphical-20261024T224500Z/screenshots/` (same build, 5 frames)
- `logs/probe-headless-1280x720.log`
- `probe/zz_accept794_probe.gd`
