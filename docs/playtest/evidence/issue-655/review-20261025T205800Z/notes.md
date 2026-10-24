# Notes — #655 verification on `906b8b3`

Independent verification. I wrote none of the implementation comments or code on this issue. Scope ID: unattended pass, parallel id 1.

## What the implement pass got right, and I confirm by measurement

- **Criterion 1** holds twice over: `specs/technical/configuration.md:43` (`B5`) and `specs/technical/components/catalog-service.md:56`, landed by `a9192a0` and `a94210d`, both ancestors of `906b8b3`.
- **Criterion 4** holds as an observable: `GS.playerElo` `1000.00` before and after, no puzzle id, `PuzzleStream.last_failure` = `<status>`, and `puzzle stream: deal read failed (status)` twice in the run stdout. `specs/` requires no player-facing absence copy, and none is invented.
- **Criterion 5** holds, re-measured: `C5` raises `leave_confirm` on `S1` with no puzzle open, Cancel returns to `S1`, and the router journey returns to mode pick. The gate that makes it possible is `puzzle_session.gd:538` (`needs_puzzle = false` for `C5`). Item 4's repair clause therefore does not fire.
- **Criteria 7, 8, 9** hold; the deliverable (#841 → `906b8b3`) is merged and checkable. Rows in [`criteria.md`](criteria.md).
- **Unit suite 32/32** headless, import exit 0.

## What has not moved

Criteria **2, 3 and 6** — the defect's symptom — measure as on `ce8a156` … `8af7f8f`:

- `game/session_router.gd:33-34` is still `advice_endpoint := ""` / `advice_api_key := ""`, and the only assignments anywhere in `game/` remain the test seam `advice_ui_test.gd:40-41`.
- The probe refuses inside `B5`'s empty-value guard (`puzzle_stream.gd:97 refused`, from `puzzle_stream.gd:47`) and the stream lands in `S1` empty.
- The published `index.pck` is unchanged (`etag "6adcf171-91ff1c"`, 9568028 bytes), predating both `specs/` landings and #479's `f07eed6`.

## The **held** clause is spent — confirmed, not inherited

Criterion 6 permits **held** only while #648's `specs/` sentence and #479's delivery decision are unlanded. Both landed:

- #648 — `a94210d` (`catalog-service.md` `R9`/`:56`) and `a9192a0` (`configuration.md` `B5`).
- #479 — PR #806 merged as **`f07eed6`** (2026-10-24T19:59:17Z): client-side delivery of the endpoint and key is the deploy path, outside `specs/`, and no mechanism is named there.

So the published leg is judged and fails: the release is in the state `B5` calls *"a deployment fault, not accepted"*.

## What this verification cannot close

Moving criteria 2, 3 or 6 needs a **published client carrying a real `T9`/`T10` pair**. After `f07eed6` that is the deploy path, which has no owner in the graph: `specs/` names no delivery mechanism, and `game/session_router.gd:33-34` must stay empty in the source tree (`T10`: never committed). Only a deploy step that fills the values into a published bundle can move them. That is a planner decision — file the deploy-path task, or supersede this defect into it — not a code change an implement dispatch can make. The last four implement passes measured the same two legs.

## Harness notes

- Probe run **unchanged**, copied into `game/` and removed after, so the tree measured is `906b8b3` plus nothing. `GODOT_BIN` set to the local `godot` `4.7.2`.
- Coverage not measured (`gdtoolkit==4.5.0` absent); logged, not claimed.
- Published build **not driven**; identity is a read. The client-side `B5` refusal drive is `review-20261025T022500Z`, same artefact.
