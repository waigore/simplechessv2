# Authoring rules: playtest procedures

Read this before editing `specs/playtest/procedures.md` or a file split from it. Do not copy these rules into the spec.

Also read [playtest.md](playtest.md) and [tools.md](tools.md).

How the AI agent runs playtesting. Steps are agent-facing. Do not name engines, frameworks, or CI products. Do not duplicate the evidence artifact schema (that belongs in `evidence.md`). Do not list unit/integration seams (technical verification).

## When to run

Restate the hub gate: required at `status:pending-acceptance` when deliverables change playable behavior; skip for spec-only, docs-only, or other non-playable work.

## Select scope

- Read coverage mode from the hub and the set from [`coverage.md`](coverage.md).
- Map the issue to design story IDs and UX journey (or story) IDs in scope; intersect with that set.
- View stories are never in scope.

## Prep

Require: build under test; Must tools from `tools.md` available; Situational tools ready when a selected protocol cites them; evidence folder opened under `docs/playtest/evidence/` for this issue/run.

## Per protocol

Ordered steps the agent always follows: enter start position (including `DBG.3` when needed) → drive via player-facing controls and debug commands → observe via inspect, story-ID overlay, and telemetry → judge pass/fail against the cited design or UX story → write screenshots, notes, and logs into the evidence folder. Design-level protocols judge game outcomes; UX-level protocols judge interface operation.

## Outcomes

Default: any protocol fail blocks acceptance. Record fail evidence and stop that protocol; remaining protocols may still run if useful, but acceptance must not pass while a required protocol has failed. Non-blocking notes exist only when a protocol explicitly marks an observation as non-blocking.

## Splitting

If the file passes 500 words, move Per protocol detail to `procedures-run.md`. Leave a summary and a link, and update `playtest.md`.
