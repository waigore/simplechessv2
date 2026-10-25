# Manifest — #868 chooser on a real screen, from a `Web Playtest` export

- **Issue**: #868 — The S4 promotion chooser is never exercised through the real screen pointer path
- **Environment**: `graphical` (`ENV.2`) attempted; **no frame was captured in this session**. Headless `chrome-headless-shell` (browser `f842f52…`), phone frame 390×844 CSS, DPR 2, CDP touch emulation — the frame parameters of the previous run.
- **Build under test**: a `Web Playtest` export (ADR-0007) of `main` at `ad9c04d`, the commit the `Web playtest` job built green on 2026-10-25T07:53Z. CI keeps no Web artifact (none on any recent run), so the export was built locally on a clean `git worktree` of that commit. The published page (ADR-0009) serves `69a03d4`, before PR #873; it cannot judge this diff.
- **Why `Web Playtest`**: S4's graphical leg needs the last-rank fixture, and the standard opening does not hold one. Only the playtest preset carries `DBG.3` (jump) and `TEL.*`; the fixture is still played out legally with taps, so the drive stays player-facing.
- **Coverage mode**: `full`, narrowed to the defect. Protocol leg: `PTU-shared-play` S8 (`US3.3`, `US3.4`).
- **Timing (`SIT.4`)**: not cited by the S8 leg.

## Results

No reading was taken, so nothing is judged. `not-judged` never counts as a pass.

| Row | Judged step | Outcome |
|---|---|---|
| `UI-shared-play.US3.3` (promotion commit) | S8 — promote with the knight and the queen | **not-judged** — no frame was captured in this session (see `notes.md`, "Why no reading") |
| `UI-shared-play.US3.4` (promotion unavailable) | S8 — try `C6` where no promotion is open | **not-judged** — same reason |
| Protocol `PTU-shared-play` (S8 leg) | — | **not-judged** |

No screenshot of the diff exists from this session, so acceptance still waits. Nothing was observed that fails the diff, so no defect is filed and no status moved.

## Reproducer

| File | What it does |
|---|---|
| `serve.mjs` | Serves `<export>/build/web` and `docs/playtest/evidence` on `127.0.0.1` (COOP/COEP set), so the page and the readback module share an origin. |
| `cdp.mjs` | Dependency-free CDP driver: one browser, two start attempts, a Chrome log on failure. |
| `drive.mjs` | The run: mode pick → Shared game → Start; the stored legal tap sequence; S4 via a real tap; chooser read; painted sprite tap; deselect leg; C6 where nothing is pending. |
| `sequences.json` | The legal tap sequences, unchanged from `graphical-20261025T011500Z`. |
| `read.mjs` | Offline readback of the captured frames into a slot/origin/destination table. |

## Paths

- [notes.md](notes.md) — what was tried and the verdict
- [attempt-log.md](attempt-log.md) — each attempt in order, the console read, and how to run the reproducer
- No `screenshots/` and no `logs/`: this session produced none. They are waiting on a run that gets past the browser start.
