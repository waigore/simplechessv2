---
name: unblock-project-issues
description: |-
  Clear a native blocked-by link when the blocker is status:accepted or closed
  and the default branch shows that issue's deliverables. Use when unblocking
  issues, checking whether a blocker is done in the repo, or at the start of a
  project-planner-agent pass. Does not add dependencies or close issues.

  Examples:
    - user: "Unblock issues whose blockers are done" → judge every open edge against the default branch
    - user: "Can #40 proceed?" → judge #40's blockers only
    - called by project-planner-agent at the start of a pass
---

# Unblock project issues

Delete native **blocked-by** edges the default branch has already satisfied. The resolution rule is [`docs/issues/hierarchy.md`](../../../docs/issues/hierarchy.md). Read it and apply it. Do not invent a different bar, add blocked-by links, or close issues.

## Scope

- Default: every open `type:epic`, `type:task`, and `type:defect` issue.
- If the user names issue numbers, judge only those issues' blocked-by links.
- Delete each satisfied edge without asking for confirmation.

## Steps

1. Resolve `OWNER/REPO` and the default branch:

   ```bash
   gh repo view --json nameWithOwner,defaultBranchRef \
     --jq '{repo:.nameWithOwner, branch:.defaultBranchRef.name}'
   git fetch origin <default-branch>
   ```

   Judge `origin/<default-branch>` only. Ignore the working tree, any other local branch, and open pull requests.
2. List the target issues (`gh issue list --state open --limit 200` once per type label; raise the limit if a page comes back full). For each issue, list native blockers with `gh api --paginate`. Each object includes numeric REST `id` and issue `number`:

   ```bash
   gh api --paginate "repos/OWNER/REPO/issues/NUMBER/dependencies/blocked_by"
   ```

   Skip an issue whose list is empty.
3. For each blocker, read `state`, labels, and body (`gh issue view BLOCKER --json state,labels,body,title`). Inspect the default branch for the done-conditions hierarchy names: cited paths, specs, demos, and playtest evidence. Use `git grep` and `git ls-tree` against `origin/<default-branch>`.
4. Apply the hierarchy rule to that edge alone. Other blockers on the same issue stay until they pass the same rule.
5. On a deletion, `ISSUE_ID` is the blocker's REST `id` from step 2:

   ```bash
   gh api --method DELETE \
     "repos/OWNER/REPO/issues/NUMBER/dependencies/blocked_by/ISSUE_ID"
   ```

6. After that deletion, re-read native `blocked_by` for the blocked issue and native `blocking` for the blocker:

   ```bash
   gh api --paginate "repos/OWNER/REPO/issues/NUMBER/dependencies/blocked_by"
   gh api --paginate "repos/OWNER/REPO/issues/BLOCKER/dependencies/blocking"
   ```

   Write those remaining numbers into that issue's `Blocked by` line and the blocker's `Blocking` line (`none` when the list is empty). Change no other body section. If a `## Dependencies` section is missing, add the one from [`docs/issues/body-shapes.md`](../../../docs/issues/body-shapes.md) and fill only those two lines.
7. Do not change `status:*` labels or edit the repository.

## Report

For every edge: blocked issue, blocker, removed or kept, and the reason. For a removal or a keep because the default branch is missing work, name the done-conditions and the paths that decided it.

## Related

- Called at the start of [`project-planner-agent`](../project-planner-agent/SKILL.md)
- Add links: [`github-issue-linking.md`](../create-project-task/references/github-issue-linking.md)
- Status labels: [`docs/issues/workflow.md`](../../../docs/issues/workflow.md)
