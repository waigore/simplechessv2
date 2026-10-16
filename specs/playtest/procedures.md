# Playtest procedures

Authoring rules: [`.agents/specs/rules/playtest/procedures.md`](../../.agents/specs/rules/playtest/procedures.md).

## When to run

At `status:pending-acceptance` (`accept-project-issue`) when the issue's deliverables change playable behavior (game or code). Skip for spec-only, docs-only, or other non-playable deliverables. Gate detail: [`playtest.md`](playtest.md).

## Select scope

1. Read coverage **Mode** from the hub and the set from [`coverage.md`](coverage.md).
2. Map the issue to design story IDs and UX journey or story IDs it can affect.
3. Intersect (1) and (2). Never include view stories.

## Prep

- Build under test is the one under acceptance.
- Must tools from [`tools.md`](tools.md) are available (`DBG.*`, `TEL.*`, both drive paths).
- Any Situational tool a selected protocol cites is available.
- Evidence folder exists under [`docs/playtest/evidence/`](../../docs/playtest/evidence/) for this issue/run.

## Per protocol

| Step | Action |
|------|--------|
| 1 | Enter the start position (use `DBG.3` when the protocol is not reachable from the default start). |
| 2 | Drive with player-facing controls and debug commands as the protocol requires. |
| 3 | Observe via `DBG.2`, `DBG.4`, and telemetry (`TEL.*`). |
| 4 | Judge pass/fail against the cited design story (game outcome) or UX story/journey (interface operation). |
| 5 | Write screenshots, notes, logs, and `manifest.md` per [`evidence.md`](evidence.md). |

Use `DBG.1` when pausing aids a reliable observation. Use `SIT.*` only when the protocol requires them.

## Outcomes

- **Pass** — every required protocol for the issue passed; evidence paths are citable.
- **Fail** — any required protocol failed. Record fail evidence and stop that protocol. Other protocols may still run for signal, but acceptance must not pass while a required protocol has failed.
- **Notes** — non-blocking only if the protocol marks that observation as non-blocking; otherwise treat as fail.
