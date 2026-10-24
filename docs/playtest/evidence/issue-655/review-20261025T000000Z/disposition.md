# Disposition proposed for #655 by the 2026-10-25 pass

This is a **planner / review decision, not taken here**. The pass that wrote it made no change to any other issue, opened no new tracker, and did not move #655's status on a summary — the previous pass did that and verification failed it for exactly that reason.

## Why the defect cannot be implemented as scoped

Criteria 1–3 and 6 need two things #655 forbids itself from producing:

| Need | Owner | Why not here |
|---|---|---|
| The one `specs/` release-status sentence | #648 AC2 | criterion 8: no `specs/` change |
| Real `T9`/`T10` values in a published client | #479 → the deploy path | #479 AC1 scopes delivery; the client never carries the pair |
| A code or `specs/` fix once those land and the deal still fails | a new tracker | body: file it *against the code that did not deliver*, not against #648 |

`gh pr list --state all --search "648 in:title"` and `"479 in:title"` → **no PR in either**, open or merged. Every pass that re-runs #655 without those landing produces the same record: the published build refuses at `B5`'s empty-value guard, and the `C5` leg passes.

## The two options

1. **Stop dispatching #655 to implementation** until #479 and #648 land their deliverables; then re-dispatch once, against the published build.
2. **Supersede #655** into a fresh task scoped to the deploy path — which #479's *"new task against the deploy path"* authorizes — naming this defect as the measurements' owner.

Option 1 costs nothing and keeps #655 as the record. Option 2 gives a live implementable tracker but closes the defect whose symptom is unchanged, so it needs a deliberate call.

## What a re-dispatch will need

Whatever the option, a pass that can actually clear #655 needs the published client to carry a real `T9`/`T10` pair. Until then, a re-run is a repeat measurement, not work.
