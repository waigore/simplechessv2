# Agent scratch output

Where an agent puts whatever it produces but does not commit.

**The rule:** agent scratch lives **outside the repository** — the operator temp directory (`/tmp`, or `$TMPDIR`) or the agent runtime's workspace (for OpenCode, the session workspace under the system temp tree, `/private/var/folders/.../T/opencode` on macOS). It never lives in the working tree, staged or not.

A path inside the checkout is not scratch just because it is git-ignored. An ignored directory still gets read, copied, and mistaken for input, and an untracked file is one `git add -A` away from a pull request.

## What counts as planner scratch

Output a planner pass produces and no commit should carry:

- a draft of a pass report or a drift report;
- a proposed or revised issue body, or a comment, before it is written through the guarded writer;
- any intermediate list, table, or coverage working file.

## What the planner does not own

Two artifacts look like scratch and are not the planner's to place here:

- **A runtime log such as `server.log` at the repository root.** It is written by an operator's shell redirect into a manual run, and it is kept out of commits by the root [`.gitignore`](../../../../.gitignore). That ignore entry is the whole remedy; the planner writes no such log.
- **A `gh_issue.py --file` staging file.** The body-write contract owns where that file lives: [body-writes.md](../../../../docs/issues/body-writes.md) states that the file passed to `--file` also sits outside the repository, and names `/tmp/issue-body.md` (as used in [`create-project-task/references/github-issue-linking.md`](../../create-project-task/references/github-issue-linking.md)) as an accepted location.

Both rules agree with this one; neither needs restating here.
