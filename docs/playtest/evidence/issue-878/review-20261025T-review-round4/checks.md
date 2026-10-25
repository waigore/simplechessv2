# Review checks — #878, round 4

Unattended `issue-workflow-review-agent` run, parallel id 1, `Assigned issue: none`.
Issue under review: **#878** (`type:task`, `status:pending-review`) — the only open issue with that label.
Read against `origin/main` **`26b07af`**.

## What was re-verified (and holds)

| Body claim | Read-back on `main` |
|---|---|
| Both advice fields are initialised empty and only read in production | `game/session_router.gd:33-34` `advice_endpoint := ""` / `advice_api_key := ""`; the only other assignments in `game/` are `game/advice_ui_test.gd:40-41` |
| `B5` states the release criterion | `specs/technical/configuration.md:43` — *"Ships enabled in the release: a missing T9 or T10 there is a deployment fault … Arrival: #479"* |
| `R9` states the ship criterion | `specs/technical/components/catalog-service.md:23` — *"Ship enabled in the published release … release Puzzle stream only on a real deal at the published URL"* |
| `T9`/`T10` rows | `configuration.md:31-32` — *"Set per deployment; never committed; ships set"* |
| ADR-0015 is `Proposed` | `specs/adr/index.md` (new in `26b07af`, #894) lists ADR-0015 — **Proposed** |
| `#892` owns the client delivery surface | #892 open, `type:task`; body Deliverable 1 scopes one read at `CMP-session-router:33-34` |
| Tracker: no stale `#479` edge | `issues/878/dependencies/blocked_by` → `[648]` |
| `L-puzzle-stream` `K1` row exists | `specs/playtest/design/puzzle-stream.md:8` cites `K1`; row `S1` at `:15` |
| #402 still `pending-verification` | open, `type:task,status:pending-verification` |

The three round-3 findings are closed in substance:

1. Deliverable 2 no longer claims a surface on `main`; `#892` owns it and Deliverable 2 records the run through it.
2. The project-hosted branch names the rewrite owner: *"#648, or the task #648's answer names for it"* (`Acceptance shape by posture`).
3. Deliverable 4 now states the concrete `K1` / release-row reading with the transport's kind.

## Findings (this round)

### 1 — `AC6` points at a closed, superseded issue

`AC6` (and Deliverable 4) make **commenting #655** an acceptance criterion.
`#655` is **CLOSED `status:superseded`** as of `2026-10-25T01:43:26Z`; the planner pass that
superseded it named **this task (#878)** as where the measurement now lands.
The criterion's consumer no longer exists, and the body's *Related* line still calls #655
*"the measured empty stream this task's reading clears"*.

### 2 — The gate `#648` moved out of clarification, and its body now points at `#892`

`#648` is `status:pending-refinement` (planner pass `2026-10-25T01:41:54Z`), not
`pending-clarification` as the body states. Its recorded product-owner answer is
*catalog enabled in the release*; the planner pass says its remaining work is a body rewrite
that points at `#892` as the client-delivery owner. So two body sentences no longer describe
the gate: the status, and the claim that the posture question is what #648 still owes.

### 3 — Stale Description bullet contradicts Deliverable 4

Body line 36 (Description, *Shape of the work* item 4) still reads *"…the fixture-deal versus
real-deal distinction #550 `K1` and `#402`'s Puzzle-stream rows need to be **re-judged**"* —
the exact round-3 item-3 wording, which the refinement replaced in Deliverable 4 and in the
*Additional context* note. One of the two must go.

### 4 — A factual error about the `#892` edge

Body line 29: *"So this task waits on #892 (**blocked by**)"*. The tracker has **no** such edge
— `issues/878/dependencies/blocked_by` → `[648]`. The `## Dependencies` section records the
removal correctly ("#892 (edge removed … edge not warranted)"), so the header section and the
dependency list contradict each other. (Same class as the round-2 fail, smaller: no edge is
claimed in the canonical list, only in prose above it.)

### 5 — Deliverable 2's alternatives do not match `#892`

Deliverable 2 offers *"build parameter at export, **or** the missing-value entry surface #892
adds"*. #892's body says its surface is **not** an entry UI: the read happens once at
`CMP-session-router:33-34`, and Playtest and Release *"differ only in what a deploy-time act
injects, never in which code reads it"*. Naming a second surface here reintroduces the
"second injection path" that #892's own review fail rejected.
