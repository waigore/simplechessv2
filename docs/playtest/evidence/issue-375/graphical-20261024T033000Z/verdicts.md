# Verdicts against #375's acceptance criteria — this run

Back to [`notes.md`](notes.md). Only what these two probes observed; anything they could not observe stays `owed`.

| AC | Verdict | Basis |
|----|---------|-------|
| 1. R3 marks + eval only while On, online, values set | not re-judged | Judged by the 2026-10-23 headless run; this run entered play with Advice Off on purpose. |
| 2. C3 toggles `GS.advice` | not re-judged | Headless run; unchanged by this branch. |
| 3. Setup R1 + C4 | not re-judged | Headless run; unchanged by this branch. |
| 4. `PER.R5` ≤ 10% of any body, `PER.R1` silhouette | **pass** | `logs/ink-run.log`: twelve piece types, worst `1.73%` (black King), ten bodies at `0.00%`. `PAL.C7` / `PAL.K5` / `UIS.T2` were pass in the verify and are unchanged. |
| 5. Marks via `CTR-presentation.E4` / `R4` | not re-judged | Both probes went through `BoardPresentation.render_advice`; no `CTR-presentation` operation touched. |
| 6. `EX.error` / S3: names failure, playable, Dismiss → S1, move never waits | **partial** | Panel raises and Dismiss returns S1 — pass. `input_commit` moves land in S3 while offline — pass. Pointer gestures do not move a piece — `fail`, filed on its own defect; the probe cannot separate that from the S3 leg. |
| 7. "Advice ready" medium, move not delayed | not re-judged | Headless run. |
| 8. Every advice string via its Copy key | not re-judged | Headless run. |
| 9. No new sound; not colour alone; 44px; focus order | not re-judged | Headless run and `advice_ui_test.gd`. |
| 10. `shared-play`, `shared-setup`, `exceptions` headless **and graphical** | **partial** | Headless pass (21 suites). Graphical: S3 panel leg passes, S3 pointer-playability leg fails (filed). `shared-play` and `shared-setup` graphical legs stay owed. |
| 11. R3 on the shipped graph against a reachable backend | not re-judged | The 2026-10-23 headless run stands; this run used no backend. |
| 12. `Code lint`, `Unit tests`, `Coverage` | pass | 21 suites, 85.6%, `gdlint` and `gdformat --check` clean, spec lint 0 errors. |

## What running found

1. **S3 panel never showed (fixed here).** The router repainted only when the advice values changed, and entering `EX.error` changes none, so `_shared_play.advice_error` stayed false while `play_ui_state` read `S3`; Dismiss then left the panel up because a dismiss changes no value either. `game/session_router.gd` `_advice_shown` now carries the flag. The headless twin missed it by reading session state instead of the panel.
2. **Pointer press dropped before a frame (filed).** `_on_pointer_down` sets `_press_active` and a frame-boundary reset clears it; `_on_pointer_up` then finds no press and makes no move. A tap whose press and release share a frame — a finger's tap, and this probe's gestures — is lost. `input_commit` bypasses pointer handling, which is why the headless twin passed.
