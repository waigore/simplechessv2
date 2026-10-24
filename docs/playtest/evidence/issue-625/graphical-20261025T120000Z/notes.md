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

## What the dispatch could do, and could not

An `issue-workflow-implement-agent` run on 2026-10-25 (parallel id 4) resolved #625 and checked each
precondition in *Scenario* / *Reproduction steps* against what an unattended agent has:

| Precondition | State |
|---|---|
| Published URL serves the commit carrying #647's repair | **Met.** `https://waigore.github.io/simplechessv2/` returned 200 with `Last-Modified: Sat, 24 Oct 2026 17:57:05 GMT`, which is `Web release` run [`40118381611`](https://github.com/waigore/simplechessv2/actions/runs/40118381611) at `c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96`; `bccdb1c` (#647's asset-root repair) is an ancestor of that commit. The fallback export was therefore **not** needed and is not used. |
| A physical phone, or a low-end laptop that is not the development machine | **Not met.** The dispatch host is the project's development machine — Apple `MacBook Pro` `Mac17,2` (`Apple M5`), macOS, on which the game is developed and exported. No phone and no second machine is attached, provisioned or reachable from an unattended run. |
| A café-grade network (shared Wi‑Fi or mobile hotspot) | **Not met.** The host is on the developer's own network. A hotspot cannot be opened and a café connection cannot be joined without a person present. |
| A person seated at the table, playing mode pick → Shared game → two puzzle attempts → backgrounding → quit and reopen | **Not met.** Driving it in this host's browser would reproduce exactly the desktop reading that [issue #544](https://github.com/waigore/simplechessv2/issues/544), #546, #557, #558 and #400 already carry — the reading #625 exists to *add to*, not to repeat. |
| #625's AC that no `specs/`, `game/`, `asset_catalog/`, or `game_assets/` file changes | `game/` **cannot** be touched by this work: the only in-scope deliverable is evidence, the #402 comment, and any owner comments. |

Per the issue's own device rule, *"A run that cannot put the build on a phone records those two rows
`not-judged` rather than passing them on the laptop"* — and here even the laptop reading would be a
reading of the development machine, which *Scenario* excludes by definition. So the honest record is
a folder that says the run did not happen.

## Why the GPU-less host does not rescue this

An earlier structural-capture path on this host (headless Chrome with SwiftShader, the method #402
and #557 used) can drive the published build and read pixels, but it answers a different question:
it measures a software renderer at 390×844 CSS, not a phone's hardware at 60 fps, and not a
low-end laptop's. Recording those numbers under this issue would be a fabricated Performance and
Load-time reading — the exact failure mode #625's *Actual behaviour* complains about. It was not
done.

## What a completing run needs

A person with a phone (or a non-development low-end laptop) and a café connection, following
*Reproduction steps* in the issue body. The build under test is settled and does not need to be
re-selected: **published `c5b8189`, `Web release` run `40118381611`**, carried by
`https://waigore.github.io/simplechessv2/`.

## Defects

None filed. A folder that states no reading is not a failing row, and #625's *Where a failing row
goes* table files defects only for rows that were read and failed.

## Status

#625 stays `status:pending-implementation`. It cannot reach `status:pending-verification` from this
run because it has no deliverable that can be verified — a marker folder is not the record the issue
asks for. The blocker is unattended-execution capability (hardware, network, a seated person), not
code or specs.
