# #550 start-condition check — 2026-10-25, parallel id 2

**What this folder is.** A measurement of #550's documented hard start condition on
`origin/main` `2e34ee7`, so the reason the wave-2 sweep still does not start lives in the
tree and not only in an issue comment. It was written by an unattended
`issue-workflow-implement-agent` pass ([`workflow-dispatch.md`](../../../../../docs/issues/workflow-dispatch.md)).

**What this folder is not.**

- It is **not** a sweep. It has no `manifest.md`, no story rows, and no protocol verdicts.
- It does **not** supersede `../headless-20261024T000000Z/` or `../graphical-20261024T000000Z/`.
  Those remain the evidence pair the issue's summary marks superseded once a real run lands; the
  supersede decision belongs to that run, not to this check.
- It is **not** a new evidence set for `PTD-puzzle-stream` or `PTU-puzzle-play`. #550's Description
  forbids re-recording the known `dealt=false` result as one.

**Contents.**

- [`notes.md`](notes.md) — the start condition, what was measured this pass, and what lets the
  sweep start.
- [`logs/import.log`](logs/import.log) — `godot --headless --path game --import --quit`.
- [`logs/x655-probe.log`](logs/x655-probe.log) — the unchanged #655 probe's output on this commit.

Retention follows [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md).
