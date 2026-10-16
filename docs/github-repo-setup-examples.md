# GitHub setup: example commands

Non-binding examples for the outcomes in [`github-repo-setup.md`](github-repo-setup.md). GitHub's APIs and `gh` change; when an example fails, adapt it or use another tool. Check results against the contract, not these commands.

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api "repos/$REPO" --jq .permissions.admin   # expect true
```

## Actions

```bash
gh api "repos/$REPO/actions/permissions"              # expect enabled: true
gh api -X PUT "repos/$REPO/actions/permissions" -F enabled=true
gh workflow run spec-lint.yml --ref main && gh run list --workflow spec-lint.yml --limit 1
```

## Ruleset for `main`

List with `gh api "repos/$REPO/rulesets"`. Create with `POST`; update an existing one with `PUT "repos/$REPO/rulesets/<id>"`.

```bash
gh api -X POST "repos/$REPO/rulesets" --input - <<'EOF'
{
  "name": "Protect main",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": {"ref_name": {"include": ["refs/heads/main"], "exclude": []}},
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": false,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": false}},
    {"type": "required_status_checks", "parameters": {
      "strict_required_status_checks_policy": true,
      "required_status_checks": [
        {"context": "Spec lint"}, {"context": "PR hygiene"}, {"context": "Code lint"}]}}
  ]
}
EOF
```

Verify the rules in effect on `main` (rulesets and classic protection together):

```bash
gh api "repos/$REPO/rules/branches/main" --jq '[.[] | {type, parameters}]'
gh api "repos/$REPO/rulesets/<id>" --jq '{enforcement, bypass_actors}'
```

## Merge settings

```bash
gh api -X PATCH "repos/$REPO" \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -F allow_update_branch=true -F allow_auto_merge=true \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY

gh api "repos/$REPO" --jq '{allow_squash_merge, allow_merge_commit, allow_rebase_merge,
  allow_update_branch, allow_auto_merge, squash_merge_commit_title, squash_merge_commit_message}'
```

## Labels

Prints configured labels missing on GitHub; expect no output:

```bash
comm -23 <(sed -n 's/^- name: //p' .github/project-labels.yml | sort) \
  <(gh label list --repo "$REPO" --limit 1000 --json name -q '.[].name' | sort)
```
