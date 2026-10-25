# Manifest

- **Issue**: 768 — Promote puzzle-stream keep list into main code
- **Environment**: `ENV.1` headless and `ENV.2` graphical. Godot
  `4.7.2.stable.official.ed1daf0bf`; graphical leg on macOS arm64 (Apple M5), Metal
  Compatibility renderer, native window 1280×720. Both legs run the shipped scene
  `game/main.tscn` from the same build.
- **Build / session id**: `origin/main` `c4202bb`. Headless `TEL.3`
  `sess-1792888538783-39186-playtest-787279` (`logs/headless-run.log`); graphical
  `TEL.3` `sess-1792888543128-39292-playtest-587977` (`logs/graphical-run.log`). Each
  leg exits 0 with `FAILURES=[]`, 70 checks passing.
- **Coverage mode**: partial — this task's two protocols only (`PTD-puzzle-stream`,
  `PTD-difficulty`). Every other Design protocol is `not-judged` here.
- **Deal source** and **probe seam**: see `setup.md`.
- **Screenshots**: `screenshots/`, from the graphical leg of this build. See
  `notes.md` for the two cue shots whose pixels do not show the transient R2 cue.

## Results

Both protocols are **`pass`** — `PTD-puzzle-stream` (S1–S10, no F1–F4) and
`PTD-difficulty` (S1–S3, no F1). Per-step rows: `results.md`.

## Defects

- None. No protocol failed; no `type:defect` filed.

## Paths

- `setup.md` — deal source and probe seam
- `results.md` — per-step outcomes
- `notes.md`
- `logs/headless-run.log`, `logs/headless-repeat-run-{1,2,3}.log`, `logs/graphical-run.log`
- `screenshots/` (10)
- `probe/` — throwaway harness: `accept768_work.gd`, `accept768_catalog_peer.gd`,
  `session-router-install-seam.diff`
