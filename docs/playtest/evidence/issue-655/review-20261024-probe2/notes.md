# Headless probe notes — #655 (branch-independent leg)

Read-only measurement pass on `origin/main` `6781577`, Godot `4.7.2.stable.official.ed1daf0bf`, `ENV.1` headless.

This folder is **not** a `pending-verification` deliverable for #655. It records the one leg of the defect's **Expected behavior** that does not depend on the branch #648 has not yet decided, so a later pass does not have to re-derive it. The branch record (deal enabled / absence path) is still owed and still blocked.

## What is blocked

`GET /repos/{owner}/{repo}/issues/655/dependencies/blocked_by` → `[648]`. Read live 2026-10-24:

| Issue | Status | Answer comment |
|---|---|---|
| #648 | `status:pending-clarification` | none (0 comments) |
| #479 | `status:pending-clarification` | none (last comment 2026-10-22 is the clarification ask) |

Acceptance criterion 1 requires *"the `specs/` sentence that states the catalog route's release status, with its commit"*. No such sentence exists on `main`; the only related rows are `configuration.md` `T10` (*"T9 and T10 serve the catalog route too"*) and `failures.md` `T14`, neither of which states a release status. Criterion 6 therefore cannot name a branch either.

## What was measured

The `C5` / `S1` leg (Expected behavior item 4). Method, raw output, and the criterion-by-criterion read are in [`readings.md`](readings.md).

Run: `godot --headless --path game -s res://_x655_min.gd` (the probe copied into `game/` for the run, removed afterwards; `game/` is unchanged). Output in `logs/x655_probe.log`.

## What this does and does not settle

It settles the **direction and location** of the item 4 repair: the reject is in `game/puzzle_session.gd:532`, the file the Deliverables clause names, not in the flow or panel routing. It does **not** fire the repair, because criterion 5 requires the control activated on the entered screen *"alongside the branch's deal record"*, and the branch is unnamed. Doing it now would leave a `game/` change that no accepted criterion covers on its own.

The `#550` manifest rows (`PTD-puzzle-stream`, `PTU-puzzle-play`, `PTU-puzzle-session`) are **not** edited: they record a completed sweep on `614746c`, and #655's deliverable scopes an update to *"if the sweep re-runs"*. It has not. The manifests still name #655 on their `Defects` lines, which is what criterion 7 requires of them today.

No `game/`, `specs/`, `asset_catalog/`, or `game_assets/` file is changed by this pass.
