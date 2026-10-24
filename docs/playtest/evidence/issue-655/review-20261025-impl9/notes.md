# Notes — #655 on `ce8a156`

## What this run settles

The defect's shipped symptom is unchanged on the newest `main`, and the two things that
could change it are both unlanded:

| Need | Owner | Live state this pass |
|---|---|---|
| The one `specs/` release-status sentence | #648 AC2 | open, `pending-implementation`, no PR; grep → no match |
| Real `T9`/`T10` in a published client | #479 → the deploy path | #806 open (`BEHIND`), ADR-0010 text not on `main` |
| A code defect once a pair exists and the deal still fails | a new tracker | not yet filable — no pair exists |

Criterion 5 (`C5` on `S1`) is the only criterion this defect can move by itself, and it
measures **conforming** for the fifth consecutive pass, so item 4's repair clause does not
fire and no `game/` change is owed.

## What changed since `064f134`

`origin/main` moved two commits (`#767`/`#809` check mark, plus the `#807` evidence
merge). Neither touches `game/session_router.gd`, `game/catalog_deal_client.gd`,
`game/puzzle_play_flow.gd`, or `specs/technical/configuration.md` in any way the criteria
observe — hence the identical `X655` lines. The unit suite grew from 29 to 30 tests and
still passes.

## The criterion-6 reading, and why it differs from last pass

`review-20261025-impl7` recorded criterion 6 as **fail, not held** and measured the
published build in a browser. This pass records **held**, because the note's condition is
now not just plausible but *checked live*: #479 has an open unmerged PR and #648 has none,
and the published artefact is byte-identical to the one already measured, with the two
later release runs **failed** rather than newer. Re-opening a browser against an identical
bundle would re-log the same five own-origin requests. The observable is unchanged in
either reading — the client still carries no `T9`/`T10` — so nothing is being softened by
taking the note's own word for it.

## What this run does not do

- It does **not** move #655's status to `pending-verification`. Criteria 1–3 cannot be
  cleared by any implementation of this defect: criterion 8 forbids the `specs/`
  sentence and #479's AC1 forbids naming a delivery mechanism. Handing a verifier those
  criteria was failed on 2026-10-24T17:11Z for exactly this reason, and repeating it would
  be the tenth identical pass with a worse label state.
- It does **not** change the disposition: the planner/review choice in
  [`../review-20261025T000000Z/disposition.md`](../review-20261025T000000Z/disposition.md)
  stands unchanged — stop dispatching #655 to implementation until #479 and #648 land, or
  supersede it into a deploy-path tracker.

## The one action this pass takes that a prior pass could not

#808 (`finding-479.md`, the record that #479 delivers an *exclusion* rather than a
mechanism) has been open since 2026-10-24T17:02Z. Leaving it open means the finding the
next planner needs — that no live issue produces a `T9`/`T10` pair — stays off `main`.
This pass merges it onto `main` unchanged rather than minting an eleventh folder
containing the same finding. That is a record being landed, not a claim that #655 is
fixed.
