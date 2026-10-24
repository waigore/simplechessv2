# Manifest

- **Issue**: 483
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf`. Deliverable PR [#631](https://github.com/waigore/simplechessv2/pull/631) at head `fa23a7d`, merged for the run with `main` `63f744c`. Session `TEL.3` `sess-1792778566323-90770-playtest` (see `logs/playtest-headless.log`).
- **Coverage mode**: full, intersected with issue scope: `PTU-localization` (UX, headless + graphical). The change is code and schema wording inside the string-table completeness gate, so the protocol's copy steps are in scope; the graphical twin supplies the screenshots.
- **Screenshots**: waiting on nothing — the graphical twin `../graphical-20261023T175813Z/screenshots/` carries the mode-pick and promotion-chooser captures of the same build.

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTU-localization` S1/P1 (headless) — first `C4` activation reads 繁體中文, copy is `zh-Hant`, screen stays `mode-pick` | pass |
| `PTU-localization` S1/P2 (headless) — `title`, `shared`, `puzzle` differ across `en`, `zh-Hant`, `ja` | pass |
| `PTU-localization` S1/P4 (headless) — `locale` row reads the live locale's own name, never `English` | pass |
| `PTU-localization` P5 (headless) — rendered mode-pick strings are their Copy-table values, not raw keys | pass |
| `PTU-localization` F1 — no `FAIL.T13` locale miss logged | pass |
| `PTU-localization` S3/P5 (graphical) — promotion-chooser `queen` row reads `Queen` in all three locales | pass — see graphical twin |
| Gate: derived owner set vs shipped owners, dropped-owner negative case (AC5) | pass — `logs/unit-tests.log`, `logs/gate-negative-cases.log` |
| Gate: `exceptions` shipped-subset reading unchanged (AC5) | pass — `logs/unit-tests.log` |
| Schema words and lint (AC8, AC9) | pass — `logs/spec-lint.log` |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/unit-tests.log`
- `logs/coverage.log`
- `logs/spec-lint.log`
- `logs/spec-cross-check.log`
- `logs/gate-negative-cases.log`
- `logs/gdformat-check.log`, `logs/gdlint.log`
- `logs/playtest-headless.log`
- `logs/headless-smoke.log`

## Defects

None filed.
