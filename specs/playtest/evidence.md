# Playtest evidence

Authoring rules: [`.agents/specs/rules/playtest/evidence.md`](../../.agents/specs/rules/playtest/evidence.md).

## Root and layout

- **Root**: [`docs/playtest/evidence/`](../../docs/playtest/evidence/)
- **Run folders**: `issue-<n>/headless-<run-id>/` and `issue-<n>/graphical-<run-id>/`
- **Skip**: when [`playtest.md`](playtest.md) says playtesting is not required, no folder is required
- **Design**: Headless folder only. **UX**: both folders when that protocol is in scope.

## Required artifacts

| Artifact | Requirement |
|----------|-------------|
| Story IDs | Every design/UX story (or protocol) in the run's scope |
| Pass / fail | One outcome per story or protocol |
| Screenshots | Per the screenshot rule below |
| Notes | Judgement text for the run |
| Logs | Session excerpt for the judged window |
| `manifest.md` | Index of the above; includes environment |

## Manifest (`manifest.md`)

| Field | Content |
|-------|---------|
| Issue | GitHub issue number |
| Environment | `headless` or `graphical` |
| Build / session id | Matches `TEL.3` where possible |
| Coverage mode | `full` or `critical-only` from the hub |
| Results | Table: story or protocol ID → pass / fail |
| Paths | Relative paths to screenshots (if any), `notes.md`, and log file(s) |

## Screenshots, logs, notes

- **Screenshots**: ≥1 image per **failed** protocol; for each **pass**, ≥1 image of the judged state unless the protocol says none. A protocol that judges no rendered state says "none" where that protocol defines its evidence; otherwise the run captures per this rule. Store under `screenshots/`.
- **Logs**: file under `logs/` covering the judged window so `TEL.1`–`TEL.5` can be correlated.
- **Notes**: `notes.md` — what was judged, blockers, and non-blocking marks only when the protocol allows.

## Retention

Keep each run folder in-repo until the accept outcome for that issue is recorded. Do not delete it before then.

## Cite from acceptance

`accept-project-issue` cites the Headless and Graphical run folders (and each `manifest.md`) when playtesting was required. Procedures: [`procedures.md`](procedures.md).
