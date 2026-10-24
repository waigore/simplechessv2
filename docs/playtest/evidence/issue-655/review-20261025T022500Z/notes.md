# Notes — #655 independent verification on `4f133e8`

Detail for [`manifest.md`](manifest.md). No implementation comment and no code were
written by this pass; everything below is measured on a clean detached worktree of
`origin/main` and on the published build.

## Re-measured, not inherited

- **The deliverable is on `main`.** PR [#814](https://github.com/waigore/simplechessv2/pull/814)
  merged as `2e34ee7`, which is an ancestor of `4f133e8`, and `review-20261025-impl9/`
  exists there. Both earlier verification fails were about a record that lived only in a
  comment or on an unmerged branch; that ground is gone.
- **Criterion 1 holds.** `specs/technical/components/catalog-service.md:23` (`R9`) and
  `:56` state the route ships enabled; landed as `a94210d`. `configuration.md` `B5` does
  not yet — that is PR #822, open, and #648's AC2, not this defect's.
- **Criterion 5 holds by probe.** `X655_PROBE pass` / `X655 ROUTER_JOURNEY pass`,
  byte-identical to the implement pass's log on a different commit.
- **Criterion 4 holds as an observable**, as the body defines it.

## The published leg is measured, not held

Criterion 6 allows **held** only while both #648's sentence and #479's delivery decision
are unlanded. #648's sentence has landed (`a94210d`), so the clause is spent.

- The published artefact is a **new** build: `last-modified` **2026-10-24 17:57:05 GMT**,
  `content-length` **9568028**, `etag` **`"6adcf171-91ff1c"`**, from Web release run
  `40118381611` on `c5b8189` — not the `9561236`-byte 13:00:58Z artefact earlier folders
  measured.
- That build contains `R9` (its commit `c5b8189` does) and still ships
  `game/session_router.gd:33-34` as `""`.
- A cold open, then `C2` into Puzzle stream, made **zero** catalog or advice requests:
  only `/`, `index.png`, `index.js`, `index.wasm`, `index.pck`, `index.icon.png` and one
  `blob:`, then `WARNING: puzzle stream: deal read failed (status)` twice. The refusal is
  client-side, inside `B5`'s empty-value guard, before any transport.
- `R9` calls a missing `T9`/`T10` on the published release *"a deployment fault, never an
  accepted state"*. The published release is in that state.

## One correction to the implement record

`review-20261025-impl9/` records the published artefact as byte-identical to `impl7`'s and
"predating `a94210d`". No longer true: a release published at 17:57:05Z from `c5b8189`
post-dates `a94210d`. The verdict is unchanged — the new build trades a missing sentence
for a missing value — but criterion 6 fails on this measurement.

## Harness limit

The `C5` leg on the **published** build was not established here. Synthetic pointer input
reached mode pick (`C2` entered the stream reproducibly), but no Leave-stream click raised
a confirm. That is this verifier's browser harness, not evidence about the control:
`game/puzzle_play_panel.gd:108-109` enables `C5` off `S2`/`S4`, and the probe measures the
leg conforming on the same code. No finding is filed against `C5`; criterion 5 is judged
on the probe, which is what the issue asks for.

## No cascade

#648, #479 and #550 are upstream of this defect, not blocked by it, and none is in
`pending-implementation`/`pending-verification` for a reason this fail creates.
