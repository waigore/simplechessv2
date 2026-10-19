---
name: setup-github-repo
description: |-
  Apply and verify first-time GitHub settings for a repo from this template:
  Actions enabled, a main ruleset (PR only, required up-to-date checks, no
  bypass), squash-only merges, auto-merge, and default labels.
  Use when initializing a new remote, after forking the template, or when the user
  asks to set up branch protection / PR-only main / auto-merge.
  Use proactively when AGENTS.md rules assume protection but the remote is not configured yet.

  Examples:
  - user: "Set up GitHub workflow for this new repo" → verify gaps, walk UI checklist
  - user: "Is main protected correctly?" → read-only checks, report pass/fail
  - user: "Apply the setup for me" → apply gaps, re-verify, report
  - user: "Sync default labels if missing" → confirm, then sync-labels.sh or workflow_dispatch
---

# Setup GitHub repo

First-time GitHub workflow configuration for repositories using this template.

**Contract:** [`docs/github-repo-setup.md`](../../../docs/github-repo-setup.md) lists the outcomes. Do not invent parallel settings. Choosing tools is your judgement (`gh`, REST or GraphQL API, Settings UI); [`docs/github-repo-setup-examples.md`](../../../docs/github-repo-setup-examples.md) has non-binding examples.

## Inputs

| Field | Required | Notes |
|-------|----------|-------|
| Target repo | no | Default: current `gh` remote |
| `--apply` / "fix it" | no | Only then change settings; default is guide + verify. `ensure-project-setup` counts as an apply request, label sync included |

## Steps

1. **Read** the contract doc.
2. **Detect** the repo and access: `gh` authenticated, a GitHub remote, and admin rights on the repo. Fail clearly if any is missing.
3. **Verify** every outcome in the contract (read-only): Actions, the `main` ruleset, merge settings, labels.
4. **Report** a short pass/fail checklist of gaps.
5. **Guide** (not applying): walk the user through the Settings UI for each failing item; re-verify after each change.
6. **Apply** (apply requested): fix failing items in the contract's order (Actions, protect `main`, merge settings, labels). Prefer the API; if one tool or example fails, try another before treating it as a blocker.
7. **Re-verify** by reading every setting back from GitHub; a successful write is not proof.
8. **Blockers**: when an outcome cannot be reached with the access available (plan limit, org policy, missing admin), follow the contract's Blockers section: report the missing outcome, why, and the options; fail and stop.
9. **Final report**: pass/fail per item; link the contract for future runs.

## Rules

- Without an apply request, **do not** change repository settings.
- Never add bypass actors, allow force pushes or deletions on `main`, or substitute a weaker setting when blocked.
- Baseline: 0 required approvals; required checks `Spec lint`, `PR hygiene`, `Code lint`, `Unit tests`, and `Coverage`, with branches up to date. Add more only if the user asks.
- Do not delete unrelated labels, or remove or weaken existing stricter protection (rulesets or classic), without confirmation.
- Keep guidance aligned with the contract and [`docs/labels.md`](../../../docs/labels.md).

## Related

- Contract: `docs/github-repo-setup.md`; examples: `docs/github-repo-setup-examples.md`
- Orchestrator: [`ensure-project-setup`](../ensure-project-setup/SKILL.md) (check, then apply gaps)
- Labels: `docs/labels.md`, `.github/scripts/sync-labels.sh`
- AGENTS.md: protected `main` under Rules to live by
