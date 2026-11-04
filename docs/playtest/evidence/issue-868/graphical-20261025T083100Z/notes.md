# Notes — #868, graphical attempt

## What this run is

Second graphical attempt on #868. The first (`graphical-20261025T011500Z`) could not judge the diff because the
published page served `69a03d4`, before PR #873, and carried no `DBG.3` to reach the last-rank fixture. This one
answers the two things that run said would unblock acceptance: a build at or after `589ed41`, and a playtest preset
that can carry a fixture.

Independence: this session wrote none of #868's code. It read `game/presentation_test.gd` at `ad9c04d` and drove
(or tried to drive) the browser itself.

## Build

`main` at `ad9c04d` (2026-10-25), `Web Playtest` preset, exported locally on a clean `git worktree` because CI keeps
no Web artifact. The commit contains PR #873 (`589ed41`) and the 33-test suite passes on it. The export carries
`main.tscn` (not `main_release.tscn`), so the seams are present.

## Why no reading

Each fixture needs a page that has started. In this session no frame ever showed a started page, so nothing was
judged. The full log of what each attempt returned is in [attempt-log.md](attempt-log.md).

1. **No browser could start at first.** This host has no Chrome on `PATH`; the Playwright bundles fail with
   `libasound.so.2`. Supplying that library from the Ubuntu package made the headless shell start.
2. **Two connections were lost to contention** (load 14–24 on 4 cores, 27 browsers from parallel agents). A probe
   during a quieter window started cleanly and painted the board.
3. **One full pass captured 12 frames, none taken as evidence.** The White leg painted through `white-s4` and
   `white-committed`, but its chooser numbers match `white-ready`, so the walk to the last rank already painted the
   destination as armed and the reading does not separate C6 from an ordinary place.
4. **Every later frame was flat white** while the app kept running (`shared.start`, `shared.resign`, `shared.end`
   in the console), and a released browser was then refused with `Not attached to an active page`.

`readings.json` from that pass was deleted rather than kept: a partial frame set whose own numbers do not support a
verdict is not evidence.

## What is left to do

The reproducer (`serve.mjs`, `drive.mjs`, `read.mjs`) is complete and syntax-checked but has not completed a pass.
Run it as [attempt-log.md](attempt-log.md) describes. A slot is painted when it reads `ink:1/<brightness>`; the S4
chooser shows four painted slots at `dest`, and none after the commit or the deselect tap.

A headless browser that keeps blanking a WebGL canvas is a capture-environment problem. The remaining option is a
human-observed graphical session in a desktop browser; the in-tree unit check is not a substitute, because it
asserts the router and supplies no screenshots.

## Verdict

**Waiting — not accepted, not failed.** #868 stays `status:pending-acceptance`; no defect filed, because nothing
here contradicts the diff and the blocker is the capture environment, not the game.
