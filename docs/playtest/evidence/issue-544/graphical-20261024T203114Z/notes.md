# Notes — graphical (`ENV.2`), `main.tscn` on `1894f31`

## How the run was driven

A throwaway `SceneTree` probe (`probe/`) boots the real `main.tscn` on a rendered Metal window, drops the `ENV.1` smoke harness (which quits on its first frame), then uses only public entry points: `PlaytestSeams.start_measurement` / `measure` for `O10`, `SessionRouter.handle_control` for navigation (`mode-pick` `C1` → `shared-setup` `C5`), and `handle_input_commit` for the move, with targets from `legal_targets_for` / `can_place`. Nothing writes to the board directly, so `G3` holds.

## What passed

- **`loading_ready` arms and closes on a live open.** Armed at frame 0 on `loading`; the router reached `mode-pick` one frame later; the window closed `ok`, `measure.start` carrying `TEL.1: measure.start`, `TEL.4: PTU-mode-pick`, `TEL.5: pass`.
- **Shared `frame_times` arms and closes on the judged move.** The window held six frames unchanged; the committed `a2a3` flipped `side_to_move` to `black` and the window closed `ok` with `sample_count: 7` and a real `max_ms`. Three runs agree.
- **The disarm returns its report.** `measure("")` on an *open* window gives `cancelled`, keeps 10 samples, claims no `max_ms`, and names the reason.
- **A refused arm names the first failed predicate.** A live puzzle-play with no deal refuses with `detail: "puzzle_id"` rather than arming on placeholders — `D1`'s arm rule working as written.

## What failed

Three findings, each with the report it produced and a refinement direction: [`findings.md`](findings.md).

## Screenshots

This run drove from a `SceneTree` probe, so it recorded reports and logs but no visible frame. A screenshot from a person-visible re-run of the same build is still owed for this leg; its absence is not itself a defect and does not change the verdict above.
