# Manifest

- **Issue**: 60
- **Environment**: headless
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`0a14c88` — PRs #356 / #359). Audio test `TEL.3`: `sess-1792618553820-68329-playtest`. Smoke `TEL.3`: `sess-1792618554162-68333-playtest`. Shared-play `TEL.3`: `sess-1792618554417-68335-playtest`.
- **Coverage mode**: full (in-scope protocols named by #60 AC: `PTD-shared-game`, `PTU-mode-pick`, `PTU-shared-play`, `PTU-shared-result`; audio cues / Ambient bed).
- **Screenshots**: waiting on graphical run of the same build (`../graphical-20261021T213200Z/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| SND.X1–X4 event mapping; X5 silent; draws no end cue | pass |
| Ambient only after board playable; M1→M2→M1; stays for sitting | pass |
| Cold-open / pre-playable mode-pick silent | pass |
| Sound-off path; no mute control | pass |
| Cue/bed IDs via `CTR-presentation` O3; ACC.G2 / ACC.G3 | pass |
| No audio I/O blocks local move (`CTR-presentation` G1) | pass |
| PTD-shared-game (session + audio integration spine) | pass |
| PTU-mode-pick / PTU-shared-play / PTU-shared-result (headless) | pass |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/presentation-audio-test.log`
- `logs/shared-play-test.log`
- `logs/headless-smoke.log`
