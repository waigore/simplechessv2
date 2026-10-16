---
name: accept-project-issue
description: |-
  Accept, fail, or escalate clarification for an epic/task/defect in
  status:pending-acceptance using test evidence against acceptance criteria.
  Use when running acceptance testing after verification.

  Examples:
    - user: "Accept #12 with evidence in docs/playtest/evidence/..." → accept comment, status:accepted, leave open
    - user: "Acceptance failed; file defect" → create defect, link, → pending-implementation
    - user: "Need PO input to finish acceptance on #12" → pending-clarification
---

# Accept project issue

Acceptance testing for a typed issue in `status:pending-acceptance`.

**Contract:** [`docs/issues/workflow.md`](../../../docs/issues/workflow.md)

**Status gate:** [`enforce-task-workflow-status`](../enforce-task-workflow-status/SKILL.md)

**Playtesting:** [`specs/playtest/playtest.md`](../../../specs/playtest/playtest.md) — required only when deliverables change playable behavior (see step 4).

## Steps

1. **Refuse** if this session also posted the implementation summary for this issue (same independence bar as verification).
2. **Load** issue `n`, acceptance criteria, verification comment, related PRs.
3. **Assert** `status:pending-acceptance`.
4. **Test** against each acceptance criterion. Evidence must be locatable in the repo (logs, screenshots, paths).
   When the issue's deliverables change playable behavior (game or code), also run AI-agent playtesting per [`specs/playtest/playtest.md`](../../../specs/playtest/playtest.md) and cite evidence under [`docs/playtest/evidence/`](../../../docs/playtest/evidence/) (story IDs, pass/fail, screenshots, notes, logs). Spec-only, docs-only, or other non-playable deliverables do not require playtesting.
5. **Outcome:**
   - **Accept** — comment summarizing evidence per criterion and related PRs. Gate: `pending-acceptance` → `accepted`. **Do not close** the issue.
   - **Fail** — create a Defect via `create-project-defect` when appropriate; link it in the comment. Gate: `pending-acceptance` → `pending-implementation`.
   - **Clarify** — if tests cannot proceed without PO input, summarize questions. Gate: `pending-acceptance` → `pending-clarification`.
6. **Report** URL, outcome, new status (and defect URL if any).

## Rules

- Leave `status:accepted` issues open.
- Evidence paths should be in-repo; summarize where to find them.
- Call `enforce-task-workflow-status` for the label change.
- Do not require playtest evidence when the issue does not change playable behavior.
