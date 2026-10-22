# Writing issue bodies and comments

Safe invocation for every `gh issue create|edit|comment` write, the read-back that proves it landed, and the guard that rejects a body no reader can use. Contract: [workflow.md](workflow.md). Body-writing skills point here instead of restating the rules.

## Why

On 2026-10-22 a writer passed the sentinel `@-` to `--body` on 32 open issues ([#470](https://github.com/waigore/simplechessv2/issues/470)). `gh` treats `--body` as a literal string: it stored `@-`, exited 0, and the durable contract was lost with only the comment trails left. `@-` is never a stdin marker.

## Write through the guarded writer

[`.github/scripts/gh_issue.py`](../../.github/scripts/gh_issue.py) wraps `gh`. It reads the composed body, rejects it before `gh` runs, hands the accepted text over as `--body-file`, then reads the write back and rejects a lost one. Prefer it over calling `gh` directly.

```bash
python3 .github/scripts/gh_issue.py edit 12 --file body.md
python3 .github/scripts/gh_issue.py comment 12 --file body.md
python3 .github/scripts/gh_issue.py create --file body.md -- --title "…" --label type:task --label status:pending-review
gh issue view 12 --json body --jq .body > after.md    # the read-back the wrapper already ran
```

- The body comes from a file (`--file body.md`) or stdin (`--file -`). There is no literal-body option, so a sentinel captured into a file fails instead of being written.
- Arguments after `--` go to `gh` unchanged (`--title`, `--label`, `--add-label`); the wrapper supplies `--body-file`.
- Exit 1 means nothing was written (body rejected) or the write lost its contract (read-back rejected). Post evidence only after a write exits 0; a failed write is not evidence.

## Guard before writing

`python3 .github/scripts/issue_body_guard.py <file>` (or `-` for stdin) exits 1 when the body is empty or comments only, is exactly `@-`, or still holds a `<!-- Template: … -->` or `<!-- fill in -->` placeholder. Run it on any body composed by a script or copied from a template; the wrapper runs it for you.

## Read back after writing

Every body or comment write is read back, and an empty result or one that is exactly `@-` aborts the step:

```bash
gh issue view 12 --json body --jq .body | python3 .github/scripts/issue_body_guard.py --readback -
```

`--readback` also rejects a stored body with no `#` heading, the usual shape of a lost body. If it fails, rewrite from a known-good copy; do not continue.

## Recover a lost body

A body stored as `@-`, empty, or truncated is not recoverable from itself. Stop, re-author the body from the issue's title, labels, and comment trail, write it through the wrapper, and note the repair in a comment. Re-authoring is editorial work; file it as its own task, not under the defect that broke the write.

## External writers

A runner outside this repo must call the wrapper, or switch to `--body-file -` and run the guard and read-back itself, with its operator confirming the call site. It must also scrub its own skill and prompt copies, which `Spec lint` cannot read; `Spec lint` (`unsafe-body`) catches the unsafe forms inside this repo's docs, skills, and issue forms.
