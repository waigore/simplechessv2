# Manifest

- **Issue**: 511
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf (`e022f83` on `main`; deliverable merged as `f44b535`, PR #519; prerequisite #483 merged as `289bce8`, PR #530). Probe `TEL.3`: `sess-1792740438…-playtest` (see `logs/playtest-headless.log`).
- **Coverage mode**: full, intersected with issue scope: `PTU-localization` (UX, headless + graphical). The defect's playable surface is the four marked piece-name rows and the `mode-pick.locale` own name, so the protocol's S1/S2 and P1–P5 steps are in scope; the five-screen copy listing (S3) is judged for the marked rows only.
- **Screenshots**: waiting on the graphical run of the same build (`../graphical-20261023T073634Z/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTU-localization` S1/P1 (headless) — first `C4` activation reads 繁體中文, copy is `zh-Hant`, screen stays S1 | pass |
| `PTU-localization` S1/P2 (headless) — `title`, `shared`, `puzzle` differ across `en`, `zh-Hant`, `ja` | pass |
| `PTU-localization` S1/P4 (headless) — `locale` row reads the live locale's own name | pass |
| `PTU-localization` S2/P3 (headless) | not-judged — protocol makes this row graphical only |
| `PTU-localization` S2/P3 (graphical) | pass — see graphical twin |
| `PTU-localization` P5 for the listed strings (headless) — every listed string is a Copy-table row value, no clipped label | pass |
| Marked-row parity gate (issue AC1, AC4, AC5) — `shared-play` × 4 piece rows equal `en` in `zh-Hant`/`ja`, negative case bites | pass — `logs/unit-tests.log`, `logs/gate-negative-cases.log`, `logs/marked-rows-values.log` |
| Marked set is a constant cross-checked against `L3` (AC2) | pass — `logs/spec-cross-check.log`, `logs/gate-negative-cases.log` (neg4 names `shared-play.bishop`) |
| `mode-pick.locale` carve-out is own-name identity, never `en` equality (AC3) | pass — `logs/marked-rows-values.log`, `logs/gate-negative-cases.log` (neg3) |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/unit-tests.log`
- `logs/playtest-headless.log`
- `logs/headless-smoke.log`
- `logs/spec-lint.log`
- `logs/spec-cross-check.log`
- `logs/marked-rows-values.log`
- `logs/gate-negative-cases.log`
