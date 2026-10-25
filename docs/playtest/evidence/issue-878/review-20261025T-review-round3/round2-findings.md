# #878 round 3 — the three round-2 findings

Each finding is checked twice: as recorded at round-3 tree `858eda8`, and re-read on merged
`main` `26b07af` because #892 first landed the delivery source after this branch was cut.

## 1a. `blocked_by #479` removed, `#648` kept

```
gh api repos/waigore/simplechessv2/issues/878/dependencies/blocked_by  → [648]
gh api repos/waigore/simplechessv2/issues/878/dependencies/blocking    → []
gh api repos/waigore/simplechessv2/issues/479/dependencies/blocking    → []
gh api repos/waigore/simplechessv2/issues/648/dependencies/blocking    → [878]
```

The body's `## Dependencies` section and the tracker agree: one edge, to `#648`, `Blocking: none`.
Round-2 finding 1 is closed. The `479` row is `[]` because the edge was removed, not because the
call failed.

## 1b. AC4 states which shape of `#648`'s answer it tolerates

AC4 reads: if `#648` **approves ADR-0015 as written**, the operator-run reading is the only one
and `B5`/`R9` are cited unchanged; if it **supersedes or withdraws** the ADR, `B5`/`R9` may be
rewritten by that answer's own task and this task cites their new text; either way the rewrite is
never this task's. Round-2 finding 2 is closed. The remaining fail leans on this sentence.

## 1c. Deliverable 1's integrity clause resolved to one reading

Deliverable 1 now says the real-snapshot I1 run is **not** owed here and that `#671` owns it
unconditionally on the same host. `#671` is `status:pending-implementation`, titled "Record the
served-snapshot I1 run on the catalog host (#329 AC5)" — same scope, same host. The second
reading is gone. Round-2 finding 3 is closed.

## Held against merged `main`

`#892` ("Give a build one deploy-time source for T9/T10…") merged to `main` at `26b07af`. Its
diff adds `game/build_config.gd` and wires it in `main.tscn`; the tree reads behind this verdict
are in [`delivery-gap.md`](delivery-gap.md). So the fail is not "the body missed a task that was
already merged" — it is that the body's own AC4 forecloses the mechanism that task built under
one of its two posture branches, and names no owner for it under the other.
