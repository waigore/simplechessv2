# Results

Assertion lines from `logs/`. Back to [`notes.md`](notes.md).

## `play` — `logs/drive-play.log` (peer `normal`)

| Assertion | Observed |
|-----------|----------|
| `scene_is_release` / `release_scene_has_no_seams` | `res://main_release.tscn` / true |
| `client_is_shipped_transport` | true — `sim_factory == null`, so `AdviceStreamTransport` is the only path |
| `setup_advice_default_on`, `setup_c4_off`, `setup_c4_on` | `true`, `false`, `true` |
| `marks_appear_after_start` | `from=e2 to=e4 children=11` (brackets + arrow) |
| `advice_best_move_dict` / `advice_eval_int` | `{ "from": "e2", "to": "e4" }` / `18` |
| `presentation_rendered_eval` | `+0.18` — the `AdviceEval` label, visible |
| `local_move_applied` / `local_move_not_delayed` | `side_to_move=black` / `waited_ms=15` |
| `move_complete_clears_advice` | `from= to= children=0`, field no longer a Dictionary |
| `black_advice_appears` | `from=e7 to=e5 children=11` |

Peer (`logs/peer-normal.jsonl`): four O1 requests, each `time_ms` 2000, keyed by position — `w` start, `b` after `e2e4`, and the two toggle restarts. Black's request appears **after** the commit, which is the "never waits" ordering.

## `toggle` — `logs/drive-toggle.log` (peer `normal`)

Marks + eval while On (`from=e2 to=e4 children=11`, `+0.18`), then:

| Assertion | Observed |
|-----------|----------|
| `c3_sets_advice_off` | `advice: false` |
| `c3_clears_marks_at_once` | `from= to= children=0` — same frame |
| `c3_clears_eval_at_once` | `<null>` |
| `c3_on_re_evaluates` | `from=e2 to=e4 children=11` |

## `telemetry` — `logs/drive-telemetry.log` (peer `fail`)

```
{"event":"shared.advice","outcome":"toggled","story":"UI-shared-play.US1.4"}  ×2
```

Two C3 presses, two events, each with `TEL.4` and `TEL.5`. Read through a recorder where the seam would be — the release graph has none ([`notes.md`](notes.md)).

## `error` — `logs/drive-error.log` (peer `fail`: 500 + `{"reason":"error"}`)

| Assertion | Observed |
|-----------|----------|
| `advice_error_raised` / `ui_state_s3` | `true` / `S3` |
| `board_still_renders` / `local_move_while_s3` | true / `side_to_move=black` |
| `error_dialog_visible` | `true` |
| `error_panel` | `{"texts": ["Advice unavailable. Play continues."], "visible": true}` — the `advice_error` Copy key's `en` value |
| `dismiss_control_present` | `AdviceErrorDismiss` is a `Button` |
| `dismiss_clears_error` / `dismiss_returns_s1` / `ui_state_s1_after_dismiss` | `false` / panel hidden / `S1` |

Peer (`logs/peer-fail.jsonl`): one O1 request, no retry — `FAIL.T1` parks the client, so S3 is not followed by a request storm.

## Gate checks

Unit tests 24 suites pass; coverage 86.5% (4383/5068, threshold 80); `gdlint` + `gdformat` clean; spec lint 0 errors, 1 pre-existing warning.

## Not run

A graphical run of the three UX protocols. No browser or display here, so no screenshots and no pixel-level judgement — see [`verdicts.md`](verdicts.md).
