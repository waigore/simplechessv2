# Playtest evidence

Authoring rules: [`.agents/specs/rules/playtest/evidence.md`](../../.agents/specs/rules/playtest/evidence.md).

## Root and layout

- **Root**: [`docs/playtest/evidence/`](../../docs/playtest/evidence/)
- **Run folders**: `issue-<n>/headless-<run-id>/` and `issue-<n>/graphical-<run-id>/`
- **Skip**: when [`playtest.md`](playtest.md) says playtesting is not required, no folder is required
- **Design**: Headless folder only. **UX**: both folders when that protocol is in scope.

## Outcomes

This file owns the vocabulary. Stories are judged individually; the **protocol** is the acceptance unit ([`playtest.md`](playtest.md)).

- **Story outcome**: per cited story, `pass`, `fail`, or `not-judged`.
- **Protocol verdict**: `pass` only when every cited story is `pass` in that environment. Any cited story `fail` makes the protocol `fail`; a protocol is never `pass` beside a failed story. A `not-judged` story makes the protocol `not-judged` there, never `pass`.
- **`not-judged`**: the run could not judge the story (for example it needs a display the run lacks). It never counts as `pass`. The issue stays `status:pending-acceptance` until another run judges it.
- **`Waiting`**: folder-level only ([`procedures.md`](procedures.md)); never a story outcome or protocol verdict.

Worked example: a protocol cites four stories; one run records three `pass` and one `fail`. Its protocol verdict is `fail`, so the folder is not acceptable.

## Required artifacts

| Artifact | Requirement |
|----------|-------------|
| Story IDs | Every design/UX story in the run's scope |
| Results | One story outcome and one protocol verdict per selected protocol |
| Screenshots | Per the screenshot rule below |
| Notes | Judgement text for the run |
| Logs | Session excerpt for the judged window |
| `manifest.md` | Index of the above, including environment; fields: [`evidence-manifest.md`](evidence-manifest.md) |

## Screenshots, logs, notes

- **Screenshots**: Required before acceptance unless the protocol says none: ≥1 image of each failed protocol and of each `pass` judged state, captured by a graphical run of the same build under `screenshots/`.
- **Headless run**: May judge and record outcomes, notes, and logs with no display. Omit `screenshots/` and mark those paths waiting in `manifest.md`; that omission is no fail and files no defect.
- **Logs**: under `logs/`, covering the judged window for `TEL.1`–`TEL.5`.
- **Notes**: `notes.md` — what was judged, blockers, and non-blocking marks only where allowed.

## Retention

Keep each run folder in-repo until the accept outcome for that issue is recorded.

## Cite from acceptance

`accept-project-issue` cites the run folder and `manifest.md`. It accepts only once graphical-run screenshots of the same build exist for every protocol that requires them; a protocol saying none may be accepted from the headless run alone. A game or interface fail still blocks acceptance and may file a defect without screenshots. Procedures: [`procedures.md`](procedures.md).
