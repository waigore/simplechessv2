# Manifest

- **Issue**: 59
- **Environment**: headless
- **Build / session id**: commit `e4d9e94` (PR #350, branch `task/59-shared-result-journey`); Godot 4.7.2. Shared-result test `TEL.3`: `sess-1792615251566-6054-playtest`. Smoke `TEL.3`: `sess-1792615247449-5927-playtest`.
- **Coverage mode**: full (in-scope UX protocols named by #59 AC: PTU-shared-result, PTU-shared-session).
- **Screenshots**: waiting on graphical run of the same build (`../graphical-<run-id>/screenshots/`).

## Results

| Protocol / story | Result |
|------------------|--------|
| Unit tests (`shared_result_test` + suite) | pass (13) |
| Coverage | pass 88.6% (≥80) |
| Import | pass |
| Headless smoke | pass |
| PTU-shared-result (Play again / Stop) | pass (`shared_result_test`) |
| PTU-shared-session (S1–S4, B1–B2) | pass (`shared_result_test`) |
| EX.interrupt reopen | pass (`shared_result_test`) |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log`
- `logs/gdscript-coverage.log`
- `logs/shared-result-test.log`
- `logs/headless-smoke.log`
- Screenshots: waiting on `../graphical-<run-id>/screenshots/` (same build as this headless judgement)
