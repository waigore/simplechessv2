# Manifest

- **Issue**: 375 — advice UI: shared-play marks and toggle, setup row, S3 error state
- **Environment**: headless (`ENV.1`), Godot 4.7.2.stable.official.ed1daf0bf, macOS, no browser
- **Build / session id**: `origin/main` `d164acb`, shipped as the `Web Release` graph (`main_release.tscn`, `custom_features="release"`, PCK not embedded). `TEL.3` session id: none — the release graph carries no `PlaytestSeams`.
- **Coverage mode**: full, intersected with scope: `PTU-shared-play` (S3 toggle, S4 advice affordances, S5 timed move), `PTU-shared-setup`, `PTU-exceptions`. **Headless half only; the graphical half is owed** ([`verdicts.md`](verdicts.md)).
- **Backend**: reachable advice peer `logs/peer.py`, a scripted CTR-advice-stream stand-in (ADR-0002 Testability). No Stockfish, no UCI. The client uses the shipped `AdviceStreamTransport` because `_advice_sim_factory()` returns `null` without seams. Requests: `logs/peer-normal.jsonl`, `logs/peer-fail.jsonl`.
- **Screenshots**: none — graphical half not run.

## Results

| Step | Result | Evidence |
|------|--------|----------|
| Fresh `--import`, `Web Release` export | pass | `logs/import.log`; `logs/drive-play.log` (`scene_is_release`) |
| `PTU-shared-play` — On: marks + eval on the board | pass | `drive-play.log`: `marks_appear_after_start from=e2 to=e4 children=11`, `presentation_rendered_eval +0.18` |
| `PTU-shared-play` S5 — move never waits on advice | pass | `drive-play.log`: `local_move_not_delayed waited_ms=15` |
| `PTU-shared-play` S3 — C3 Off clears at once, On re-evaluates | pass | `drive-toggle.log`: `c3_clears_marks_at_once`, `c3_on_re_evaluates` |
| R8/R9 — move clears advice, next side re-evaluates | pass | `drive-play.log`: `move_complete_clears_advice`, `black_advice_appears from=e7 to=e5` |
| `PTU-shared-setup` — row default On, C4 Off then On | pass | `drive-play.log`: `setup_advice_default_on`, `setup_c4_off`, `setup_c4_on` |
| `PTU-exceptions` — S3 `EX.error`, playable, Dismiss → S1 | pass | `drive-error.log`: `error_panel "Advice unavailable. Play continues."`, `local_move_while_s3`, `dismiss_returns_s1` |
| `TEL.4`/`TEL.5` — toggle carries its story id | pass (recorder) | `drive-telemetry.log`: `shared.advice / toggled / UI-shared-play.US1.4` |
| Unit tests / Coverage / Code lint / Spec lint | pass | 24 suites; 86.5% (80); `gdlint` + `gdformat` clean; 0 errors |
| Graphical `PTU-shared-play` / `-setup` / `-exceptions` | **not run** | owed — no browser in this session |

## Defects filed

None — no observed criterion failed.

## Paths

- [`notes.md`](notes.md), [`setup.md`](setup.md), [`results.md`](results.md), [`verdicts.md`](verdicts.md), [`verifier.md`](verifier.md)
- `logs/drive.gd`, `logs/peer.py`
- `logs/drive-play.log`, `drive-toggle.log`, `drive-telemetry.log`, `drive-error.log`
- `logs/peer-normal.jsonl`, `peer-fail.jsonl`, `peer-normal.log`, `peer-fail.log`
- `logs/import.log`, `unit-tests.log`, `coverage.log`, `lint.log`, `spec-lint.log`
