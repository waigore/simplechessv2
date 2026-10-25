# Findings — #878 round 4

### 1 — `AC6` points at a closed, superseded issue

`AC6` (and Deliverable 4) make commenting #655 an acceptance criterion. #655 is
CLOSED `status:superseded` as of `2026-10-25T01:43:26Z`; the pass that superseded it named
this task (#878) as where the measurement lands. The criterion's consumer no longer exists,
and the body's *Related* line still calls #655 "the measured empty stream this task's reading clears".

### 2 — The gate #648 moved out of clarification, and its body now points at #892

#648 is `status:pending-refinement` (planner pass `2026-10-25T01:41:54Z`), not
`pending-clarification` as the body states. Its recorded product-owner answer is
*catalog enabled in the release*; the pass says its remaining work is a body rewrite
pointing at #892 as the client-delivery owner. Two body sentences no longer describe the gate:
the status, and the claim that the posture question is what #648 still owes.

### 3 — Stale Description bullet contradicts Deliverable 4

Body line 36 (*Shape of the work*, item 4) still reads "…the fixture-deal versus real-deal
distinction #550 `K1` and #402's Puzzle-stream rows need to be **re-judged**" — the round-3
wording the refinement replaced in Deliverable 4 and in *Additional context*. One must go.

### 4 — A factual error about the #892 edge

Body line 29: "So this task waits on #892 (**blocked by**)". The tracker has no such edge —
`issues/878/dependencies/blocked_by` → `[648]` — and `## Dependencies` records the removal
correctly. The header prose and the canonical list contradict each other.

### 5 — Deliverable 2's alternatives do not match #892

Deliverable 2 offers "build parameter at export, **or** the missing-value entry surface #892
adds". #892 says its surface is not an entry UI: the read happens once at
`CMP-session-router:33-34`, and Playtest and Release "differ only in what a deploy-time act
injects, never in which code reads it". Naming a second surface reintroduces the second
injection path #892's own review fail rejected.
