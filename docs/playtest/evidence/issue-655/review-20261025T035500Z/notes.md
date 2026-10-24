# Notes — #655 verification, `8af7f8f`

## What this pass settled

The implementation record is **merged and checkable** — [`review-20261025-impl10/`](../review-20261025-impl10/) exists on `main` via
`e929ad9` (PR #829). The two earlier verification fails on this issue were recorded because the named deliverable lived only in a comment
or only on an unmerged branch (`#808`). **That ground is gone**, and this pass does not fail on it.

What remains is the defect's own observable, which I measured rather than read:

```
X655 B5 endpoint=<> key_set=false is_available=false
X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>
X655 PANEL_C5_GATE=true
X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true
X655 CANCEL state=S1 has_puzzle=false
X655_PROBE pass
X655 ROUTER booted=mode-pick entered=puzzle-play C5=S2 after_confirm=mode-pick flow_left=true
X655 ROUTER_JOURNEY pass
```

That output is **byte-identical** to [`../review-20261025-impl10/logs/x655-probe.log`](../review-20261025-impl10/logs/x655-probe.log) and to
[`../review-20261025-impl9/logs/x655-probe.log`](../review-20261025-impl9/logs/x655-probe.log), on three different commits. That is the
honest result: every commit since `ce8a156` that touches this defect's surface is docs-only, so nothing it measures could move.

## What moved, and what did not

| Item | Change since the impl10 pass (`5c15e80` → `8af7f8f`) |
|---|---|
| Criterion 1 (`specs/` sentence) | **Strengthened.** `configuration.md:43` `B5` now reads *"Ships enabled in the release: a missing T9 or T10 there is a deployment fault, not accepted…"*, landed **`a9192a0`** (PR #822, merged 19:48Z). Two commits now carry the sentence — `a94210d` in `catalog-service.md` `R9`, `a9192a0` in `configuration.md` `B5`. |
| Criterion 6 (published rows) | **Clause spent.** `6` permits **held** only while **both** #648's sentence and #479's delivery decision are unlanded. #648's has landed (twice over); #479's has **not** — `gh pr view 806` → `state: OPEN`, `mergedAt: null`. Half the condition is met, so **not held**, and the rows are judged. |
| Criteria 2, 3 (the symptom) | **Unchanged.** `session_router.gd:33-34` is still `""`, and the entered stream is still `S1` with nothing dealt. |
| Criterion 5 (`C5` / `S1`) | **Still conforming**, sixth measurement (repaired in #694, `2e389b5`). |
| Criterion 7 (`#550` rows) | **Unchanged.** The headless manifest was last touched by `d9e1fe1`; `4713715` added the separate start-condition check. |
| Unit suite | **32** headless tests, up from 31 at impl10. |
| Published artefact | `index.pck` `last-modified: Sat, 24 Oct 2026 17:57:05 GMT`, `etag "6adcf171-91ff1c"`, 9568028 bytes — the same artefact `review-20261025T022500Z` drove and measured the client-side refusal on. |

## Why the verdict is `fail`, not `pass`

Criteria 2, 3 and 6 are the defect's symptom. On the newest `main` the deal path still refuses inside `B5`'s empty-value guard before any
transport, the stream lands in `S1` with nothing dealt and no failed-read record, and the newest **published** release is in the state
`catalog-service.md` `R9` calls *"a deployment fault, never an accepted state"* — and criterion 6 no longer has a held clause to stand on.

A `pass` would advance a defect whose shipped surface has not moved to `pending-acceptance`.

## The gap this pass cannot close, and who owns it

Criteria 2, 3 and 6 need a **published client carrying a real `T9`/`T10` pair**. Both prerequisites the earlier passes named are now
landed or in their final state, and the outcome is still no pair:
- **#648** — `status:pending-verification`, both `specs/` halves landed (`a94210d`, `a9192a0`).
- **#479** — `status:pending-acceptance`; PR #806 (**open**, not merged) records client delivery as *the deploy path*, excluded from
  `specs/`. So #479 delivers the **exclusion**, not a mechanism.
- No issue in the graph puts a real pair into a published bundle. Nothing dispatched to implementation can move criteria 2, 3 or 6.

This is a planner decision — file the deploy-path task, or supersede this defect into it — and it is not taken here. It is recorded so the
next dispatch does not measure the same two legs a seventh time.
