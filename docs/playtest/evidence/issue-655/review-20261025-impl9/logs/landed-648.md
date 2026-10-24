# #648's sentence landed mid-pass — `a94210d` (PR #815)

Appended to this pass's record **after** its measurements, because the landing happened
while the pass was still open.

- **Commit**: `a94210d` "State that the catalog route ships enabled (#648) (#815)", merged
  2026-10-25T17:3xZ, on `origin/main`.
- **The sentence criterion 1 asks for**, `specs/technical/components/catalog-service.md:56`:

  > Because the route ships enabled, a missing T9/T10 or an unreachable route on the
  > published release is a deployment fault, never an accepted state.

  and its requirement row `R9` (line 23):

  > Ship enabled in the published release: the client carries a real T9/T10 pair, and
  > Puzzle stream releases only on a real deal at the published URL, never a seam build
  > standing in. Value delivery is #479.

## What this changes, and what it does not

- **Criterion 1**: was **unmet** on the measured `ce8a156`; now **satisfiable**, and the
  quote above with its commit is what the issue asks a pass to record. A pass that starts
  *after* `a94210d` measures against it and quotes it directly.
- **Criterion 6**: one half of the sequencing note's condition is now false. The
  *published* build still cannot carry the pair, because #479's delivery text
  (PR #806) is still **open** and no deploy-path work has happened — the published
  `index.pck` is unchanged and still pre-#648. So the published rows remain **held**, but
  a *newer* published artefact is now required to measure them.
- **Criteria 2 and 3 are unchanged.** The spec now says a missing `T9`/`T10` on the
  published release is a deployment fault, which is exactly the state this defect
  records: `X655 B5 endpoint=<> key_set=false is_available=false`. The landing makes the
  defect *more* clearly a live defect, not less.

## Consequence for the next pass

`R9` now names the observable precisely, and it says *"never a seam build standing in"* —
so the seam-build re-runs every previous folder recites are no longer the criterion-6
evidence. The next dispatch of #655 is meaningful once (a) #806 merges, and (b) a release
carrying the pair is published. Before (b) it will measure the same `B5` refusal, now
against a spec that calls that refusal a deployment fault.
