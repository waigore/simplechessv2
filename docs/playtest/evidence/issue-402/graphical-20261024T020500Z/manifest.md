# Manifest — #402 quality-row re-record on the shipped release build

- **Issue**: #402 — verify every `quality.md` row on the shipped release build
- **Environment**: `graphical` — Chrome headless (SwiftShader WebGL), 390×844 CSS px, DPR 2, touch
- **Build / session id**: two readings, never merged — [builds.md](builds.md)
  - **Published** — `https://waigore.github.io/simplechessv2/`, `dd15479`, run **`40049651531`**
  - **Fallback** — `Web Release` export of `bccdb1c` at `build/web/`; used only because that commit is unpublished
- **Timing (`SIT.4`)**: macOS arm64, headless Chrome. Published: 4 cold opens; fallback: 1
- **Coverage mode**: `critical-only` — stops at the first blocking failure
- **Screen reached**: none — both render `Loading…` throughout

## Results

Each row names the build it read; Load time is split into its two targets.

| `quality.md` row | Method (`How checked`) | Build read | Verdict |
|---|---|---|---|
| Performance | `SIT.4` frame time during a move | published `dd15479` | not-judged — no move reachable |
| Load time — board playable ≤ 3 s | timed cold open to first legal move | published `dd15479` | **fail** — `Loading…` at 25 s; 4/4 |
| Load time — advice ready ≤ 2000 ms | timed advice readiness while moving | published `dd15479` | not-judged — seat #559 |
| Reliability — sitting | sitting soak | published `dd15479` | not-judged — seat #558 |
| Reliability — reopen at mode pick | fault mid-session, reopen | published `dd15479` | not-judged — seat #557 |
| Observability | protocol run; story IDs, outcomes, errors | none — playtest build only | not-judged — out of envelope; silence specified |
| Save durability | quit/reload after a result; failed write | published `dd15479` | not-judged — seat #557 |
| Accessibility — shape / no color-only | `PER.R1`, `PAL.K1`, `PAL.K2` | published `dd15479` | not-judged — seats #640 / #641 |
| Accessibility — smallest text | `SIT.6` phone-width read | published `dd15479` | not-judged — seat #546 |
| Localization — three locales | locale switch, four screens | published `dd15479` | not-judged — seat #643 |
| Load time — board playable (control) | timed cold open | **fallback** `bccdb1c` | **fail** — #647 E4 line, `Loading…` at 25 s |
| All other rows (control) | as above | **fallback** `bccdb1c` | not-judged — never a published reading |

**Totals, published: 0 `pass`, 1 `fail`, 9 `not-judged`.** Observability moved `fail` → `not-judged` under #729 ([notes.md](notes.md)).

## Paths

- [builds.md](builds.md) — commits, sources, attribution, environment, repeat count
- [readings.md](readings.md) — timelines, `SIT.4` numbers, what they do not prove
- `logs/`, `screenshots/`, `capture_release.js` — captures and the reproducer
- [notes.md](notes.md) — judgement text, defect decisions, re-record rules

## Defects

- **#630** — shipped release never leaves `EX.loading`; cited for Load time — board playable and the eight `not-judged` rows. Not re-filed.
- **#729** — the Observability row was read here against the wrong build; it judges the playtest-certified build, and release silence is specified. Corrected by #729. Sub-issue of #37.
