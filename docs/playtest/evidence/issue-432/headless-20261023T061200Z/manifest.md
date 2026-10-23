# Manifest

- **Issue**: 432
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`f943fb3` on `main`; deliverable merged as `95386d5`, PR #489). Probe `TEL.3`: `sess-1792707107657-15095-playtest`.
- **Coverage mode**: full, intersected with issue scope: `PTD-end-conditions` (Design, headless), `PTU-shared-result` (UX, headless + graphical).
- **Screenshots**: waiting on the graphical run of the same build (`../graphical-20261023T061200Z/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| PTD-end-conditions — draw/loss classification (D1–D5, L1–L3) | pass |
| PTD-end-conditions — draw endings play no end cue; L2 keeps `SND.X4` (non-protocol observation) | pass |
| PTU-shared-result S1 — headless | pass |
| PTU-shared-result S1 — graphical | pass (see graphical twin) |
| PTU-shared-result S2/S3 — Play again / Stop | not-judged (outside change scope; unrelated to P1) |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/unit-tests.log`
- `logs/spec-lint.log`
- `logs/accept-probe.log`
