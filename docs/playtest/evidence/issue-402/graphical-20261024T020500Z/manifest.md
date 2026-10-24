# Manifest — #402 quality-row re-record on the shipped release build

- **Issue**: #402 — Verify every `quality.md` row on the shipped release build
- **Environment**: `graphical` — Chrome headless (SwiftShader WebGL), 390×844 CSS px, DPR 2, touch; no seam
- **Build / session id**: two readings, never converted into one another — [builds.md](builds.md)
  - **Published** — `https://waigore.github.io/simplechessv2/`, `dd15479`, run **`40049651531`**
  - **Fallback** — `Web Release` export of `bccdb1c` at `build/web/`; used only because that commit is unpublished
- **Timing (`SIT.4`)**: macOS arm64, headless Chrome. Published: 4 cold opens; fallback: 1
- **Coverage mode**: `critical-only` — stops at the first blocking failure
- **Screen reached**: none — both builds render `Loading…` for the full window

## Results

Each row names the build it read. Load time is split into its two targets, judged separately.

| `quality.md` row | Method (`How checked`) | Build read | Verdict |
|---|---|---|---|
| Performance | `SIT.4` frame time during a move | published `dd15479` | not-judged — no move reachable |
| Load time — board playable ≤ 3 s | timed cold open to first legal move | published `dd15479` | **fail** — `Loading…` at 25 s; 4/4 |
| Load time — advice ready ≤ 2000 ms | timed advice readiness while moving | published `dd15479` | not-judged — seat #559 |
| Reliability — sitting | sitting soak | published `dd15479` | not-judged — seat #558 |
| Reliability — reopen at mode pick | fault mid-session, reopen | published `dd15479` | not-judged — seat #557 |
| Observability | protocol run; story IDs, outcomes, errors | published `dd15479` | **fail** — #729; zero `TEL.*` |
| Save durability | quit/reload after a result; failed write | published `dd15479` | not-judged — seat #557 |
| Accessibility — shape / no color-only | `PER.R1`, `PAL.K1`, `PAL.K2` | published `dd15479` | not-judged — seats #640 / #641 |
| Accessibility — smallest text | `SIT.6` phone-width read | published `dd15479` | not-judged — seat #546 |
| Localization — three locales | locale switch, four screens | published `dd15479` | not-judged — seat #643 |
| Load time — board playable (control) | timed cold open | **fallback** `bccdb1c` | **fail** — #647 E4 line, `Loading…` at 25 s |
| All other rows (control) | as above | **fallback** `bccdb1c` | not-judged — never a published reading |

**Totals, published: 0 `pass`, 2 `fail`, 8 `not-judged`.** Every `not-judged` row names its blocker; none is recorded as a pass.

## Paths

- [builds.md](builds.md) — commits, sources, attribution, environment, repeat count
- [readings.md](readings.md) — timelines, `SIT.4` numbers, what they do not prove
- `logs/`, `screenshots/`, `capture_release.js` — captures and the reproducer
- [notes.md](notes.md) — judgement text, defect decisions, re-record rules

## Defects

- **#630** — shipped release never leaves `EX.loading`; cited for Load time — board playable and the eight `not-judged` rows. Not re-filed.
- **#729** — release export emits no `TEL.*`; the Observability row fails. Sub-issue of #37. Filed by this run.
