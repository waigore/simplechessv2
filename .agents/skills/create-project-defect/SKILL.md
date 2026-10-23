---
name: create-project-defect
description: |-
  Create a GitHub Defect issue (type:defect) from docs/issues/; wire related
  links and native blocked-by when provided.
  Use when the user reports a bug, broken behavior, or a problem with any deliverable.
  Use proactively when a failure needs a tracked defect rather than burying it in a task.

  Examples:
  - user: "File a defect: jump input ignored on web" → collect per docs/issues/, create
  - user: "Defect related to #15, blocked by #9" → related section + blocked-by
  - user: "Draft defect body only" → --no-create
---

# Create project defect

Create a repository **Defect** (`type:defect`).

**Issue contract:** [`docs/issues/`](../../../docs/issues/) (`requirements.md`, `body-shapes.md`, `hierarchy.md`). Do not redefine sections or invent a parallel template in this skill.

**Body writes:** [`docs/issues/body-writes.md`](../../../docs/issues/body-writes.md) — guarded writer `gh_issue.py` and read-back.

**Linking (sub-issues / blocked-by commands):** [`../create-project-task/references/github-issue-linking.md`](../create-project-task/references/github-issue-linking.md).

## Steps

1. **Read** Defect requirements + body shape docs.
2. **Collect** `title` and content for every required Defect section; optional reproduction, context, `related`, `parent`, `blocked_by`, `blocking`. Ask if required content is missing.
3. **Build** the body exactly as specified in `body-shapes.md`.
4. If `--no-create` / "draft only": print title + body and stop.
5. **Create**: write the composed body to a file and run `python3 .github/scripts/gh_issue.py create --file body.md -- --title "…" --label "type:defect" --label "status:pending-review"`, per [`body-writes.md`](../../../docs/issues/body-writes.md) (guard and read-back are built in).
6. If `parent` is set: attach as sub-issue (linking reference); enforce depth rules from `hierarchy.md` when nesting under a task chain.
7. **Blocked-by**: for each true blocker, follow the linking reference. Related-only issues stay in `## Related tasks or defects` per the docs.
8. **Report** URL, labels (`type:defect`, `status:pending-review`), parent (if any), related links, and dependency wiring.

## Rules

- Apply labels `type:defect` and `status:pending-review`.
- Default: create on GitHub.

## Related

- Form: `.github/ISSUE_TEMPLATE/defect.yml`
- Contract: `docs/issues/`
- Workflow: `docs/issues/workflow.md`
