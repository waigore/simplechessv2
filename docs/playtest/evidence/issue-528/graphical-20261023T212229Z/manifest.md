# Evidence manifest — issue #528 (graphical run)

| Field | Value |
|-------|-------|
| Issue | #528 (defect, epic #35 / Wave 2 — Adaptive Puzzle stream) |
| Environment | graphical `ENV.2` — Godot `4.7.2.stable.official.ed1daf0bf`, Metal 4.1, macOS arm64 |
| Build | `origin/main` `614746c` (worktree `1`, branch `main`, no local code changes) — the same build as `../headless-20261023T212229Z/` |
| Coverage mode | `full`, intersected with this defect's playable deliverables: `PTU-puzzle-session` and `PTU-puzzle-play` (UX). Both also ran headless in the twin; no Design protocol needs a graphical run. |
| Peer | `FakeCatalogTransport` (ADR-0013 Testability), as in the headless twin. |
| Screenshots | `screenshots/01-puzzle-play-dealt.png`, `02-puzzle-play-next.png`, `03-puzzle-play-timed.png`, `04-leave-confirm.png`, `05-mode-pick-final.png` |
| Defects | None — no cited story failed. |

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTU-puzzle-session` S1 — mode-pick `C2` opens `puzzle-play` with the dealt record on the board | pass — `screenshots/01-puzzle-play-dealt.png` (opening `e2e4` applied, board presented) |
| `PTU-puzzle-session` S2 — leave → confirm → mode-pick | pass — `screenshots/04-leave-confirm.png` shows the confirm; `ACCEPT leave_confirm stage=mode-pick` |
| `PTU-puzzle-session` S3 — leave → cancel stays on `puzzle-play` with the puzzle open | pass — `ACCEPT leave_cancel stage=puzzle-play puzzle_id=pz-1` |
| `PTU-puzzle-play` S1 — the Solving side moves the required steps on the rendered board | pass — `ACCEPT timed move ['e7','e5'] is a required step` ×4 while `03-puzzle-play-timed.png` is captured |
| `PTU-puzzle-play` S2 — reveal after confirm; failure, then the next deal on screen | pass — `screenshots/02-puzzle-play-next.png` is the next record after the reveal settle |
| `PTU-puzzle-play` S3 — leave confirm / cancel | pass — `04-leave-confirm.png`; the cancel branch from the same run |
| `PTU-puzzle-play` S4 / P3 — a timed move holds 60 fps, no hitch longer than one frame | pass — `ACCEPT timed_move frame_worst_ms=1.9 frame_mean_ms=1.62 handler_worst_ms=3.67 budget_ms=16.67 repeats=3` |
| Mode-pick after leave renders (journey end) | pass — `screenshots/05-mode-pick-final.png` |
| **Protocol verdict `PTU-puzzle-session`** | **pass** (headless + graphical) |
| **Protocol verdict `PTU-puzzle-play`** | **pass** (headless + graphical) |

## Checks run

| Check | Result | Log |
|-------|--------|-----|
| Acceptance drive, graphical (`logs/drive.gd -- --graphical`) | 94 checks pass, `ACCEPT DRIVE PASS`, exit 0 | `logs/drive-graphical.log` |

The headless twin carries the unit tests, coverage, lint, spec lint and smoke logs; this
run judged the rendered half of the UX stories only.

## Capture scope

The screenshots come from a seam build, which mounts `PlaytestSeams`' debug layer
(`ACCEPT capture debug_layer=["PlaytestDebug visible=true"]`): the empty rows above the
board and the grey button stack at the left are that seam, not the shipped screen. G2 keeps
the layer out of `main_release.tscn`. The board, the dealt position, the result cue and the
leave confirm are the shipped presentation.

## Paths

- [`notes.md`](notes.md)
- `logs/drive.gd` — the drive (identical to the headless twin's `logs/drive.gd`)
- `logs/drive-graphical.log`
- `screenshots/`