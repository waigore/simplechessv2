# AC ledger — issue #375

Back to [`manifest.md`](manifest.md). Judged on `origin/main` `161b4a9`, independently of the implement and verify comments.

| AC | Verdict | Basis |
|----|---------|-------|
| 1 marks + eval only while On, online, values set | pass | `drive-play.log` `marks_appear_after_start from=e2 to=e4 children=11`, `presentation_rendered_eval +0.18`, `move_complete_clears_advice children=0`; `drive-error.log` shows nothing after the failed fetch |
| 2 C3 toggles, Off clears at once, On re-evaluates | pass | `drive-toggle.log`: `advice: false`, `c3_clears_marks_at_once children=0`, `c3_clears_eval_at_once <null>`, `c3_on_re_evaluates from=e2 to=e4` |
| 3 Setup R1 row + C4, default On, not persisted | pass | `drive-play.log` `setup_advice_default_on true`, `setup_c4_off false`, `setup_c4_on true` before C5 |
| 4 `PAL.C7` 2:1, eval ≥ `UIS.T2`, ≤ 10%, `PER.R1` | pass | 2.01:1 on C1 and C2 from the swatches; `style_label` → `BODY_PX`; worst 0.13% with the probe artifact corrected ([`notes.md`](notes.md)); unit bound `_marks_fit_the_body_bound` |
| 5 via `CTR-presentation.E4` / `R4`, no new operation | pass | `presentation.gd` `_show_advice_update` calls only `_board.render_advice()` |
| 6 `EX.error` / S3 names, playable, Dismiss → S1, no wait | pass | `drive-error.log`: `ui_state_s3`, `error_panel`, `local_move_while_s3 side_to_move=black`, `dismiss_returns_s1 visible=false`, `ui_state_s1_after_dismiss S1` |
| 7 "Advice ready" medium, move not delayed | pass | `local_move_not_delayed waited_ms=12`; `feedback.md` row is medium |
| 8 every string through its Copy key | pass | `string_table.gd` holds all five keys in en / zh-Hant / ja |
| 9 no new sound, not colour alone, 44px, focus | pass | no audio call on the advice path; bracket form + arrow (`PAL.K9`); 44px assertion; `_focus_chain` |
| 10 the three protocols, headless and graphical | pass | headless here; graphical S3 legs per the [accepted #753 run](../../issue-753/graphical-20261025T100000Z/manifest.md) — code unchanged in range ([`notes.md`](notes.md)) |
| 11 R3 on the shipped graph, reachable backend | pass | this run: `scene_is_release`, `release_scene_has_no_seams`, `client_is_shipped_transport`, marks and eval arriving and clearing |
| 12 lint / tests / coverage green | pass | 32 suites; 86.7% (80); `gdlint` + `gdformat --check` clean; `spec_lint` 0 errors, 1 pre-existing glossary warning |
