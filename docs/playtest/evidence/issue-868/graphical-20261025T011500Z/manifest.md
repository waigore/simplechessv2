# Manifest — #868 promotion chooser on the published Web build

- **Issue**: #868 — The S4 promotion chooser is never exercised through the real screen pointer path
- **Environment**: `graphical` (`ENV.2`). Headless Chrome 144 (`--headless=new`, SwiftShader WebGL 2.0), frame 390×844 CSS px, DPR 2 (780×1688 backing buffer), CDP touch emulation.
- **Build under test**: the published client at `https://waigore.github.io/simplechessv2/` (ADR-0009), read on 2026-10-25. It is CI's release export of `main` at `69a03d4`; PR #873 (`589ed41`) merged after that export, so **the published tree predates the diff under acceptance**. The build carries no playtest seams (ADR-0004 `G2`), so there is no `TEL.3` session id.
- **Coverage mode**: `full`, but this is a defect acceptance run, not a coverage sweep. Protocol: `PTU-shared-play` S8 (`US3.3`, `US3.4`).
- **Timing (`SIT.4`)**: not cited by this protocol's S8 leg.

## Results

`not-judged` is not a pass and not a fail; it means this run could not reach the state the row needs.

| Row | Judged step | Outcome |
|---|---|---|
| `UI-shared-play.US3.3` (promotion commit) | S8 — promote with the knight and the queen | **not-judged** — S4 is unreachable: the published build predates PR #873 and has no `DBG.3`; the tap path places nothing and the export exposes no scene handle to push a pointer into |
| `UI-shared-play.US3.4` (promotion unavailable) | S8 — try `C6` where no promotion is open | **not-judged** — same blocker: no session state can be set up to ask it |
| Protocol `PTU-shared-play` (S8 leg) | — | **not-judged** |

Screenshots of the published screen as far as this run drove it are in `screenshots/`; they do not judge the S4 visit
because no shot contains an S4 chooser. Acceptance waits on a graphical run of a build that carries the diff.

## Defects

None filed. The blocker is the build under test, not a game or interface fault observed in the diff.

## Paths

- [notes.md](notes.md) — the build resolution, the two drive routes that failed, and what would unblock
- `readings.json` — tap-pair drive readings (taps, chooser slot colours, commits)
- `screenshots/` — `step-mode-pick.png`, and per-fixture `*-board`, `*-armed`, `*-s4`, `*-committed` (no S4 chooser appears in any of them)
- `exp3/`, `exp3-control/` — tap pair vs drag, published build and a local export of the same commit
- `exp4/` — focus, long-press, and raw-touch probes
- `logs/drive-console.log` — page console (GitHub Pages is serve-only; `TEL.*` comes from the playtest build, ADR-0004)
- `drive.mjs`, `cdp.mjs`, `png.mjs`, `sequences.json` — the reproducer: `node drive.mjs <url> <runDir>`
