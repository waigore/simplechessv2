# Playtest evidence

Authoring rules: [`.agents/specs/rules/playtest/evidence.md`](../../.agents/specs/rules/playtest/evidence.md).

## Root and layout

- **Root**: [`docs/playtest/evidence/`](../../docs/playtest/evidence/)
- **Run folder**: `issue-<n>/<run-id>/` (date or opaque run id)
- **Skip**: when [`playtest.md`](playtest.md) says playtesting is not required, no folder is required

## Required artifacts

| Artifact | Requirement |
|----------|-------------|
| Story IDs | Every design/UX story (or protocol) in the run's scope |
| Pass / fail | One outcome per story or protocol |
| Screenshots | See below |
| Notes | Judgement text for the run |
| Logs | Session excerpt for the judged window |
| `manifest.md` | Index of the above |

## Manifest (`manifest.md`)

| Field | Content |
|-------|---------|
| Issue | GitHub issue number |
| Build / session id | Matches `TEL.3` where possible |
| Coverage mode | `full` or `critical-only` from the hub |
| Results | Table: story or protocol ID → pass / fail |
| Paths | Relative paths to screenshots, `notes.md`, and log file(s) |

## Screenshots, logs, notes

- **Screenshots**: ≥1 image per **failed** protocol; for each **pass**, ≥1 image of the judged state unless the protocol says none. Store under `screenshots/` in the run folder.
- **Logs**: file under `logs/` covering the judged window so `TEL.1`–`TEL.5` can be correlated.
- **Notes**: `notes.md` — what was judged, blockers, and non-blocking marks only when the protocol allows.

## Retention

Keep the run folder in-repo until the accept outcome for that issue is recorded. Do not delete it before then.

## Cite from acceptance

`accept-project-issue` cites the run folder (and `manifest.md`) when playtesting was required. Procedures that produce this evidence: [`procedures.md`](procedures.md).
