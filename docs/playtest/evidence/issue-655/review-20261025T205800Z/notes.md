# Notes — #655 verification pass, `906b8b3`, unattended, parallel id 1

Independent verification. I wrote none of the implementation comments or code on this issue.

## What the implement pass got right, and I confirm by measurement

- **Criterion 1** holds twice over: `specs/technical/configuration.md:43` (`B5`) and `specs/technical/components/catalog-service.md:56`, landed by `a9192a0` and `a94210d`, both ancestors of `906b8b3`.
- **Criterion 4** holds as an observable: `GS.playerElo` `1000.00` before and after, no puzzle id, `PuzzleStream.last_failure` = `<status>`, and `puzzle stream: deal read failed (status)` twice in the run stdout. `specs/` requires no player-facing absence copy, and none is invented.
- **Criterion 5** holds, re-measured: `C5` raises `leave_confirm` on `S1` with no puzzle open, Cancel returns to `S1`, and the router journey returns to mode pick. The gate that makes it possible is `puzzle_session.gd:538` (`needs_puzzle = false` for `C5`). Item 4's repair clause therefore does not fire.
- **Criteria 7, 8, 9** hold; the deliverable (#841 → `906b8b3`) is merged and checkable.
- **Unit suite 32/32** headless, import exit 0 on my own runs.

## What has not moved

Criteria **2, 3 and 6** are the defect's symptom and measure exactly as they did on `ce8a156`, `5c15e80`, `6a969ee` and `8af7f8f`:

- `game/session_router.gd:33-34` is still `advice_endpoint := ""` / `advice_api_key := ""`, and the only assignments anywhere in `game/` remain the test seam `advice_ui_test.gd:40-41`.
- The probe refuses inside `B5`'s empty-value guard (`puzzle_stream.gd:97 refused`, called from `puzzle_stream.gd:47 request`) and the stream lands in `S1` with nothing dealt.
- The published `index.pck` is unchanged (`etag "6adcf171-91ff1c"`, 17:57:05Z, 9568028 bytes), predating both `specs/` landings and #479's `f07eed6`.

## The **held** clause is spent, and this pass confirms it rather than inherits it

Criterion 6 permits **held** only *"while #648's `specs/` sentence and #479's delivery decision are unlanded"*. Both have landed:

- #648 — `a94210d` (`catalog-service.md` `R9`/`:56`) and `a9192a0` (`configuration.md` `B5`).
- #479 — PR #806 merged as **`f07eed6`** (2026-10-24T19:59:17Z): client-side delivery of the endpoint and key is the deploy path, outside `specs/`, and no mechanism is named there.

So the published leg is judged, and it fails: the release is in exactly the state `B5` calls *"a deployment fault, not accepted"*.

## What this verification cannot close

Moving criteria 2, 3 or 6 needs a **published client carrying a real `T9`/`T10` pair**. After `f07eed6` that is the deploy path, and the deploy path has no owner in the graph:

- `specs/` deliberately names no delivery mechanism.
- `game/session_router.gd:33-34` is the shipped default and must stay empty in the source tree (`T10`: never committed).
- Only a deploy step that fills the values into a published bundle can move them.

That is a planner decision — file the deploy-path task, or supersede this defect into it — not a code change an implement dispatch can make. A further implement dispatch before one happens will measure the same two legs again, as the last four did.

## Harness notes

- The probe was run **unchanged**, copied to `game/` for the run and removed afterwards, so the tree measured is `906b8b3` plus nothing.
- The suite runner needs `GODOT_BIN` on macOS (`gdscript_tests.py` only auto-downloads a Linux binary); it was set to the local `godot` `4.7.2`.
- Coverage is **not measured**: `gdtoolkit==4.5.0` is absent in this container, as on every earlier pass on this issue. Logged, not claimed.
- The published build was **not driven** this pass; its identity is a read. The drive that established the client-side `B5` refusal is `review-20261025T022500Z`, on this same artefact.
