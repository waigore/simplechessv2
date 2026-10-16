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

Closing a blocker resolves the dependency in GitHub; keep the body history unless correcting a mistake.
