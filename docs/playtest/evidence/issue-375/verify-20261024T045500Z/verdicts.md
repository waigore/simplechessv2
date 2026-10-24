# Verdicts against #375's acceptance criteria

Back to [`notes.md`](notes.md). Only what the verifier observed on `ea37581`, plus the implementor's repo-locatable evidence where this run did not re-measure.

| AC | Verdict | Basis |
|----|---------|-------|
| 1. R3 marks + eval only while On, online, values set | pass | 2026-10-23 headless shipped-path run (`headless-20261023T190212Z/`): On shows `e2e4` +0.18, Off clears same frame, nothing after a completed move or on a failed fetch. Unchanged by #752. |
| 2. C3 toggles `GS.advice`; Off clears at once; On re-evaluates | pass | Same headless run + `advice_ui_test.gd` `_toggle_clears_at_once` in this branch's 28-suite run. |
| 3. Setup R1 row + C4 On / Off; default On, not persisted | pass | Same headless run (`setup_advice_default_on`) + `_setup_row_c4`. |
| 4. `PAL.C7` ≥ 2:1, eval ≥ `UIS.T2`, ≤ 10% of any body, silhouette kept | **pass** | 2026-10-24 verify measured 58.6%; `graphical-20261024T033000Z/logs/ink-run.log` re-measures 1.73% worst (black King), 0.00% for ten bodies, brackets outside every half-width. `_marks_fit_the_body_bound` green in this run's suite. |
| 5. Marks via `CTR-presentation.E4` / `CMP-presentation.R4`, no new operation | pass | `BoardPresentation.render_advice()` from `_show_advice_update`; no `CTR-presentation` operation touched by #752. |
| 6. Failed fetch → `EX.error` / S3: names the failure, playable, Dismiss → S1, move never waits | **pass** | This run: S3 with the panel up, session parked offline, `gestures_available` true, `can_place` true, `handle_input_commit("g1","f3")` lands → black; a real pointer tap pair also lands the move (`logs/gesture-run.log`). Dismiss → S1 is `graphical-20261024T033000Z/logs/gesture-run.log` (`dismiss_returns_s1`, `panel_hidden_after_dismiss`). The 2026-10-24 refusal does not reproduce. |
| 7. "Advice ready" medium, move not delayed | pass | 2026-10-23 headless (`waited_ms=15`), unchanged by #752. |
| 8. Every advice string via its Copy key | pass | 2026-10-23 headless; `advice_ui_test.gd` key-equality, green on this branch. |
| 9. No new sound; not colour alone; 44px; focus order | pass | No cue added; arrow carries direction; `MIN_TOUCH` assertions green; focus chain unchanged. |
| 10. `shared-play`, `shared-setup`, `exceptions` headless and graphical | **pass** | Headless: 28 suites on this branch. Graphical: S3 panel, playability and pointer leg pass here; `panel_hidden_after_dismiss`, `dismiss_returns_s1`, setup/play entry and C4/C5 in `graphical-20261024T033000Z`. (The implementor recorded this AC as `partial` only because it read the pointer leg through #753; see [`notes.md`](notes.md).) |
| 11. R3 on the shipped graph against a reachable backend, under this folder | pass | `headless-20261023T190212Z/` (shipped transport, reachable peer, request log). #534 is `accepted`. |
| 12. `Code lint`, `Unit tests`, `Coverage` green | pass | PR #752 checks green; verifier re-ran `Unit tests` on `ea37581` → 28 suites pass. |

## What running found

1. **#753 does not reach the S3 leg it was used for.** #753's own reproduction is a press and release with no frame between them, plus the gate `_reset_gesture()`. In the implementor's gesture log the refused gestures each wait a frame between events, so a press dropped by `_reset_gesture()` there points at more than the sub-frame race its description claims. On this branch the same shape of tap pair one frame apart moves a piece in S3 (`logs/gesture-run.log`, `selected_after_tap=g1`, side → black). Whether this run's shape differs (`_accept_pointer` with recorded drags) or #752's repaint change removed the trigger, the refusal is not reproducible here, so AC6's playability leg passes and #753 stays a real sub-frame defect on its own terms.
2. **Nothing else moved.** The ink bound and the panel fix both hold on the shipped graph.

## Residual risk

- `PER.R1` under a rendered capture is bounded by the arrow's `1.73%` and the brackets' 0.00%; not re-photographed here.
- This run's probes are new code; they live in `logs/` next to their runs.
