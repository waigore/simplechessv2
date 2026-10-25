# #550 start-condition check — 2026-10-25T23:53Z, parallel id 2

**What this folder is.** A measurement of #550's documented hard start condition on
`origin/main` `05521ca`, so the reason the wave-2 sweep still does not start lives in the tree and
not only in an issue comment. It was written by an unattended
`issue-workflow-implement-agent` pass ([`workflow-dispatch.md`](../../../../../docs/issues/workflow-dispatch.md)).

**What this folder is not.**

- It is **not** a sweep. It has no `manifest.md`, no story rows, and no protocol verdicts.
- It does **not** supersede `../headless-20261024T000000Z/` or `../graphical-20261024T000000Z/`.
  The supersede decision belongs to the run that actually replaces them.
- It is **not** a new evidence set for `PTD-puzzle-stream` or `PTU-puzzle-play`. #550's Description
  forbids re-recording the known `dealt=false` result as one.
- It does not edit or replace `../start-check-20261025T-par2/`, the earlier pass's record of the
  same check on an older commit.

**Contents.**

- [`notes.md`](notes.md) — the start condition, what was measured this pass, and what lets the
  sweep start.
- [`logs/import.log`](logs/import.log) — `godot --headless --path game --import --quit` (run from
  `game/`).
- [`logs/x655-probe.log`](logs/x655-probe.log) — the unchanged #655 probe's output on this commit.

Retention follows [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md).
