---
name: verify-project-issue
description: |-
  Independently verify an epic/task/defect in status:pending-verification against
  its deliverables; post pass or fail and advance or return status. When linked
  PRs contain code changes, run review-code and treat a Fail as verify Fail.
  Use when checking implemented work (smoke test) before acceptance.

  Examples:
    - user: "Verify #12" → independent checks, pass/fail comment, gate status
    - user: "Verification failed on #12: missing tests" → fail → pending-implementation
---

# Verify project issue

Independent verification (smoke test) for a typed issue in `status:pending-verification`.

**Contract:** [`docs/issues/workflow.md`](../../../docs/issues/workflow.md)

**Evidence writes:** [`docs/issues/body-writes.md`](../../../docs/issues/body-writes.md) — `--body-file`, guard, read-back.

**Status gate:** [`enforce-task-workflow-status`](../enforce-task-workflow-status/SKILL.md)

**Delegates when applicable:** [`review-code`](../review-code/SKILL.md) · [`review-asset`](../review-asset/SKILL.md) · [Verification in `docs/demos.md`](../../../docs/demos.md#verification) · [`docs/demo-style-assets.md`](../../../docs/demo-style-assets.md#verification)

## Steps

1. **Refuse** if this session also posted the implementation summary for this issue. Prefer a different comment author than that summary when detectable (`gh api` / comment list).
2. **Load** issue `n`, implementation comment, and linked PRs/commits/paths.
3. **Assert** `status:pending-verification`.
4. **Check** (smoke-level, independent of the implementor’s claim):
   - Deliverables align with what the issue demands
   - Coding/architecture/spec/doc standards closely followed where applicable
   - No major gaps/ambiguities/underspecifications requiring revision
   - If coding: unit test coverage adequate; tests sensibly cover program logic
   - **If any linked PR contains code changes:** run [`review-code`](../review-code/SKILL.md) on those PR diffs. Include its report. A Fail from that skill fails verification.
   - **If any linked PR adds or changes cataloged assets:** run [`review-asset`](../review-asset/SKILL.md) on those catalog entries. Include its report. A Fail from that skill fails verification.
   - **If the deliverable is a gameplay demo** (`demos/<slug>/`): check per [Verification in `docs/demos.md`](../../../docs/demos.md#verification) and [`docs/demo-style-assets.md`](../../../docs/demo-style-assets.md#verification) instead of code review and unit-test coverage. A Fail there fails verification.
5. **Outcome:**
   - **Pass** — comment summarizing what was checked against each deliverable (include delegated review Pass when run). Gate: `pending-verification` → `pending-acceptance`.
   - **Fail** — detail issues (include delegated review findings when that review failed). Gate: `pending-verification` → `pending-implementation`.
6. **Report** URL, outcome, new status.

## Rules

- Must be independent of the implementor’s comment and session.
- Freeform evidence; intent must be clear.
- Call `enforce-task-workflow-status` for the label change.
- Do not skip `review-code` when linked PRs include implementation files.
