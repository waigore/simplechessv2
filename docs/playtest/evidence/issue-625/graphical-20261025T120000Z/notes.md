# Notes — #625 off-device release reading: not taken, no rows written

## What this folder is, and is not

This folder records that the reading #625 asks for **was not taken**. It is not a run folder with
results: there is no `manifest.md` results table, no `readings.md`, no screenshots and no logs,
because no session took place. Per [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md),
`not-judged` never counts as `pass`, and an artifact that pretends to a reading would be worse than
the absence this folder states.

The four rows #625 owes — Performance, Load time (board playable), Reliability (background/return
folded into its reopen clause), Save durability (quit/reopen) — are **left untouched**. Nothing in
this folder re-reads, supersedes, or contradicts the rows in #402's accepted record.

The build under test was resolved (published `c5b8189`, `Web release` run `40118381611`); see
[`build-resolution.md`](build-resolution.md). Why the reading could not be taken on this host, why
the headless path does not rescue it, and what a completing run needs are in
[`blockers.md`](blockers.md).

## Defects

None filed. A folder that states no reading is not a failing row, and #625's *Where a failing row
goes* table files defects only for rows that were read and failed.

## Status

#625 stays `status:pending-implementation`. It cannot reach `status:pending-verification` from this
run because it has no deliverable that can be verified — a marker folder is not the record the issue
asks for. The blocker is unattended-execution capability (hardware, network, a seated person), not
code or specs.
