# ADR-0001, ADR-0002, ADR-0003 — quoted Methods and evidence

Methods are quoted from the ADRs on `main`. `#402` rows are named by their `quality.md` row.
Citation source: #402's re-read on this **same** build,
`docs/playtest/evidence/issue-402/graphical-20261025T031500Z/manifest.md` (commit `161b4a9`) —
2 `pass`, 1 `fail`, 7 `not-judged` there. Where it judged a row, the verdict and reason are
inherited; where it did not, the row stays `not-judged` rather than being re-timed into a `pass`.

## ADR-0001 (`specs/adr/decisions/0001-godot-engine.md:75-79`)

| Check | Method (quoted) | Result | Evidence |
|---|---|---|---|
| Move hitch ≤1 frame | `quality.md frame-time` | **not-judged** | #402 **Performance**: *idle and move windows equally slow on SwiftShader (p50 50–66.7 ms both)*. Own reading agrees: idle p50 33.3 ms, move 33.2 ms — a hitch cannot be isolated on a host that never reaches 16.7 ms frames |
| Cold open ≤3 s | `quality.md timed open` | **fail** | #402 **Load time — board playable ≤ 3 s**: *first paint 5.5–6.1 s, FCP 8.2–8.7 s, 3/3*. Own readback: 3039–4394 ms, 4/4. Defect **#856** |
| Sitting without forced exit | `quality.md sitting soak` | **not-judged** | #402 **Reliability — sitting**: *seat #558*; the soak was not run |
| Piece shape and color-blind readability | `quality.md readability checks` | **not-judged** | **#640**/**#641** returned no verdict; #402 **Accessibility — shape / no colour-only** is `not-judged` behind them |
| Locale spot-check | `quality.md locale spot-check` | **not-judged** | **#643** returned no verdict; #402 **Localization — three locales** is `not-judged` — locale control focused without activating (#833) |
