# Playtest outcomes

Authoring rules: [`.agents/specs/rules/playtest/procedures.md`](../../.agents/specs/rules/playtest/procedures.md). Scope selection, prep, and the per-protocol steps: [`procedures.md`](procedures.md). Artifact schema and outcome vocabulary: [`evidence.md`](evidence.md).

## Outcomes

- **Pass** — every required protocol passed and required graphical-run screenshots for the same build are citable.
- **Fail** — a required protocol failed for a game or interface reason. Record notes and logs and stop that protocol; other protocols may still run for signal, but acceptance must not pass. May file a defect without screenshots; that defect's number is cited in the protocol's results row and on a `Defects` line in `manifest.md`.
- **Waiting** — folder-level. Judgement is recorded and screenshots still wait on a graphical re-run. Stay on `status:pending-acceptance`.
- **Notes** — non-blocking only if the protocol marks that observation as non-blocking; otherwise treat as fail.

## Filing a failure

A failure is filed as a `type:defect` against the wave that owns the behavior ([`quality-regression-owners.md`](../definition/quality-regression-owners.md) for quality rows; the owning wave epic for a protocol), citing the evidence folder and protocol that found it and linking the release gate that ran it. The gate never fixes its own finding.
