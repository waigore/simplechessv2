# Setup and drive

Build `d164acb`, environment `ENV.1`. Back to [`notes.md`](notes.md).

## Prep

- Fresh worktree on `origin/main`; `godot --headless --path game --import --quit` → exit 0 (`logs/import.log`)
- `python3 .github/scripts/web_export.py --preset "Web Release"` → exit 0. It asserts `custom_features="release"` and a non-embedded PCK, exports with `main_scene` set to `main_release.tscn`, then restores `project.godot` (worktree came out clean).
- `GODOT_BIN=/opt/homebrew/bin/godot python3 .github/scripts/gdscript_tests.py test` → 24 suites pass
- `… gdscript_tests.py coverage` → 86.5% (threshold 80), gdtoolkit 4.5.0
- `gdlint game`, `gdformat --check game`, `python3 .github/scripts/spec_lint.py` → clean (1 pre-existing glossary warning)
- Peer: `python3 logs/peer.py --port 18495 --mode normal --log …` and a second on `18496 --mode fail`

## Why headless against the release scene

AC11 wants the result on the shipped release graph against a reachable backend. The graph matters because `main_release.tscn` has no `PlaytestSeams`, so `_advice_sim_factory()` returns `null` and `AdviceStreamTransport` — the real HTTP/NDJSON transport on `HTTPClient` + `Thread` — is the only advice path. The drive asserts that twice (`scene_is_release`, `release_scene_has_no_seams`).

Headless because no browser or display is reachable here. The transport is identical in a headless build, so display behavior is real; the pixels are not, and AC4 plus AC9's visual legs are marked owed rather than passed.

## Drive design

`logs/drive.gd` is a `SceneTree` script, not a unit test — it does not import `game/advice_ui_test.gd`.

1. Instantiates `res://main_release.tscn`.
2. Sets `SessionRouter.advice_endpoint` / `advice_api_key` (T9/T10, [`configuration.md`](../../../../../specs/technical/configuration.md) `B3`) to the reachable peer; the export itself ships them empty as the Pages deploy does.
3. Drives real presentation controls: `mode-pick C1` → `shared-setup C4` ×2 → `C5` → `shared-play C3` → `input_commit(e2,e4)`.
4. Reads **rendered** state (`AdviceMarks.last_from`, the `AdviceEval` label text, the `AdviceError` box and its label) and cross-checks `play_state()`.

| Phase | Peer | Drives |
|-------|------|--------|
| `play` | normal | marks + eval; move not delayed; move clears; Black re-evaluates |
| `toggle` | normal | On; C3 Off clears; C3 On re-evaluates |
| `telemetry` | fail | two C3 presses with a recorder where the seam would be |
| `error` | fail | S3 `EX.error`, playable board, Dismiss → S1 |

Each prints `R375 {json}` lines plus a `{"summary": {"checks","failed"}}` line.

## Teardown note

The shipped transport's worker `Thread` is released only once `AdviceClient` sees `is_finished()`, so a run that ends mid-stream can fault on exit while the engine tears the thread down. The drive's `_reset()` joins that worker inside the harness (`Thread.wait_to_finish()` on the main thread, then drops the reference). Nothing in `game/` changed for this run; the build is `origin/main` byte-for-byte.
