# Playtest evidence

In-repo index from AI-agent playtesting. Schema: [`specs/playtest/evidence.md`](../../../specs/playtest/evidence.md). Gate: [`specs/playtest/playtest.md`](../../../specs/playtest/playtest.md). Wiki media: [`wiki-evidence.md`](../wiki-evidence.md).

## Layout

`issue-<n>/<run-id>/` with:

- `manifest.md` — issue, build/session id, coverage mode, results table, wiki page URL, path to `notes.md`
- `notes.md`

Screenshots and logs are **not** stored here. Push them to the repo wiki and cite the wiki page URL. Do not commit `screenshots/` or `logs/` under this tree (gitignored).

Markdown under `issue-*` is outside the 500-word cap. This README stays inside it.

## Gate-level runs

A release gate (#400 playtest sweep, #402 quality rows on the shipped build, #403 Every-release ADR rows) writes its evidence under its own issue number, like any other run: `issue-400/`, `issue-402/`, `issue-403/`. The gate's record — its summary comment and the `manifest.md` of each run — cites the build it ran on: the playtest-seam build for #400, the published release build for #402 and #403. One never stands in for the other (ADR-0004).

A failing protocol, quality row, or ADR validation row is not fixed inside the gate. It is filed as a `type:defect` against the wave that owns the behavior, and **the defect number is cited in the `manifest.md` of the protocol that failed** — in its results row and on a `Defects` line. The gate's own record lists every defect it filed, so acceptance of the gate names them.

## When required

Only when acceptance deliverables change playable behavior. Spec-only and docs-only issues do not need a folder here.

Design protocols → Headless only. UX protocols → Headless and Graphical.

## Filmed seating

A recording is one more artifact a run's `manifest.md` cites — never a substitute for it. Definition, segments, shot list, and review verdict: [`specs/playtest/filmed-seating.md`](../../../specs/playtest/filmed-seating.md).
