# Playtest procedures

Authoring rules: [`.agents/specs/rules/playtest/procedures.md`](../../.agents/specs/rules/playtest/procedures.md).

## When to run

At `status:pending-acceptance` (`accept-project-issue`) when the issue's deliverables change playable behavior (game or code). Skip for spec-only, docs-only, or other non-playable deliverables. Gate detail: [`playtest.md`](playtest.md).

## Select scope

1. Read coverage **Mode** from the hub and the set from [`coverage.md`](coverage.md).
2. Map the issue to the story rows it can affect, taking rows and their judging protocols from [`story-rows.md`](story-rows.md).
3. Intersect (1) and (2). Never include view stories.
4. For each selected **Design** protocol, schedule a **Headless** run only.
5. For each selected **UX** protocol, schedule **Headless and Graphical** runs.

## Prep

- Build under test is the one under acceptance, named by commit and by the source it was read from. It is a local export into `build/web/` (ADR-0007) or an in-process run of that commit. The project publishes no client URL (ADR-0016). The manifest records which source was read.
- Must tools from [`tools.md`](tools.md) are available (`ENV.*`, `DBG.*`, `TEL.*`, both drive paths); `ENV.*` is the environment class from [`ids.md`](ids.md), not a second tool set. The Must environments are `ENV.1` (Headless) and `ENV.2` (Graphical).
- Any Situational tool a selected protocol cites is available.
- Evidence folders exist under [`docs/playtest/evidence/`](../../docs/playtest/evidence/) for each required environment run.

## Per protocol

1. Enter the start position (use `DBG.3` when the protocol is not reachable from the default start).
2. Drive with player-facing controls and debug commands as the protocol requires.
3. Observe via `DBG.2`, `DBG.4`, and telemetry (`TEL.*`). On Graphical, also observe rendered UI.
4. Judge each selected row as pass, fail, or not-judged, taking the row and its judging protocol from [`story-rows.md`](story-rows.md) and the outcome wording from [`evidence.md`](evidence.md); judge a design row against its game outcome and a UX row against its interface operation.
5. Derive the protocol verdict, then write notes, logs, and `manifest.md` per [`evidence.md`](evidence.md). Write screenshots when the run has a display.

A protocol is `pass` only when every cited story is `pass`. It is never `pass` while a contained story is `fail`, and it is `not-judged` when any cited story is `not-judged`. Outcomes are defined only in [`evidence.md`](evidence.md).

Use `DBG.1` when pausing aids a reliable observation. Use `SIT.*` only when the protocol requires them.

## Headless and graphical runs

A headless run (no display) may enter, drive, observe, and judge. It writes notes, logs, and `manifest.md`, and marks screenshots as waiting on a graphical run. Missing screenshots are not a fail and do not file a defect.

Before acceptance, a graphical run re-runs the protocols on the same build and writes the screenshots into its own run folder. It does not only attach images to the headless log. The graphical manifest names that same build.

A protocol that says no screenshot may be accepted from the headless run alone.

## Outcomes

Pass, fail, waiting, and notes, plus how a failure is filed: [`procedures-outcomes.md`](procedures-outcomes.md).
