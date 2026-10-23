# Manifest

- **Issue**: 545
- **Environment**: graphical (`ENV.2`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf, `origin/main` `16e197b` — the same build id as the headless twin `../headless-20261024T000000Z` (deliverable merged as `5a7541b`, PR #595). Display: macOS windowed Godot, 720×1280 phone-portrait window. Capture session `TEL.3`: `sess-1792774831598-57794-playtest` (see `logs/graphical-probe.log`).
- **Coverage mode**: full, intersected with issue scope: `PTU-shared-play` (UX), S3/S4/S6 and P4/P2. `P2` — both environments pass on this build.
- **Defects**: none — no protocol failed.
- **Screenshots**: present under `screenshots/` (five PNGs, 720×1280), covering every judged state.
- **Log window cited by `SIT.5`**: `sess-1792774831598-57794-playtest`, 5 events.

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTU-shared-play` S6 / P4 — judged stories carry `TEL.*` with their IDs on a rendered run | pass — `verdict=pass`, `matched=3` |
| `PTU-shared-play` F3 — a judged story with no event fails and is named | pass — `verdict=fail`, `US9` in `missing` |
| `PTU-shared-play` P2 — graphical environment passes | pass — `display=macOS`, all five captures rendered |
| `PTU-shared-play` S3/S4 — Advice toggle and resign confirm operate on the rendered UI | pass — screenshots 03 and 04 |
| `PTU-shared-play` S1/S2/S5, P1/P3 | not-judged — outside the change's blast radius |
| **Protocol verdict `PTU-shared-play`** | **pass** (graphical) |

## Paths

- `notes.md`
- `probe/accept545_graphical.gd`
- `logs/graphical-probe.log`
- `screenshots/01-shared-setup-en.png`
- `screenshots/02-shared-play-s1.png`
- `screenshots/03-shared-play-advice.png`
- `screenshots/04-shared-play-resign-confirm.png`
- `screenshots/05-shared-result.png`
