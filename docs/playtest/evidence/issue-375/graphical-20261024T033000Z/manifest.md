# Manifest

- **Issue**: 375 — advice UI: shared-play marks and toggle, setup row, S3 error state
- **Environment**: graphical (`ENV.2`), Godot 4.7.2.stable.official.ed1daf0bf, Linux x86_64, Xvfb 1280×720 window, `gl_compatibility` (llvmpipe). No browser: the run drives the shipped release scene graph in the desktop window, not the exported Web build.
- **Build / session id**: `fix/375-advice-ink-and-s3-play` off `origin/main` `abc6469`. Shipped graph: `main_release.tscn` (no `PlaytestSeams`, so `AdviceStreamTransport` is the only advice path). `TEL.3` session id: none — the release graph carries no telemetry seam.
- **Coverage mode**: full, intersected with scope: `PTU-shared-play` (S3 toggle, S4 advice affordances), `PTU-shared-setup`, `PTU-exceptions` (`EX.error` / S3). **This run judges the two legs the 2026-10-24 verify failed — AC4 `PER.R5` ink and AC6/AC10 `EX.error` playability — and does not re-judge AC11** (the headless shipped-path run at `headless-20261023T190212Z/` (on `main`; absent from this branch) stands).
- **Backend**: none. The S3 leg points T9 at `http://127.0.0.1:1/advice`, a port nobody listens on, so the shipped transport fails on its own the way a stopped backend fails. No Stockfish, no UCI, no simulated peer.
- **Screenshots**: `screenshots/s3-error.png`, `screenshots/s3-played.png`, `screenshots/after-dismiss.png`.

## Results

| Step | Result | Evidence |
|------|--------|----------|
| AC4 `PER.R5` — marks and arrow cover ≤ 10% of any body | pass | `logs/ink-run.log`: twelve pieces, worst `1.73%` (black King), 0 for the ten narrower bodies |
| AC4 brackets outside every silhouette | pass | unit `advice_ui_test.gd` `_marks_fit_the_body_bound`: bracket inner edge `0.343 > 0.20` (knight half-width) |
| AC6/AC10 S3 raises after the fetch fails; board playable; Dismiss → S1 | pass | `logs/gesture-run.log`: `advice_error_raised`, `service_parked_offline`, `client_parked`, `ui_state_s3`, `ex_error_panel_up`, `dismiss_returns_s1`, `panel_hidden_after_dismiss` |
| AC6 local move never waits on the error path | pass (`input_commit`), **not judged by pointer gestures** | `advice_ui_test.gd` `_error_s3_dismiss` moves `d7d5` and `e4e5` after the park with `still offline` asserted; the graphical pointer legs are `fail` below |
| Graphical pointer moves in S3 | **fail** | `logs/gesture-run.log`: `pointer_move_g1f3_in_s3`, `pointer_move_g8f6_in_s3`, `tap_move_e2e4_in_s3`, `pointer_move_d7d5_after_dismiss` all `ok: false`, side unchanged; `dismiss_returns_s1` reads `S4` |
| Unit tests / Coverage / Code lint / Spec lint | pass | 21 suites; 85.6% (threshold 80); `gdlint` clean, `gdformat --check` clean; spec lint 0 errors, 1 pre-existing glossary warning |

## Defects filed

- **No protocol is marked `fail` by this run** other than the pointer-gesture leg below, which is the S3 playability leg of `PTU-exceptions`. Its owner is filed on its own `type:defect` and its number is recorded on this line once filed.
- **Filed**: pointer gestures (tap and drag) refused in Shared play on the shipped graph — press and release inside one frame lose the press (`_on_pointer_down` / `_presentation.can_process()` reset). Found by `logs/gesture-run.log`; stands in for #375's `EX.error` gesture-playability leg until fixed.
- **Fixed in this branch, not a filed defect**: `EX.error` / S3 panel never rendered — the router re-rendered only on an advice-value change, so entering or leaving S3 never repainted (`game/session_router.gd` `_advice_shown`).

## Paths

- [`notes.md`](notes.md), [`verdicts.md`](verdicts.md), [`setup.md`](setup.md)
- `logs/ink_probe.gd` (AC4 frame capture), `logs/ink-run.log`
- `logs/gesture_probe.gd` (S3 pointer gestures), `logs/gesture-run.log`
- `screenshots/*.png`
