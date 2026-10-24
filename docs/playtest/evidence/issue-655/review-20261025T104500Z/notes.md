# Notes — #655 implementation re-run #11 on `6a969ee`

Detail for [`manifest.md`](manifest.md). Every line below is measured on a clean detached
worktree of `origin/main` `6a969ee`; the probe script is carried over unchanged from
`review-20261025-impl10`. This pass wrote no `game/`, `specs/`, `asset_catalog/`, or
`game_assets/` file.

## What moved since the verify fail on `8af7f8f`

| Item | On `8af7f8f` | On `6a969ee` |
|---|---|---|
| Criterion 1 sentences | present (`a9192a0`, `a94210d`) | present |
| `game/session_router.gd:33-34` | `""` | `""` — unchanged |
| Probe output | identical | **byte-identical** |
| #479 delivery decision (PR #806) | **open** | **merged `f07eed6`** (2026-10-24T19:59:17Z) |
| Published `index.pck` | `"6adcf171-91ff1c"` | `"6adcf171-91ff1c"` — no release since |

`origin/main` moved by docs-only commits (`ffb2b39` #768 wiring, `1894f31` #546 record,
`f07eed6` #479 record, `6a969ee` #478 record). None touches the deal path.

## Criteria 2, 3 and 6 stay the defect's live symptom

- **2** `is_available()` is false because both values are empty:
  `X655 B5 endpoint=<> key_set=false is_available=false`. The only assignment anywhere in
  `game/` is the test seam `game/advice_ui_test.gd:40-41`.
- **3** The stream enters `S1` with nothing dealt, no puzzle id, `last_failure=<status>` —
  neither `K1` nor a committed `F-puzzle-catalog.X2`. The body calls this a `fail`.
- **6** The published `index.pck` is unchanged since `review-20261025T022500Z` measured a
  zero-catalog-request cold open. `configuration.md` `B5` calls a missing `T9`/`T10` on the
  published release *"a deployment fault, not accepted"*; the release is in exactly that state.

## Criterion 6: the **held** clause is spent — measured, not inferred

Criterion 6 permits **held** only *"while #648's `specs/` sentence and #479's delivery
decision are unlanded"*. As of this pass **both halves have landed**
([`logs/held-condition.log`](logs/held-condition.log)):

- **#648's sentence** — `configuration.md:43` `B5` (`a9192a0`, PR #822) and
  `catalog-service.md:56` (`a94210d`, PR #815), both ancestors of `origin/main`.
- **#479's delivery decision** — PR [#806](https://github.com/waigore/simplechessv2/pull/806)
  merged `f07eed6`. ADR-0010 now reads: *"Client-side delivery of the configured endpoint
  and key is the deploy path, so it stays out of this decision and out of `specs/`: no
  delivery mechanism is named there, and none is required."*

So the defect can no longer be parked as *held*. It is judged, and on the current published
artefact it fails: the shipped client still refuses inside `B5`'s empty-value guard.

## Criteria that hold

- **1** — quoted in [`logs/criterion1-2-3-grep.log`](logs/criterion1-2-3-grep.log) with both commits.
- **4** — the absence is observable exactly as the body defines it: Elo `1000.00` unchanged,
  no puzzle id, `PuzzleStream.last_failure` holds `<status>`, and the run log carries
  `WARNING: puzzle stream: deal read failed (status)` twice. No player-facing absence copy
  is required by `specs/`, and none is invented here.
- **5** — `C5` → `EX.confirm` (`leave_confirm`) → Cancel back to `S1`, and the router journey
  `mode-pick` → `puzzle-play` → confirm → `mode-pick`, both `pass`. `TEL.3`
  `sess-1792873135319-1941-playtest-242597` carries `puzzle.enter` (`J-puzzle-session.S1`) →
  `puzzle.confirm` (`leave_confirm`) → `puzzle.leave` (`J-puzzle-session.S2`). The item-4
  repair clause does not fire, so no `game/` change is owed.
- **7** — the `#550` sweep has not re-run; its `Defects` line still names #655.
- **8**, **9** — this folder adds no `specs/`, asset, or `game/` change and implies no edge.

## Why this pass writes no code — and where the fix now belongs

Item 4 is the only `game/` change this defect may own, and on `origin/main` today it is
conforming: `game/puzzle_session.gd:554` sets `needs_puzzle = false` for `C5`, so the
`has_open_puzzle()` guard no longer applies to it. `git blame` on `origin/main` attributes
both that line (554) and the gate it exempts (557) to **#694**, merge `2e389b5`. The probe
confirms the result end to end (`X655_PROBE pass`, `X655 ROUTER_JOURNEY pass`), so the
repair clause does not fire and no `game/` change is owed.

Criteria 2, 3 and 6 need a published client carrying a real `T9`/`T10` pair. With PR #806
merged, the graph now records that delivery as **the deploy path, outside `specs/`** — and
no issue in the graph owns that deploy-path step. Nothing dispatched to an implement agent
can move criteria 2, 3 or 6 until one does, because:

- `specs/` deliberately names no delivery mechanism (ADR-0010, `f07eed6`);
- `game/session_router.gd:33-34` is the shipped default and must stay empty in the source
  tree (a committed key is forbidden by `T10`);
- setting the values requires the deploy step that fills them into a published bundle.

That is a planner decision — file the deploy-path task, or supersede this defect into it.
It is not taken here, and no `game/` default is changed to fake a deal.

## Harness limit

Coverage was not measured: `gdtoolkit==4.5.0` is absent in this container, so
`gdscript_tests.py coverage` exits before running. The unit suite itself is green (32/32).
