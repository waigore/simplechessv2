# Playtest evidence

In-repo evidence from AI-agent playtesting. Schema and requirements: [`specs/playtest/evidence.md`](../../../specs/playtest/evidence.md). Gate and scope: [`specs/playtest/playtest.md`](../../../specs/playtest/playtest.md).

## Layout

`issue-<n>/headless-<run-id>/` and `issue-<n>/graphical-<run-id>/` with at least:

- `manifest.md` — issue, environment, build/session id, coverage mode, results table, paths
- `notes.md`
- `logs/`
- `screenshots/` — per the screenshot rule in [`specs/playtest/evidence.md`](../../../specs/playtest/evidence.md)

## When required

Only when acceptance deliverables change playable behavior. Spec-only and docs-only issues do not need a folder here.

Design protocols → Headless only. UX protocols → Headless and Graphical.
