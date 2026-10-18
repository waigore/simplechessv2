# Issue hierarchy and dependencies

Parent/child and blocker rules for Epics, Tasks, and Defects. Index: [README.md](README.md). Exact `gh` / API steps: [`.agents/skills/create-project-task/references/github-issue-linking.md`](../../.agents/skills/create-project-task/references/github-issue-linking.md).

## Hierarchy (sub-issues)

Use GitHub **sub-issues** for parent/child:

- An **epic** is the usual parent of tasks that deliver its outcome.
- A **task** may be a sub-issue of an epic **or** of another task.
- **Maximum depth: 3 levels from epic to leaf** (epic → task → task). Do not create a fourth level.
- Defects are not required to sit under an epic; link related work in the body and optionally attach as a sub-issue when it clearly belongs to that parent.

Skills reject creates that would exceed the depth limit.

## Dependencies

For blockers and ordering:

1. Set GitHub native **blocked-by** relationships (REST or GraphQL).
2. Mirror them in the issue body under `## Dependencies`:

```markdown
## Dependencies
- Blocked by: #8, #11
- Blocking: none
```

Use `none` when there are no blockers or no issues this one blocks. Merely related work belongs in `## Related tasks or defects` (defects) or prose — not as fake blocked-by edges.

Closing a blocker resolves its native dependency. `status:accepted` stays open ([workflow.md](workflow.md)), so acceptance does not. While the blocker is open, [`unblock-project-issues`](../../.agents/skills/unblock-project-issues/SKILL.md) is what deletes a satisfied edge, and only when both hold:

- The blocker is `status:accepted` or closed.
- The default branch meets every done-condition in the blocker body. A task uses deliverables and acceptance criteria; an epic uses its goal; a defect uses expected behavior. Count code, specs, demos, and playtest evidence on that branch.

Keep the edge when the blocker is not accepted, when a done-condition is missing on the default branch, or when a condition cannot be checked. That includes work present on the default branch before acceptance. The skill adds no blocked-by edges. A create flow may still remove a mistaken link while both issues are open (linking doc above). After a deletion, set the blocked issue's `Blocked by` line and the blocker's `Blocking` line from the native links that remain (`none` when empty). Do not close the blocker to force resolution.
