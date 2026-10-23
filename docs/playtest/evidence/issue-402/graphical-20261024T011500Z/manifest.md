# Manifest — #402 quality-row sweep, shipped release build

- **Issue**: #402 — Verify every `quality.md` row on the shipped release build
- **Environment**: `graphical` — Chrome 155 headless via `puppeteer-core`, 390×844 CSS px, DPR 2, WebGL 2.0; no seam, no playtest build
- **Build**: published release `https://waigore.github.io/simplechessv2/`, commit `98d3473c5edf686ac35d5e65d47aaa57c9d0d7fe`, `Web release` run `39991174434`. Control: `Web Release` export of the same commit served from `build/web/`. No `TEL.3` session id — the release export emits no telemetry
- **Coverage mode**: `critical-only` — the sweep stopped at the first blocking failure
- **Repeat count**: 4 cold opens of the published URL, 1 local export; identical result

## Results

| `quality.md` row | Method (`How checked`) | Verdict |
|---|---|---|
| Performance | `SIT.4` frame time during a move | not-judged — no move reachable; build stalls on `EX.loading` |
| Load time — board playable ≤ 3 s | timed cold open to first legal move | **fail** — board never playable (25 s, no mode pick) |
| Load time — advice ready ≤ 2000 ms | timed advice readiness while moving | not-judged — Advice Off, no board |
| Reliability — 15–40 min sitting | sitting soak | not-judged — no screen reachable |
| Reliability — reopen at mode pick | fault mid-session, reopen | not-judged — no puzzle result committable |
| Observability | protocol run, story IDs in logs | **fail** — release export emits no `TEL.*` lines |
| Save durability | quit/reload after a puzzle result; forced failed write | not-judged — no commit path |
| Accessibility — shape / no color-only | `PER.R1`, `PAL.K1` `PAL.K2` review | not-judged on this build — no piece rendered |
| Accessibility — smallest text | `SIT.6` phone-width read | not-judged — only `Loading…` renders |
| Localization — three locales | locale switch, four screens | not-judged — no screen past loading |

The two failing rows and all eight `not-judged` rows share one cause: the build never leaves the
loading screen. See [`notes.md`](notes.md).

## Paths

- `logs/release-cold-open.log` — published build, cold open, 25 s wait
- `logs/local-release-export.log` — same commit exported locally, served from `build/web/`
- `logs/local-release-asset-requests.log` — HTTP access log: no asset request
- `logs/preset-attempts.log` — every `export_presets.cfg` route tried to pack the asset root
- `screenshots/release-cold-open-390x844.png` — published build after 25 s: `Loading…`

## Defects

- #630 — `game_assets/` missing from the Web export: the release build never leaves `EX.loading`
