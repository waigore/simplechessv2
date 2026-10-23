# Manifest — #402 quality-row sweep, shipped release build

- **Issue**: #402 — Verify every `quality.md` row on the shipped release build
- **Environment**: `graphical` (Chrome 155 headless driven by `puppeteer-core`, 390×844 CSS px,
  DPR 2, WebGL 2.0) — `ENV.2`-class browser viewport; no seam, no playtest build
- **Build / session id**: published release `https://waigore.github.io/simplechessv2/`,
  commit `98d3473c5edf686ac35d5e65d47aaa57c9d0d7fe`, published by `Web release` run `39991174434`.
  Local control: `Web Release` export of the same commit served from `build/web/`.
  `TEL.3` session id: none — telemetry does not exist in the release export (see Observability row)
- **Coverage mode**: `critical-only` — only the cold-open path, because that is all the shipped
  build can reach (the sweep stopped at the first blocking failure)
- **Repeat count**: 4 cold opens of the published URL, 1 of the local export; identical result

## Results

| `quality.md` row | Method (`How checked`) | Verdict |
|---|---|---|
| Performance | `SIT.4` frame-time capture during a move | not-judged — no move is reachable; the build stalls on `EX.loading` |
| Load time — board playable ≤ 3 s | timed cold open to first legal move | **fail** — board never becomes playable (25 s observed, no mode pick) |
| Load time — advice ready ≤ 2000 ms | timed advice readiness while moving | not-judged — Advice is Off in the shipped build and no board is reachable |
| Reliability — 15–40 min sitting | continuous sitting soak | not-judged — no screen is reachable to soak |
| Reliability — reopen at mode pick with committed Player Elo + Last mode | fault mid-session, reopen | not-judged — no puzzle result can be committed |
| Observability | run a protocol, read story IDs in logs | **fail** — the release export emits no `TEL.*` story-ID lines at all; only engine/`ERROR:` lines are in `logs/release-cold-open.log` |
| Save durability | quit/reload after a puzzle result; forced failed write | not-judged — no commit path reachable |
| Accessibility — shape alone / no color-only | `PER.R1`, `PAL.K1` `PAL.K2` review | not-judged on this build — no piece is rendered; the review method is outside playtest |
| Accessibility — text legible at smallest size | `SIT.6` phone-width read | not-judged — the only text on the shipped build is the `Loading…` label |
| Localization — `en`/`zh-Hant`/`ja` complete | switch locale, spot-check four screens | not-judged — no screen past loading, no locale switch |

**Blocking defect: #TBD** — the shipped release never leaves the loading screen because
`game_assets/` is not in the Web export. Every `not-judged` row above is unobservable for that
one reason, not for ten independent reasons; #402's record cites this defect once and names the
rows it blocks.

## Paths

- `logs/release-cold-open.log` — console capture of the published build, cold open, 25 s wait
- `logs/local-release-export.log` — same commit exported locally with `Web Release`, served from `build/web/`
- `logs/local-release-asset-requests.log` — HTTP access log for that local export (shows no asset request)
- `logs/preset-attempts.log` — every `export_presets.cfg` route tried to pack the asset root
- `screenshots/release-cold-open-390x844.png` — the published build after 25 s: `Loading…`
- `notes.md` — judgement, method, and what would unblock each row

## Defects

- #TBD — `game_assets/` missing from the Web export: the release build never leaves `EX.loading`
