# #648's criterion-1 sentence, as landed on main

Landed by PR #815, commit `a94210d` — "State that the catalog route ships enabled (#648)".

`specs/technical/components/catalog-service.md:23` (`R9`):

> Ship enabled in the published release: the client carries a real T9/T10 pair, and Puzzle
> stream releases only on a real deal at the published URL, never a seam build standing in.
> Value delivery is #479.

`specs/technical/components/catalog-service.md:56`:

> Because the route ships enabled, a missing T9/T10 or an unreachable route on the published
> release is a deployment fault, never an accepted state.

`specs/technical/configuration.md` `T9`/`T10` still read "Set per deployment" and `B5` still
reads "T9 or T10 missing: every deal fails (`FAIL.T14`); Elo kept; log" — the wording
duplicate is PR #822 (open, auto-merge on), #648's own AC2, not this defect's.

Judged under the PO answer on #648 (2026-10-24T07:16:25Z): "The puzzle catalog route ships
enabled in the published release...".
