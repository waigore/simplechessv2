# Headless notes

Acceptance playtest for #374 (client advice streaming) on `origin/main` `e022f83`. Run in a session that posted neither the implementation summary nor the verification comment.

## Scope

#374 changes playable behavior: advice must appear automatically in a Shared game while Advice is On and online. The intersect with `full` coverage is `PTD-move-advice` (Design, headless only; the protocol says no screenshots). UI chrome, `EX.error`, and the UX protocols belong to #375, so no UX protocol is in scope.

## Setup and probe

Prep steps and the probe design: [`setup.md`](setup.md). What actually happened, the root cause, and the judgement: [`results.md`](results.md). Per-story outcomes: [`verdicts.md`](verdicts.md).

## Judgement

Protocol `PTD-move-advice`: **fail**. S1 fails on the shipped path (no best move or eval is produced against a reachable service, and a healthy service is reported offline), so P3 does not hold. S2–S5 and the gate checks pass with the simulated peer; F1 and F2 are not observed. A defect is filed and linked from the acceptance comment.
