# Manifest — #655 branch re-run, *catalog enabled* answer

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: T9/T10 are unset
- **Environment**: `graphical` — Chrome 156.0.8078.47 headless (CDP), 390×844 CSS px, DPR 2, mobile + touch, WebGL 2.0 (SwiftShader). No seam, no overlay. Probe leg: Godot `4.7.2.stable.official.ed1daf0bf` (`ENV.1` headless).
- **Build / session id**: published release `https://waigore.github.io/simplechessv2/` (`index.pck` `last-modified` 2026-10-24 13:00:58 GMT, 9 561 236 B), published by `Web release` run [40096272525](https://github.com/waigore/simplechessv2/actions/runs/40096272525) on `main` **`a5b35ae`**; the probe leg on a clean `origin/main` worktree at the same commit. The `TEL.3` session id is not emitted to the browser console on this build, so it comes from the headless probe leg (`logs/x655-probe.log`).
- **Repeat count**: 2 cold opens of the published build (deal leg), 1 cold open (leave leg), plus 1 headless probe leg.
- **Coverage mode**: `critical-only`.

## Results

| Row / protocol | Outcome | Evidence |
|---|---|---|
| Reproduction steps re-run on the published build | **observed** | `logs/published-deal-log.txt`, `screenshots/published-1-mode-pick-390x844.png`, `screenshots/published-2-puzzle-play-390x844.png` |
| `PTD-puzzle-stream` K1 — a puzzle is dealt | **fail** | `ERROR: WARNING: puzzle stream: deal read failed (status)`; no catalog/advice HTTP request in `Network.requestWillBeSent` |
| `PTU-puzzle-play` US1 — the board is playable on a dealt puzzle | **fail** | no puzzle open on the entered `S1`; R1 empty, R2 shows Elo only |
| `F-puzzle-catalog.X2` — nothing dealt, `GS.playerElo` unchanged | **holds** (no-deal is not the issue; the *cause* is) | `X655 ENTERED … pid=<> elo=1000.00 last_failure=<status>`; `CANCEL` leg leaves Elo at `1000.00` |
| `FAIL.T14` — failure reason in `PuzzleStream.last_failure` and the run log | **pass** | `last_failure=<status>`; the `deal read failed (status)` line in the run log |
| `UI-puzzle-play.US5.1` / `US5.3` — `C5` on `S1` raises `leave_confirm`, Cancel returns | **pass** (headless leg) | `X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true`, `X655 CANCEL state=S1` |
| `J-puzzle-session` S2 — leave → confirm → `mode-pick` | **pass** (headless leg) | `X655 ROUTER booted=mode-pick entered=puzzle-play C5=S2 after_confirm=mode-pick flow_left=true` |
| `PTU-puzzle-session` S2–S3 | **pass** (headless leg) | same two lines |
| Catalog-enabled branch record (criterion 6) | **fail** | the published build carries no `T9`/`T10`: zero outbound catalog requests |

Unsettled rows: `observations.md`.

Protocol verdicts: `PTD-puzzle-stream` **fail**, `PTU-puzzle-play` **fail**, `PTU-puzzle-session` **pass**.

## Paths

- `logs/published-deal-log.txt` — published cold open: boot, mode pick, Puzzle stream tap, console + network, with timestamps
- `logs/published-leave-log.txt` — published cold open with the leave taps (console verdict lines only)
- `logs/x655-probe.log` — headless probe leg on `a5b35ae` (`C5` / `S1` and router journey)
- `screenshots/published-boot-390x844.png` — published build at boot: mode pick
- `screenshots/published-1-mode-pick-390x844.png` — published build: mode pick before the tap
- `screenshots/published-2-puzzle-play-390x844.png` — published build after the tap: entered stream, `S1` with no puzzle open
- `probe/x655_confirm_probe.gd` — the headless probe (`C5` / `S1` + router journey), run from `game/`
- `probe/drive_published.mjs` — the published-build driver that produced the two logs and three screenshots
- `notes.md` — what was measured and under which answer; `observations.md` — preload observations and the unsettled rows
