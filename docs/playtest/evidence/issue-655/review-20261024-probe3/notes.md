# Headless probe notes — #655 (C5 / S1 leg repaired)

Re-measurement on `main` `227a1be`, Godot `4.7.2.stable.official.ed1daf0bf`, `ENV.1` headless. Run after the `PuzzleSession.request_confirm` repair so the item 4 leg is measured on the repaired tree, not only in unit tests.

## What changed since `review-20261024-probe2`

`request_confirm` refused `C5` whenever no puzzle was open. `UI-puzzle-play` gates `C5` on *"Not S2 or S4"* only, so the guard was narrower than the spec and made leave unreachable on the `S1` a failed catalog read leaves behind. The repair scopes the open-puzzle guard to `C3` / `C4`; `C5` now raises `leave_confirm` on any `S1`.

## What was measured

`probe/x655_confirm_probe.gd` runs two legs, both writing to `logs/x655_probe.log`:

1. **Flow leg** — builds `PuzzlePlayFlow` as `session_router._enter_puzzle_play` does, with `T9`/`T10` at their `""` defaults, enters it, then activates `C5` and Cancel through `PuzzlePlayFlow.control`.
2. **Journey leg** — builds a booted `SessionRouter` (`persist_store_test._boot_router` shape), drives `mode-pick` `C2` → `puzzle-play` `C5` → `confirm`.

```
X655 B5 endpoint=<> key_set=false is_available=false
X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>
X655 PANEL_C5_GATE=true
X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true
X655 CANCEL state=S1 has_puzzle=false
X655_PROBE pass
X655 ROUTER booted=mode-pick entered=puzzle-play C5=S2 after_confirm=mode-pick flow_left=true
X655 ROUTER_JOURNEY pass
```

Read against the criteria:

- **Item 4 / criterion 5 — `pass`.** `C5` on the entered `S1` with no puzzle open raises `S2` with `leave_confirm`, Cancel returns to `S1` unchanged, and on the shipped router Confirm reaches `mode-pick` with the flow dropped (`J-puzzle-session` S2, `US5.1` / `US5.2` / `US5.3`). Previously the same probe recorded `confirm_shown=false`.
- **Criteria 2–4 — still open, still `B5`.** `is_available=false` with `endpoint=<> key_set=false`, so the deal still refuses at the client's empty-value guard. That is #648's and #479's layer, not this defect's; no branch can be named until #648 answers.

## What this does not settle

The branch record. `#655`'s blocked_by is still `#648`, which remains `status:pending-clarification` with no answer comment, and `specs/` still carries no sentence stating the catalog route's release status — so criterion 1 cannot be met and criteria 2–3 cannot be judged on either branch. This folder records the one leg the answer does not decide.

No `game/`, `specs/`, `asset_catalog/`, or `game_assets/` file is changed by the probe itself; the run copies the probe into `game/` and removes it.
