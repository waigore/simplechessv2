# Protocol: Shared play screen

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-shared-play`
- **Environment**: Headless and Graphical
- **Cites**: `UI-shared-play.US1`, `UI-shared-play.US2`, `UI-shared-play.US3`, `UI-shared-play.US4`, `ACT-bottom-player.US1`, `ACT-top-player.US1`
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
| S7 | Offer, answer, and withdraw a draw on S1 and S6; dismiss an advice error on S3. `US3.1`, `US3.2`, `US3.5`, `US3.7`, `US3.9`, `US3.12`, `US3.15`, `US3.17`. |
| S8 | Promote on S4 with the knight and the queen, then try `C6` where no promotion is open. `US3.3`, `US3.4`. |
| S9 | Place a refused move, place by pick-and-drag, and let a move lapse the offer. `US3.11`, `US3.13`, `US3.14`, `US3.16`. |
| S10 | On S2 confirm, S4 promotion, and S6 draw offer, activate each unavailable control and read the state. `US4.1`–`US4.13`. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Both seats can operate when it is their turn; resign confirm works. |
| P2 | Headless and Graphical both pass. |
| P3 | The timed move holds 60 fps with no hitch longer than one frame (Performance). |
| P4 | Story IDs, outcomes, and errors appear in the captured logs for every judged story (Observability). |
| P5 | S7 and S8 judge `UI-shared-play.US3` choices: draw controls, promotion, and advice-error dismiss; with P6 they cover `shared-play-choices.md#US3` and `shared-play-place.md#US3`. |
| P6 | S9 judges `UI-shared-play.US3` place: refused place, promotion shown, lapsed offer, pick-and-drag. |
| P7 | S10 judges `UI-shared-play.US4` (`US4.1`–`US4.13`): state and position hold. P5–P7 hold in Headless and Graphical. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Seat cannot move on its turn or resign skips confirm | yes |
| F2 | A hitch longer than one frame during the timed move | yes |
| F3 | A judged story has no correlating `TEL.*` event | yes |
| F4 | A `US3` or `US4` scenario fails: a draw control misfires, a promotion commits wrong, or an unavailable control changes state | yes |

## Evidence

Default evidence rules. Graphical: screenshot play, resign confirm, the draw offer, and one unavailable control. `SIT.4` reports carry device, browser, build id, and repeat count ([`evidence-manifest.md`](../evidence-manifest.md)); one move sample is not evidence. `SIT.5` cites the log window it read.
