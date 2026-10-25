# Manifest

- **Issue**: 333 — Build the puzzle play screen, mode-pick entry, and stream journey
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, Web export
  (`Web Playtest`), headless Chrome + SwiftShader (WebGL 2), 1280×720 CSS at DPR 1, so CSS
  pixels are canvas pixels. Browser: Chrome headless, `--use-angle=swiftshader`.
- **Build**: `origin/main` `8e7237d`. This branch adds evidence only — no `game/`,
  `specs/` or catalog change.
- **Why**: the 2026-10-24 verification failed `PTU-controls` / `PTU-exceptions` on the S2
  leave prompt being tiled by the board and its buttons reading 1.00:1
  (`graphical-20261025-recheck`). This run measures the shipped prompt's painted rect
  through the real control path. Method and limits: `notes.md`.
- **Coverage mode**: partial — the S2 prompt fill only.
- **Deal source**: the seams peer deals no record in this build, so only C5 Leave raises a
  prompt here; Reveal and Abandon stay disabled without an open attempt.
- **Timing (`SIT.4`)**: not sampled.

## Results

| Step | Outcome | Notes |
|------|---------|-------|
| `C2` → puzzle-play | **pass** | `01-mode-pick.png`, `02-puzzle-play-s1.png` |
| `C5` → prompt, frame after tap | **pass** | panel body `#F7F1E8`, no board band. `03-s2-leave-immediate.png` |
| Same prompt settled | **pass** | 34 157 of 39 200 px panel fill; copy 6.39:1 (`PAL.K4` ≥ 4.5). `03-s2-leave-settled.png` |
| Raised twice more in one session | **pass** | 34 449 / 34 157 px; no first/later asymmetry. `03b-*`, `03c-*` |
| Cancel → S1, stream open (B1) | **pass** | `03-after-cancel.png`, `03b-*`, `03c-*` |
| Confirm → mode-pick (`NAV.T9`) | **pass** | `06-mode-pick.png` |

## The verification claim, measured

| Measure | 2026-10-24 verification | This run (`8e7237d`) |
|---------|-------------------------|----------------------|
| Prompt body | split into board-square bands | `#F7F1E8`, no band on rows 240/262/306/345 |
| Board paint in the rect | tiled per square | 1 257 px of 39 200 (3.21 %) — rounded-corner AA, same in every leg |
| Copy contrast | 1.00:1 | 6.39:1 |

`02-puzzle-play-s1.png` reads `#E8D5B5` / `#8B5A3C` across the full 500–780 span at those
rows, so the board colours are present to be found whenever the prompt does not cover them.

## Left for the sweep

The play legs (`PTU-puzzle-play` S1–S8, `SIT.4`), the S2 Reveal/Abandon copy legs,
`PTU-puzzle-session` deal/advance and AC13's headless leg are not re-taken; their last
verdicts stand and land in #400's sweep.

## Paths

`notes.md`, `logs/probe333-console.log`, `screenshots/` (15), `readings.json`,
`probe/` (throwaway harness).
