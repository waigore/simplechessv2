# Quality evaluator evidence

In-repo results from [`run-quality-evaluators`](../../../.agents/skills/run-quality-evaluators/SKILL.md). Axes and bars: [`specs/definition/quality.md`](../../../specs/definition/quality.md) and [`specs/definition/quality/rubrics.md`](../../../specs/definition/quality/rubrics.md).

## Layout

`issue-<n>/<run-id>/manifest.md` records the issue, the mode (`deterministic` or `llm-judge`), the deliverable commit, and one results table.

Each results row is one axis: axis id, evaluator, observation or level, bar, pass / fail / blocked, a blocked reason when blocked, and the path to the observation. There is no combined score.

## When a folder is written

A run writes a folder only when it selects at least one Applies axis. A run that selects nothing writes nothing. Markdown under `issue-*` is outside the 500-word cap. This README stays inside it.

## Reuse

A passing `deterministic` record stays valid for that issue while `game/` at the deliverable commit matches `game/` at the recorded commit (`git diff <recorded> <deliverable> -- game/` is empty). Other paths may differ. A **fail** or **blocked** row still applies.

Verification writes a new `deterministic` record only when no passing record covers that `game/` tree. Land it on the open fix PR. After that PR has merged, an evidence-only chore PR is allowed only when nothing reusable exists.

Acceptance cites the matching passing record and does not re-run `deterministic`. It cites the latest `llm-judge` run for qualitative axes.
