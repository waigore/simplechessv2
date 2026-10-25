# Issue #878 — review round 3 checks

Unattended `issue-workflow-review-agent` run (parallel id 1, `Assigned issue: none`).
Recorded at tree `858eda8`; round-2 closes are re-read on merged `main` `26b07af` in
[`round2-findings.md`](round2-findings.md). All tree reads are against `origin/main` `5800770`
("Load Ambient after the mode-pick paint (#856) (#877)") unless a file says otherwise. Tracker
reads are live `gh` calls made in the same run, recorded verbatim.

Every claim is a read-back, not an inference from the body or the comment trail.

| File | Holds |
|---|---|
| [`round2-findings.md`](round2-findings.md) | The three round-2 findings: the edges, AC4, the integrity clause |
| [`body-facts.md`](body-facts.md) | Every fact the body cites, re-read on `main` |
| [`delivery-gap.md`](delivery-gap.md) | The fail: no `T9`/`T10` delivery path in `game/`; both posture branches |
| [`cascade.md`](cascade.md) | Cascade evaluation under `workflow-cascade.md` |

## Verdict

**Fail → `status:pending-refinement`** on `#878` only. The round-2 findings are closed and the
body's factual premises hold, except one: the body says `game/` needs no change and `main` already
carries what `T9`/`T10` need, and the re-read below contradicts that. No non-test line assigns
either value, no non-test `OS.get_environment` reads one, and no spec section states where they
come from. So AC2 can only be met by first building that delivery path, which AC4 forbids
([`delivery-gap.md`](delivery-gap.md)). The single remaining defect is that conditional: one of
its two branches is unexecutable on `main`, so the implementer is asked either to break AC4 by
inventing a mechanism or to record a run that cannot happen.
