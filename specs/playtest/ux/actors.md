# Protocol: Actors

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-actors`
- **Environment**: Headless and Graphical
- **Cites**: `ACT-bottom-player.US2`, `ACT-bottom-player.US3`, `ACT-bottom-player.US4`, `ACT-bottom-player.US5`, `ACT-top-player.US2`, `ACT-top-player.US3`, `ACT-top-player.US4`
- **Situational tools**: None

Steps copy each scenario's givens; the two seats do not carry the same ranges.

## Steps

| ID | Action |
|----|--------|
| S1 | On `shared-play`, each actor offers, withdraws, accepts, and declines a draw, and clears with `IN.deselect`. `US2.1`–`US2.6`. |
| S2 | Off turn, each actor tries offer, clear, promote, resign. `US2.7`–`US2.10`. |
| S3 | As host, offer a draw, resign with confirm, then resign. `US2.1`, `US5.1`, `US5.2`. |
| S4 | Each actor works the host controls from `mode-pick`, `shared-setup`, and `shared-result`. Bottom: `US3.1`–`US3.8`. Top: `US3.1`–`US3.12`, whose three extra steps are Mode pick, Start, and Play again. |
| S5 | On `puzzle-play`, the acting actor selects, places, abandons, leaves with confirm, and promotes (`US4.2`–`US4.6`); Top also reveals (`US4.1`). Either actor Stops from `shared-result` (`US4.1`). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | S1–S3 judge `ACT-bottom-player.US2`, `ACT-top-player.US2`, `ACT-bottom-player.US5`. |
| P2 | S4 judges `ACT-bottom-player.US3` (`US3.1`–`US3.8`) and `ACT-top-player.US3` (`US3.1`–`US3.12`). |
| P3 | S5 judges `ACT-bottom-player.US4` and `ACT-top-player.US4`, each `US4.1`–`US4.6`, with `US4.1` covering Reveal for Top and Stop for either seat. |
| P4 | Headless and Graphical both pass; Graphical screenshots each judged state. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A cited scenario fails in either seat | yes |
| F2 | A seat reaches fewer scenarios than its own headings list | yes |

## Evidence

Default evidence rules. Graphical: screenshot the draw offer, one unavailable control, and Stop from result.
