# Writing issue bodies and comments

Safe invocation for every `gh issue create|edit|comment` write, the read-back that proves it landed, and the guard that rejects a body no reader can use. Contract: [workflow.md](workflow.md). Every body-writing skill points here instead of restating the rules.

## Why

On 2026-10-22 a writer passed the sentinel `@-` to `--body` on 32 open issues ([#470](https://github.com/waigore/simplechessv2/issues/470)). `gh` treats `--body` as a literal string: it stored `@-`, exited 0, and the durable contract was lost with only the comment trails left. `@-` is never a stdin marker.

## Compose then write

Write the body to a file or a heredoc, then pass it with `--body-file`. Stdin is `-`, not `@-`.

```bash
python3 .github/scripts/issue_body_guard.py body.md            # optional: heredoc piped through stdin with '-'
gh issue create --title "…" --label type:task --label status:pending-review --body-file body.md
gh issue edit 12 --body-file body.md
gh issue comment 12 --body-file body.md
```

- Never pass the sentinel `@-` to `--body` (stores the literal) or `--body-file` (reads a file named `@-`).
- The heredoc form `--body "$(cat …)"` works only when the heredoc is non-empty; prefer `--body-file`.

## Guard before writing

`python3 .github/scripts/issue_body_guard.py <file>` (or `-` for stdin) exits 1 when the body is empty or comments only, is exactly `@-`, or still holds a `<!-- Template: … -->` or `<!-- fill in -->` placeholder. Run it on any body composed by a script or copied from a template.

## Read back after writing

Every body or comment write is read back, and an empty result or one that is exactly `@-` aborts the step:

```bash
gh issue view 12 --json body --jq .body | python3 .github/scripts/issue_body_guard.py --readback -
```

`--readback` also rejects a stored body with no `#` heading, the usual shape of a lost body. If it fails, rewrite from a known-good copy; do not continue the workflow.

## External writers

A runner outside this repo must switch to `--body-file -` (or call the guard) and have its operator confirm the call site. `Spec lint` fails any agent-facing doc or skill that shows the unsafe forms.
