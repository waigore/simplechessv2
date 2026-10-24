# Manifest

- **Issue**: 427 — `demos/shared-game` playtest polish (piece size, select SFX, coords, wood bevel)
- **Run kind**: acceptance testing (`accept-project-issue`), unattended `issue-workflow-accept-agent`, parallel id 1
- **Build / session id**: Godot 4.7.2 stable `4.7.2.stable.official.ed1daf0bf` (`logs/build-id.txt`)
- **Tree under test**: `origin/main` `705f0d1`; `git diff --name-only origin/main -- demos/shared-game` is empty, so the demo bytes are `main`'s (`logs/build-context.txt`)
- **Environments**: Headless autodrive, plus a Graphical autodrive of the same build (`--rendering-driver opengl3`, macOS 27.0.1 arm64)
- **Screenshots**: `screenshots/demo-shared-game-exercise.png`, `screenshots/demo-shared-game-mate.png` — written by the Graphical run itself (`DEMO_SHOT_DIR`)

This run produced its own evidence. It did not reuse
`issue-427/headless-20261023T013500Z/`, which records the earlier `#513` build and predates the
`#569` / `#642` coordinate work.

## Results

| Check | Result | Measurement |
|-------|--------|-------------|
| Autodrive, headless (whole scenario set) | pass | `logs/autodrive-headless.log`: every command completed as scripted, `[demo] PASS`, exit 0 |
| Autodrive, graphical | pass | `logs/autodrive-graphical-try2.log`: `[demo] PASS`, exit 0, two screenshots written |
| Item 1 — piece size | pass | Body extents per type, in square units: K 0.40×0.85, Q 0.40×0.79, B 0.39×0.76, N 0.48×0.75, R 0.40×0.68, P 0.38×0.62. Every height equals its `FRM.P2` value and sits inside the `SPC.E1` 0.85 box. Visible in `screenshots/demo-shared-game-exercise.png`. |
| Item 3 — coordinates | pass | `UIS.T2` face 16.0 px at the 640 px reference frame (18.0 screen px), line box 23.0 px inside a 32.0 px band (`PER.R7`). Rendered-pixel probe: left band 322 px, bottom band 324 px of ink (floor 202), **inside the 8×8 0 px, off-band 0 px**. Ink is `PAL.C9` on the `PAL.C1` inlay; in the frames each letter sits under its own file and each numeral beside its own rank. |
| Item 4 — wooden bevel | pass | Board bevel 630 px wide at x 25..702 in the 720×1280 frame, lip 47 px, band 36 px (`PRJ.P1`). The frames show a lit top/left lip, a shadowed bottom/right lip, a raised frame with a darker outline, and the carved bottom-right corner. |
| End panel | pass | `[P: (41.0, 582.5), S: (638.0, 185.0)]` inside the frame, margins 230/160, `z 10` above every board layer |
| Item 2 — select cue | not a gap here | Owned by defect #570; the issue body states item 2 is owned by #570 and items 1/3/4 are the landed items. Not judged in this run. |

## Interpretation

The probe is non-vacuous: it requires at least 202 ink px per band, counts 0 px inside the 8×8 and 0 px
off-band, and the same probe failed on the pre-`#642` 6.5 px face. Screenshots come from the graphical
run of the same build as the headless run.

## Paths

- `manifests` — `manifest.md`, `notes.md`
- `logs` — `logs/build-id.txt`, `logs/build-context.txt`, `logs/autodrive-headless.log`, `logs/autodrive-graphical-try2.log`
- `screenshots` — `screenshots/demo-shared-game-exercise.png`, `screenshots/demo-shared-game-mate.png`
