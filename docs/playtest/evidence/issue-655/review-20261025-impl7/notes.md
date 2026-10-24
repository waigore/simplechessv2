# Notes — #655 re-run on `064f134` (2026-10-25, parallel id 2)

## The answer this run was judged under

**Catalog enabled in the published release** — the PO comment on #648, 2026-10-24T07:16:25Z. The branch that owed a record was therefore the *enabled* branch, not the history-only disabled one.

The sentence criterion 1 asks this comment to quote **does not exist on `064f134`**. `git grep -n -i "ships enabled\|release status\|published release" origin/main -- specs/` returns no match; `specs/technical/configuration.md` still reads `T9` *"Set per deployment; no fixed default"*, `T10` *"Set per deployment; never committed"*, and `B5` *"T9 or T10 missing: every deal fails (`FAIL.T14`); Elo kept; log"*. That one sentence is #648's AC2, and #655's criterion 8 forbids this defect from writing it.

## What this run settles

Nothing has moved since the previous pass. Both blockers are still open in `pending-implementation` with **no PR at all** (`gh pr list --state all --search "648 in:title"` → none; `"479 in:title"` → none), and the shipped client still carries no `T9`/`T10`.

The published leg is stronger this pass than last: the browser run records the **full request list** — 5 own-origin fetches (`/`, `index.png`, `index.js`, `index.wasm`, `index.pck`) plus one blob — and **no outbound call to a catalog or advice route at all**, followed by `WARNING: puzzle stream: deal read failed (status)`. That is the refusal happening client-side inside `B5`'s empty-value guard, which is exactly what criteria 2 and 3 measure and exactly what #479 exists to fix.

The `C5`/`S1` leg measures **conforming** a fourth time. Item 4's repair clause is *"if, and only if, item 4's `C5`/`S1` leg fails on measurement"*, so no `game/` change is owed.

## What this run does not settle

- **Criteria 1, 2, 3 and 6 stay unmet.** They cannot be met by editing this defect: criterion 1's sentence belongs to #648, and real `T9`/`T10` in a published client belongs to #479's deploy-path decision and whoever implements it.
- **Criterion 6's "held" escape was not taken.** The sequencing note allows the published leg to be recorded as held rather than failed. This pass measured it instead because it is cheap, it is owed on the enabled branch, and a measured row is stronger evidence for the next reader than a held one. Either reading lands on the same verdict.
- **The `#550` rows stay as they are.** That sweep has not re-run since 2026-10-24, so its rows are still true of the build they measured.

## Why this pass does not move the status

`implement-project-issue`'s gate is *"every deliverable checked"*. Deliverables 1, 2 and 3 are produced and attached to the issue; deliverable 4 is not owed because its only trigger (item 4 failing) did not fire. But the issue's own acceptance criteria are requirements, not deliverables, and four of them are unclearable on any build until #648 and #479 land. Moving to `pending-verification` would ask a verifier to check criteria no implementation can satisfy, and the last pass that did that on a summary was failed for it.

The honest disposition is the one already filed in [`../review-20261025T000000Z/disposition.md`](../review-20261025T000000Z/disposition.md) and unchanged by this run:

1. stop dispatching #655 to implementation until #648 and #479 land, then dispatch once against the published build; or
2. supersede #655 into a tracker scoped to the deploy path, naming this defect as the owner of the measurements.

A sixth implement pass before either happens will produce this same folder under a new timestamp.
