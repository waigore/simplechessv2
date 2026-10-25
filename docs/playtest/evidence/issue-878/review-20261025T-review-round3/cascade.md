# #878 round 3 — cascade evaluation

[`workflow-cascade.md`](../../../../../docs/issues/workflow-cascade.md) requires, for an agent
cascade, a native blocked-by edge plus a written reason that the other issue's implementation or
verification cannot be done or judged while this fail stands.

| Issue | Edge to `#878` | Step | Cascaded |
|---|---|---|---|
| `#648` | `blocked_by → [648]` | `status:pending-clarification` | No |
| `#479` | none (removed) | `status:accepted` | No |
| `#655` | none | `status:pending-implementation` | No |
| `#550` | none | `status:pending-verification` | No |
| `#402` | none | `status:pending-verification` | No |
| `#892` | none (holds the `T9`/`T10` source) | `status:pending-review` | No |

- **`#648`** meets condition 1 (native neighbour). Condition 2 is not met in a cascadable way, and
  its step bars it: the contract leaves `status:pending-clarification` in place even when both
  conditions hold. Its answer is this task's *input*, not a party to the fail.
- **`#479`** is accepted and has no live edge.
- **`#655`, `#550`, `#402`** have no edges to `#878`, and their steps are unchanged by this fail.
- **`#892`** is unlinked and in review. If it lands, it removes §3a's *absence of a source* but not
  §3b's conditional; the fail stands either way, so nothing follows to it.

No other issue's status changes in this run.
