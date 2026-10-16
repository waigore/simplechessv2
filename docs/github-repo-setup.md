# GitHub first-time repo setup

Apply once after creating a repository from this template (or moving it to a new remote), then verify. Requires **repo admin** access.

Agents: run `ensure-project-setup` (check, apply gaps, re-verify), or `setup-github-repo` directly (guide + verify unless asked to apply).

This doc is the contract: the **outcomes** below. Tools are the agent's judgement (`gh`, REST or GraphQL API, Settings UI); [examples](github-repo-setup-examples.md) are not binding.

Apply in this order. Protect `main` before turning on auto-merge, or a PR can merge unchecked.

## 1. Actions

GitHub Actions is enabled, and the allowed-actions policy permits the actions the workflows use (e.g. `actions/checkout`). Required checks and auto-merge run on Actions; without it, every PR waits forever.

## 2. Protect `main`

A **ruleset** (**Settings → Rules → Rulesets**) targeting `main`, enforcement **Active**, with:

| Rule | Value |
|------|-------|
| Bypass list | Empty: no one bypasses, including admins |
| Restrict deletions | On |
| Block force pushes | On |
| Require a pull request before merging | On; 0 required approvals (baseline; tighten later if needed) |
| Require status checks to pass | On; **require branches to be up to date**; checks `Spec lint` ([`spec-lint.yml`](../.github/workflows/spec-lint.yml)), `PR hygiene` ([`pr-hygiene.yml`](../.github/workflows/pr-hygiene.yml)), `Code lint` ([`code-lint.yml`](../.github/workflows/code-lint.yml)) |

Existing classic branch protection on `main` may stay; GitHub enforces the stricter of both. Do not remove or weaken it without the user's confirmation. A check appears in the UI picker only after it has run once; the API accepts check names before then.

Outcome: changes reach `main` only via PR; no one bypasses; PRs merge (or auto-merge) only when the three checks pass on a branch up to date with `main`.

## 3. Merge settings

**Settings → General → Pull Requests**:

- **Allow squash merging** only; **merge commits** and **rebase merging** off.
- Squash commit message default: **Pull request title and description**.
- **Always suggest updating pull request branches** on, since up-to-date checks hold back stale PRs.
- **Allow auto-merge** on. Same-repo, non-draft PRs then squash-merge once mergeable unless labeled `no-automerge` ([`automerge.yml`](../.github/workflows/automerge.yml)).
- **Automatically delete head branches** on. After a same-repo PR merges, GitHub deletes that PR's head branch.

## 4. Labels

Every label in [`.github/project-labels.yml`](../.github/project-labels.yml) exists on GitHub. If any is missing, sync: Actions → **Sync labels** → **Run workflow**, or `bash .github/scripts/sync-labels.sh` (needs `gh` and `yq`). Details: [`labels.md`](labels.md).

## 5. Verify

Read every setting above back from GitHub and compare it with this doc; a successful write is not proof. Confirm Actions can run (e.g. a `Spec lint` run on `main` succeeds). Setup passes only when every outcome holds.

## Blockers

On a tooling error, try another tool first. When an outcome cannot be reached with the access available (e.g. rulesets unavailable for a private repo on GitHub Free, an organization policy overrides it, or the token lacks admin), setup **fails**:

- Report the missing outcome, why, and the options (make the repo public, upgrade the plan, ask an org owner).
- Stop: no PRs until it is resolved.
- Never substitute a weaker setting.

## Related

- Agent rules: [`../AGENTS.md`](../AGENTS.md) (protected `main`, small PRs)
