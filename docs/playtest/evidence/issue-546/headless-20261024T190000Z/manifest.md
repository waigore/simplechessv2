# Manifest

- **Issue**: 546 — implement `SIT.6` phone-width legibility viewport (seam `S13`, op `O12`)
- **Environment**: headless (`ENV.1`) — the unit-test binary plus a headless smoke of the playtest build
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf`. Branch `task/546-sit6-residual` off `main` `101c216`. Session `TEL.3` `sess-*‑playtest` (see `logs/headless-smoke.log`).
- **Coverage mode**: partial — `S13` seam scope only. The protocol-level `PTU-mode-pick` S6 judgement at 390×844 is an `ENV.2` step and belongs to the #400 sweep; this run checks the seam and the presentation ratio it reports.
- **Screenshots**: waiting on an `ENV.2` run; a headless runner applies no viewport, so there is nothing to capture here.

## Results

| Check | Result |
|-------|--------|
| `S13` — `O12` applies 390×844 on `ENV.2` (`applied`, applied size) | pass — by construction, `logs/unit-tests.log` asserts the same expression the seam uses |
| `S13` — a runner that refuses the resize touches nothing and claims no frame height | pass — `logs/unit-tests.log` |
| `S13` — report shape: requested size, applied text scale, `frame_height_px`, `body_text_px`, `last_viewport_report`, `viewport_changed` | pass — `logs/unit-tests.log` |
| `S13` — body text is the presentation ratio for the reported frame (`UIS.T2`), never clamped at `BODY_PX` | pass — 21 px at 640+ vs 16 px at the reference; `logs/unit-tests.log` |
| `S13` — a bound presentation's own size is echoed and its frame named | pass — `logs/unit-tests.log` |
| `S13` — invalid input returns no report; `SetViewport` control present on the debug panel | pass — `logs/unit-tests.log` |
| `I3` — release has no `O12`: empty report, no stored report | pass — `logs/unit-tests.log` |
| Unit tests | pass — 24 tests, `logs/unit-tests.log` |
| Coverage | pass — 86.4%, `logs/coverage.log` |
| Spec lint | pass — 0 errors, 1 pre-existing glossary warning, no `specs/` file touched, `logs/spec-lint.log` |
| Format / lint | pass — `logs/gdformat-check.log`, `logs/gdlint.log` |
| Headless smoke (`ENV.1`) | pass — no errors, 4 `TEL.1` events, `logs/headless-smoke.log` |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/unit-tests.log`
- `logs/coverage.log`
- `logs/spec-lint.log`
- `logs/gdformat-check.log`, `logs/gdlint.log`
- `logs/headless-smoke.log`

## Defects

None filed. One spec question is recorded in `notes.md` (`I6` asks for `ENV.1`/`ENV.2` parity of `S11`–`S13`; a headless runner cannot apply a viewport by definition). It needs an upstream decision, not a code fix, so it is not filed here.
