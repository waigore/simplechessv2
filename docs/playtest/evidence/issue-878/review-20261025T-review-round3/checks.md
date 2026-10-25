# Issue #878 — review round 3 checks

Unattended `issue-workflow-review-agent` run (parallel id 1, `Assigned issue: none`).
All tree reads are against `origin/main` `5800770` ("Load Ambient after the mode-pick paint (#856) (#877)").
Tracker reads are live `gh` calls made in the same run, recorded verbatim below.

Every claim in this file is a read-back, not an inference from the body or the comment trail.

## 1. The three round-2 findings

### 1a. `blocked_by #479` removed, `#648` kept

```
gh api repos/waigore/simplechessv2/issues/878/dependencies/blocked_by  → [648]
gh api repos/waigore/simplechessv2/issues/878/dependencies/blocking    → []
gh api repos/waigore/simplechessv2/issues/479/dependencies/blocking    → []
gh api repos/waigore/simplechessv2/issues/648/dependencies/blocking    → [878]
```

Both read-backs quoted in the body and in the 2026-10-25T00:50Z refinement comment hold.
The body's `## Dependencies` section and the tracker now agree: one edge, to `#648`, with
`Blocking: none`. Round-2 finding 1 is closed.

### 1b. AC4 states which shape of `#648`'s answer it tolerates

AC4 now reads: if `#648` **approves ADR-0015 as written**, the operator-run reading is the
only one and `B5`/`R9` are cited unchanged; if it **supersedes or withdraws** the ADR,
`B5`/`R9` may be rewritten by that answer's own task and this task cites their new text;
either way the rewrite is never this task's. Round-2 finding 2 is closed — and the sentence
is the one the remaining problem below leans on.

### 1c. Deliverable 1's integrity clause resolved to one reading

Deliverable 1 now says the real-snapshot I1 run is **not** owed here and that `#671` owns it
unconditionally on the same host. `#671` is `status:pending-implementation` and titled
"Record the served-snapshot I1 run on the catalog host (#329 AC5)" — the same scope, on the
same host. The second reading is gone. Round-2 finding 3 is closed.

## 2. Facts cited by the body, re-read

| Body claim | Read-back | Holds |
|---|---|---|
| `B5` says the release ships enabled and a missing pair is a deployment fault | `configuration.md:43` | yes |
| `R9` restates the criterion and cites `B5` | `components/catalog-service.md:23` | yes |
| ADR-0015 is `Status: Proposed`, decides no project backend, catalog route on operator's host | `adr/decisions/0015-….md:5`; `R8` names the operator as the host owner | yes |
| `#648` is `status:pending-clarification` | live label read | yes |
| `#648` holds the posture question, unanswered | latest comment 2026-10-25T00:34Z is a planner pass, not a PO answer; the PO clarification is 2026-10-24T07:16Z on the *spec* question | yes, for the posture question |
| `#329` delivered the serve route | `advice_backend/catalog.py` exists; `#329` `status:accepted` | yes |
| `#479` records client delivery as a deploy-time decision, advice-scoped | `#479` `status:accepted` | yes |
| `#655` records the empty stream | `#655` `status:pending-implementation`; its Description cites `session_router.gd:33-34` | yes |
| `game/` does not change: `session_router.gd` initialises both | `session_router.gd:33-34`; the only non-test reference is a read | yes |
| `puzzle_play_flow.gd` already receives them | `puzzle_play_flow.gd:40` forwards both into `CatalogDealClient.configure` | yes |
| `CatalogDealClient.is_available()` guards on empty values | `catalog_deal_client.gd:34` `configure`, `:39` `is_available` | yes |
| Technical element IDs exist | `B5`, `T9`, `T10`, `R6`/`R7`/`R8`/`R9`, `SCH-puzzle-catalog`, ADR-0008/0010/0015 all present at the cited paths | yes |

Technical-elements check passes: every layer, module, component, contract, schema and ADR the
title and body name exists on `main`.

## 3. The problem that fails this round

The body's own AC4 makes this task's work a conditional of `#648`'s answer. Two of its four ACs
cannot be written by the implementer under one branch of that condition, because `main` carries
no place for the value to arrive from and no client read of it.

### 3a. Nothing assigns `T9`/`T10` anywhere in `game/`, and AC2 requires a record of the run that did

```
grep -rn "advice_endpoint\s*=\|advice_api_key\s*=" game/*.gd
  game/advice_ui_test.gd:40  _router.advice_endpoint = "http://advice.test/advice"
  game/advice_ui_test.gd:41  _router.advice_api_key = "test-key"
grep -rn "OS.get_environment" game/*.gd
  advice_client_test.gd:600,634  ADVICE_STREAM_PEER   (test seam)
  advice_readiness_test.gd:238   CI_COV_OUT          (coverage harness)
  release_scene_test.gd:60       CHESS_EXPORT_SCENES (test harness)
  string_table_test.gd:269       CHESS_SPECS_ROOT    (test harness)
grep -n "T9\|T10\|advice_endpoint\|ADVICE" .github/scripts/web_export.py
  line 82 only — a comment in the engine-bundle regex
grep -n "custom\|args" game/export_presets.cfg
  custom_template/* and html/custom_html_shell only; no script arguments
```

`session_router.gd:33-34` initialises both to `""`; `:502` and `:793` only read them.
`main.tscn` carries no value (confirmed by #655's Description and unchanged since).

So on `main` there is **no** build-time injection step, no per-sitting entry UI, and no fetched
config path. AC2 — "the deploy-time path #479 records, with the run that set them recorded (build
commit, timestamp)" — can only be satisfied by *first building* one of those mechanisms, which
the body forbids under AC4 ("names no client delivery mechanism") and which `CMP-catalog-service`
`R6`/`R7` plus `T10`'s never-committed rule constrain.

### 3b. The posture branch the body treats as the narrow one is the branch that cannot proceed

The body's *Acceptance shape by posture* says:

- **Operator-run posture** (ADR-0015 as written) — "The dealing build is configuration-driven
  (ADR-0010) … with the pair entered or injected by the operator on that build … **no pair value
  appears in the repository or evidence**."
- **Project-hosted posture** — "a release workflow deploys the route … That posture must be
  recorded in `specs/` **before** this task is implemented — this task does not create it."

AC4 then says: "#648 **approves ADR-0015 as written** → the operator-run reading is the only one."

Under that branch, the only permitted reading (operator-run) is precisely the one that needs the
client-side entry or injection mechanism `main` does not have, and the branch that would have
supplied it (project-hosted, release workflow) is the one an approval of ADR-0015 forecloses. The
refinement comment closed on "if the owner picks the operator-run posture, Deliverables 1 and 3
collapse to 'record the operator's host and the deal on it' and no release workflow step is owed"
— but Deliverable 2 does not collapse: `T9`/`T10` still have to reach the build, and on `main`
nothing does that.

Under the project-hosted branch the problem is different but real: the body requires the
superseding ADR **and** `B5`/`R9` to be rewritten before implementation, yet the ACs are written
against `B5`/`R9` as they stand today. AC4 says the rewrite "belongs to that task, never to this
one" — but nothing names *which* task owns it, so the gate on that branch is a task that may not
exist.

### 3c. AC7 asks for comments on issues whose state the surface contradicts

- `#550` is `status:pending-verification` (body line 77: the sweep "starts once #655's deal reaches
  `main`"). AC7 asks that its `K1` "can be re-judged on the named build".
- `#402` is `status:pending-verification` and asks for every `quality.md` row on the *shipped
  release build*.

Neither is `status:pending-acceptance`, so "re-judged" has no workflow step to land on here; AC7
is satisfiable as a comment, but the words "can be re-judged" describe a state that is already
the current state for `#550`/`#402`, and both are in a step this task does not own.

## 4. Cascade evaluation

[`workflow-cascade.md`](../../../../../docs/issues/workflow-cascade.md) requires, for an agent
cascade, a native blocked-by edge plus a written reason that the other issue's implementation or
verification cannot be done or judged while this fail stands.

- **`#648`** — it *is* a native blocked-by neighbour of `#878` (`blocked_by → [648]`), so it meets
  condition 1. Condition 2 is not met in a cascadable way, and its step also bars it: `#648`'s
  current step is `status:pending-clarification`, which the contract leaves in place even when
  both conditions hold. Its answer is this task's *input*, not a party to this fail.
  **Not cascaded.**
- **`#479`** — `status:accepted`, no live edge to `#878`. **Not cascaded.**
- **`#655`, `#550`, `#402`** — no edges to `#878`; their steps (implementation, verification) are
  unchanged by this fail. **Not cascaded.**

No other issue's status changes in this run.

## 5. Verdict

**Fail → `status:pending-refinement`** on `#878` only. The round-2 findings are closed and the
body's factual premises hold; the single remaining defect is that the body's own conditional
(AC4 + *Acceptance shape by posture*) makes one of its two branches unexecutable on `main` (§3a),
so the implementer is asked either to break AC4 by inventing a delivery mechanism or to record a
run that cannot happen.
