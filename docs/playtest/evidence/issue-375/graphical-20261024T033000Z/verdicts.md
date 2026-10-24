# Verdicts against #375's acceptance criteria — this run

Back to [`notes.md`](notes.md). Only what these two probes observed; anything they could not observe stays `owed`, and anything they observed failing stays `fail`.

| AC | Verdict | Basis |
|----|---------|-------|
| 1. R3 marks + eval only while On, online, values set | not re-judged | Behaviour was judged by [`../../headless-20261023T190212Z/`](../../headless-20261023T190212Z/verdicts.md); this run entered play with Advice Off deliberately (see [`setup.md`](setup.md)). |
| 2. C3 toggles `GS.advice` | not re-judged | Headless run; unchanged by this branch. |
| 3. Setup R1 + C4 | not re-judged | Headless run; unchanged by this branch. |
| 4. `PER.R5` ≤ 10% of any body, `PER.R1` silhouette | **pass** | `logs/ink-run.log`: every piece type on e4 with the advice arrow to e2, ink against that piece's opaque body in the rendered frame. Worst `black king 1.73%`, `white king 1.66%`, `queen ≈ 0.9%`, everything else `0.00%`. `PAL.C7`, `PAL.K5`, `UIS.T2` were already pass in the verify fail and are unchanged. |
| 5. Marks via `CTR-presentation.E4` / `R4` | not re-judged | Went through `BoardPresentation.render_advice` in both probes; no `CTR-presentation` operation touched. |
| 6. `EX.error` / S3: names failure, board playable, Dismiss → S1, move never waits | **partial — pass on `input_commit`, fail on pointer gestures** | Panel raises and Dismiss returns S1 (pass). `input_commit` moves land in S3 while offline (`advice_ui_test.gd`, pass). Real pointer gestures do **not** move a piece in S3 on the shipped graph (`pointer_move_g1f3_in_s3`, `pointer_move_g8f6_in_s3`, `tap_move_e2e4_in_s3` all refused) — filed on its own defect; this probe's own gesture driver cannot separate that from the S3 leg until it is fixed. |
| 7. "Advice ready" medium, move not delayed | not re-judged | Headless run. |
| 8. Every advice string via its Copy key | not re-judged | Headless run. |
| 9. No new sound; not colour alone; 44px; focus order | not re-judged | Headless run and `advice_ui_test.gd`. |
| 10. `shared-play`, `shared-setup`, `exceptions` pass headless **and graphical** | **partial** | Headless: pass (`advice_ui_test.gd`, 21 suites). Graphical: the S3 panel leg passes, the S3 pointer-playability leg fails (filed). `shared-play` and `shared-setup` graphical legs are owed exactly as in the headless run's verdict. |
| 11. R3 on the shipped release graph against a reachable backend | not re-judged | [`../../headless-20261023T190212Z/`](../../headless-20261023T190212Z/manifest.md) stands; this run did not talk to a backend. |
| 12. `Code lint`, `Unit tests`, `Coverage` | pass | 21 suites, 85.6% (threshold 80), `gdlint` and `gdformat --check` clean, spec lint 0 errors. |

## What changed in the behaviour under test

Two defects were found by running, not by reading:

1. **S3 panel never showed (fixed here).** The router re-rendered the play screen only when the advice *values* changed, and entering `EX.error` changes no value, so `_shared_play.advice_error` was never set and the panel stayed hidden while `play_ui_state` read `S3`. Dismiss then left the panel up because a dismiss changes no advice value either. Fixed in `game/session_router.gd` (`_advice_shown` now includes the error flag). `logs/gesture-run.log` shows `ex_error_panel_up`, `dismiss_returns_s1`, `panel_hidden_after_dismiss` turning green; the headless run had passed this leg only because it polled the state directly.
2. **Pointer press dropped before a frame (filed).** `_on_pointer_down` sets `_press_active = true` and a deferred frame-boundary reset clears it; `_on_pointer_up` reads `_press_active` and does nothing once it has been cleared. A tap or drag whose press and release both arrive inside one frame — a finger's tap, or any driven gesture — therefore reaches the release with the press already gone and no move is made. `_drag` in this probe hits that window, which is why its moves are refused; `input_commit` bypasses pointer handling, which is why the headless twin passed.
