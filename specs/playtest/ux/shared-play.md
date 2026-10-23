# Protocol: Shared play screen

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-shared-play`
- **Environment**: Headless and Graphical
- **Cites**: `UI-shared-play.US1`, `UI-shared-play.US2`, `ACT-bottom-player.US1`, `ACT-top-player.US1`
- **Situational tools**: `SIT.4` (Performance), `SIT.5` (Observability)

## Steps

| ID | Action |
|----|--------|
| S1 | As Bottom, select and move when Bottom is side to move. |
| S2 | As Top seat, select and move when Top is side to move (same device). |
| S3 | Toggle Advice if present; resign flow with confirm. |
| S4 | Confirm coordinates / advice affordances per screen story. |
| S5 | Complete one full local move while timing frame times across it. |
| S6 | Assert the run's captured logs carry `TEL.1`–`TEL.5` for the shared-play stories judged, with their IDs. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Both seats can operate when it is their turn; resign confirm works. |
| P2 | Headless and Graphical both pass. |
| P3 | The timed move holds 60 fps with no hitch longer than one frame (Performance). |
| P4 | Story IDs, outcomes, and errors appear in the captured logs for every judged story (Observability). |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Seat cannot move on its turn or resign skips confirm | yes |
| F2 | A hitch longer than one frame during the timed move | yes |
| F3 | A judged story has no correlating `TEL.*` event | yes |

## Evidence

Default evidence rules. Graphical: screenshot play and resign confirm. `SIT.4` reports carry device, browser, build id, and repeat count ([`evidence-manifest.md`](../evidence-manifest.md)); one move sample is not evidence. `SIT.5` cites the log window it read.
