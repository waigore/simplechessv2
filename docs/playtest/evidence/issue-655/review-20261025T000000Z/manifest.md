# Manifest — #655 branch re-run, *catalog enabled* answer (2026-10-25 pass)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: T9/T10 are unset
- **Disposition**: none claimed here; [`notes.md`](notes.md) carries the proposal.
- **Environment**: `graphical` — Chrome headless (CDP), 390×844 CSS px, DPR 2, mobile + touch, WebGL 2.0 (SwiftShader), no seam, no overlay. Probe leg: Godot `4.7.2.stable.official.ed1daf0bf` (`ENV.1` headless).
- **Build / session id**: published release `https://waigore.github.io/simplechessv2/` (`index.pck` `last-modified` 2026-10-24 13:00:58 GMT — unchanged since #782, so still CI run [40096272525](https://github.com/waigore/simplechessv2/actions/runs/40096272525) on `main` `a5b35ae`). Probe leg on a clean worktree of `origin/main` **`8cdfd45`**; `TEL.3` `sess-1792857688733-89849-playtest-364251`.
- **Repeat count**: 1 published cold open (deal leg), 1 headless probe leg, 1 headless smoke.
- **Coverage mode**: `critical-only`.

## Results

| Row / protocol | Outcome | Evidence |
|---|---|---|
| Reproduction steps on the published build | **observed** | `logs/published-deal-log.txt`, `screenshots/published-1-mode-pick-390x844.png`, `screenshots/published-2-puzzle-play-390x844.png` |
| Criterion 2 — deal path reaches the resolver (no `B5` empty-value refusal) | **fail** | probe `X655 B5 endpoint=<> key_set=false is_available=false`; `game/session_router.gd:33-34` still `""` |
| Criterion 3 — one named outcome (`K1` dealt **or** `F-puzzle-catalog.X2` absence) | **fail** | `S1`, `has_puzzle=false`, `pid=<>`, `elo=1000.00`, `last_failure=<status>` — neither branch is committed |
| Criterion 4 — absence recorded as `FAIL.T14` | **holds as an observable** | `last_failure=<status>` plus the `deal read failed (status)` line in both the published log and the probe stdout |
| Criterion 5 — `C5` → `EX.confirm` → Cancel on the entered `S1` | **pass** | `X655 C5_ACTIVATED … confirm_kind=<leave_confirm>`, `X655 CANCEL state=S1`, `X655 ROUTER … after_confirm=mode-pick flow_left=true` |
| Criterion 6 — published rows, or held under the sequencing note | **fails, not held** | rows above are the published build's; they fail for the empty-value guard, not because #648/#479 blocked the measurement |
| Criterion 7 — `#550` manifest rows | **unchanged** — sweep has not re-run; `Defects` line still names #655 | — |
| Criterion 8 — no `specs/`/asset change; `game/` only under item 4 | **holds** — only this folder is added | — |
| Criterion 9 — #332 / #333 / #335 relationship | **holds** — no native edge added or implied | — |
| Headless smoke (`godot --headless --path game --quit-after 600`) | **pass**, `mode-pick` reached | `logs/headless-smoke.log` |

Protocol verdicts on this build: `PTD-puzzle-stream` **fail** (K1), `PTU-puzzle-play` **fail** (US1), `PTU-puzzle-session` **pass** (S2–S3).

## Paths

- `logs/published-deal-log.txt` — published cold open through the refusal: bundle fetches, mode pick, Puzzle stream tap, console and network
- `logs/x655-probe.log` — the headless probe's verdict lines; `logs/x655-probe-stdout.log` — the same run's telemetry (`TEL.1`–`TEL.5`)
- `logs/headless-smoke.log`, `logs/import.log` — environment checks on the `8cdfd45` worktree
- `screenshots/published-1-mode-pick-390x844.png`, `screenshots/published-2-puzzle-play-390x844.png`
- `probe/drive_published.mjs` — unchanged driver from `review-20261024T131647Z`
- `probe/x655_confirm_probe.gd` — unchanged probe from `review-20261024T131647Z`
- `notes.md` — what this run settles and what it does not; `disposition.md` — the proposal for the planner
