# What is new in this run — #479's exclusion, and why the disposition changes

Earlier passes on #655 recorded that `#479`'s *"new task against the deploy path"* sentence was ambiguous about whether `#479` itself would deliver anything to a client. That ambiguity is now **resolved on paper**, and it resolves the *wrong* way for this defect.

## The finding

- **PR [#806](https://github.com/waigore/simplechessv2/pull/806)** ("Record the advice key's source and delivery exclusion (#479)") is open on `task/479-advice-key-delivery`: all eight checks green, auto-merge on, `BEHIND` main only. `#479` itself is `status:pending-verification`.
- Its ADR-0010 edit records, in the Decision: *"**Client-side delivery of the configured endpoint and key is the deploy path**, so it stays out of this decision and out of `specs/`: no delivery mechanism is named there, and none is required."*
- Its own test plan asserts: `grep -rn -i "build-time injection\|runtime-fetched\|per-sitting entry" specs/` → **no match**.

So `#479`'s deliverable is the **exclusion**, not a mechanism. Even once #806 merges, `specs/` will still name no way for a published client to receive `T9`/`T10`, and `#479`'s AC1 explicitly forbids any file under `specs/` naming or requiring one.

## Why that changes the disposition

**Nothing in the issue graph now produces a published client carrying a real `T9`/`T10` pair.** `#786` (the code-side tracker) was superseded as a duplicate naming #655 as successor; `#648` owns only the wording plus a deployment measurement, and is itself `blocked_by` #479.

[`../review-20261025T000000Z/disposition.md`](../review-20261025T000000Z/disposition.md) said *"unblocking order: #479 → #648 → re-dispatch"*. That order is now known to be insufficient: **#479 landing does not deliver a pair**, because that is exactly what #479 excludes. A re-dispatch after it would produce the same measurement a ninth time.

## What is actually required

A **new task against the deploy path** — an export or deploy step that puts a real endpoint and key into the published `index.pck`. #479's ADR text (*client-side delivery is the deploy path*) is the sentence that authorizes filing it, and #648's *"new task against the deploy path"* note anticipated it.

Until that exists, #655's criteria 2, 3 and 6 cannot be met on any build, and criterion 1 cannot be met by #655's own rule. This is a planner/review decision, not one this implement pass takes.
