---
name: babysit-pr-agent
description: |-
  Find one same-repo pull request that is conflicted, behind its base, or
  failing checks, then resolve conflicts, update the branch, and fix in-scope
  CI so auto-merge can squash it. Skips fork PRs. One PR per run. Use when
  automation or a user asks to unblock a PR for automerge.

  Examples:
    - dispatch with no PR → discover one eligible PR and unblock it
    - dispatch with #12 → unblock #12 when it is same-repo
---

# Babysit PR agent (facade)

Canonical instructions: [`.agents/skills/babysit-pr-agent/SKILL.md`](../../../.agents/skills/babysit-pr-agent/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
