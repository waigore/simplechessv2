# Writing issue bodies and comments

Safe invocation for every `gh issue create|edit|comment` write, the read-back that proves it landed, and the guard that rejects a body no reader can use. Contract: [workflow.md](workflow.md). Body-writing skills point here rather than restating the rules.

## Why

On 2026-10-22 a writer passed the sentinel `@-` to `--body` on 32 open issues ([#470](https://github.com/waigore/simplechessv2/issues/470)). `gh` treats `--body` as a literal string: it stored `@-`, exited 0, and the durable contract was lost, leaving only comment trails. `@-` is never a stdin marker.

## Write through the guarded writer

[`.github/scripts/gh_issue.py`](../../.github/scripts/gh_issue.py) wraps `gh`: it reads the composed body, rejects it before `gh` runs, passes the accepted text as `--body-file`, then reads the write back and rejects a lost one. Prefer it over calling `gh` directly.

```bash
python3 .github/scripts/gh_issue.py edit 12 --file body.md
python3 .github/scripts/gh_issue.py comment 12 --file body.md
python3 .github/scripts/gh_issue.py create --file body.md -- --title "…" --label type:task --label status:pending-review
gh issue view 12 --json body --jq .body > after.md    # the read-back the wrapper already ran
```

- The body comes from a file (`--file body.md`) or stdin (`--file -`). There is no literal-body option, so a sentinel captured into a file fails rather than being written.
- Arguments after `--` go to `gh` unchanged (`--title`, `--label`); the wrapper supplies `--body-file`.
- Exit 1 means nothing was written (rejected) or the read-back rejected the stored text. Post evidence only after exit 0; a failed write is not evidence.

## Guard before writing

`python3 .github/scripts/issue_body_guard.py <file>` (or `-` for stdin) sets aside HTML comments and headings, then exits 1 when nothing is left, all that is left is `@-` lines, or a `<!-- Template: … -->` or `<!-- fill in -->` placeholder remains. A `@-` inside a sentence is prose and passes. Run it on any script-composed or template-copied body; the wrapper runs it for you.

## Read back after writing

Every body or comment write is read back with the same rule, so a stored heading plus `@-` lines aborts the step:

```bash
gh issue view 12 --json body --jq .body | python3 .github/scripts/issue_body_guard.py --readback -
```

A heading is not content: `# T` alone is rejected in both modes, and `--readback` only warns when a stored body has no heading. If it fails, rewrite from a known-good copy; do not continue.

## Recover a lost body

A body stored as `@-`, empty, or truncated is not recoverable from itself. Stop, re-author it from the title, labels, and comment trail, write it through the wrapper, and note the repair in a comment. Re-authoring is editorial work; file it as its own task, not under the defect that broke the write.

## External writers

A runner outside this repo must call the wrapper, or use `--body-file -` and run the guard and read-back itself, with its operator confirming the call site. It must also scrub its own skill and prompt copies, which `Spec lint` cannot read; its `unsafe-body` check covers this repo's docs, skills, and issue forms.
