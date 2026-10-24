# Manifest — issue #375, acceptance run (headless)

- **Issue**: 375 — advice UI: shared-play marks and toggle, setup row, the S3 error state
- **Environment**: `ENV.1` headless for the shipped-path drive and the unit/lint gates. The rendered `PER.R5` / `PER.R1` measurement ran in a graphical session (`ENV.2`, Metal, `Apple M5`) and its log is kept here; the S3 graphical protocol legs are the accepted [#753 graphical run](../../issue-753/graphical-20261025T100000Z/manifest.md) on `4e50418`, an ancestor of this run's build.
- **Build / session id**: `origin/main` `161b4a9`, clean detached worktree, `Web Release` export (`main_release.tscn`, `custom_features="release"`, PCK not embedded) via `.github/scripts/web_export.py --preset "Web Release"` → exit 0 (`logs/export.log`). Godot 4.7.2.stable.official.ed1daf0bf. `TEL.3` session id: none — the release graph carries no `PlaytestSeams`. Headless smoke `sess-1792879251727-52214-playtest-199415` (`logs/smoke.log`).
- **Timing (`SIT.4`)**: not cited — this issue sets no frame-time row. `PTU-shared-play` S5's "move not delayed" is judged as `waited_ms=12` on one move, which is the criterion, not a timing sample.
- **Coverage mode**: `full`, intersected with scope: `PTU-shared-play`, `PTU-shared-setup`, `PTU-exceptions`.
- **Backend**: reachable advice peer `logs/peer.py` (scripted CTR-advice-stream stand-in, ADR-0002 Testability). `normal` answers a best move and an eval; `fail` answers HTTP 500. No Stockfish, no UCI, no in-process simulated peer.
- **Screenshots**: waiting — this run produced none. The rows it judges are the shipped-path behavior rows; the rendered leg it re-measured is recorded as pixels in `logs/ink-run.log`, and the S3 GUI state is shown in the accepted #753 run's `screenshots/02-s3-exerror-panel.png`.

## Story rows

| Story row | Outcome | Basis |
|-----------|---------|-------|
| `UI-shared-play.US1` (play/chrome) | pass | `logs/drive-play.log`, `logs/drive-toggle.log` |
| `UI-shared-play.US2` (advice marks) | pass | `logs/drive-play.log` marks + eval; `logs/ink-run.log` coverage |
| `UI-shared-play.US3` (advice-error dismiss) | pass | `logs/drive-error.log` `dismiss_returns_s1`, `ui_state_s1_after_dismiss` |
| `UI-shared-play.US4` (unavailable controls) | pass | `logs/drive-toggle.log` C3 availability; `game/advice_ui_test.gd` |
| `UI-shared-setup` R1 (Advice row, C4) | pass | `logs/drive-play.log` `setup_advice_default_on`, `setup_c4_off`, `setup_c4_on` |
| `EX.US1` (`EX.error` / S3, play continues) | pass | `logs/drive-error.log` |
| `ACT-bottom-player.US1`, `ACT-top-player.US1` | pass | `logs/drive-play.log` `local_move_applied`, `black_advice_appears` |

## Protocol verdicts

| Protocol | Verdict | Basis |
|----------|---------|-------|
| `PTU-shared-play` | pass (headless) | `logs/drive-play.log`, `logs/drive-toggle.log`, `logs/drive-telemetry.log` |
| `PTU-shared-setup` | pass (headless) | `logs/drive-play.log` |
| `PTU-exceptions` | pass (headless) | `logs/drive-error.log` |

## Defects

None.

## Paths

- [`notes.md`](notes.md), [`ledger.md`](ledger.md) (AC-by-AC)
- `logs/drive.gd`, `logs/peer.py`, `logs/ink_probe.gd`
- `logs/drive-play.log`, `drive-toggle.log`, `drive-telemetry.log`, `drive-error.log`, `ink-run.log`
- `logs/unit-tests.log`, `coverage.log`, `lint.log`, `spec-lint.log`, `export.log`, `smoke.log`
