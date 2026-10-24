# Protocol: Puzzle play screen

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-puzzle-play`
- **Environment**: Headless and Graphical
- **Cites**: `UI-puzzle-play.US1`, `UI-puzzle-play.US2`, `UI-puzzle-play.US3`, `UI-puzzle-play.US5`
- **Situational tools**: `SIT.4` (Frame time)

## Steps

| ID | Action |
|----|--------|
| S1 | On puzzle-play, move pieces for the required side. |
| S2 | Use reveal if offered; confirm failure UX then next puzzle. |
| S3 | Leave stream with confirm / cancel. |
| S4 | Complete one full move while timing frame times across it. |
| S5 | Read every region on S1 on deal and after a wrong move, a solve, and an abandon. `US2.1`–`US2.9`. |
| S6 | Promote on S4, committing the queen, the rook, then the bishop. `US3.1`, `US3.4`, `US3.8`, `US3.9`. |
| S7 | Place a refused move by tap and by pick-and-drag. `US3.3`, `US3.16`. |
| S8 | Activate every unavailable control in S4 and in S2 confirm. `US3.2`, `US3.5`–`US3.7`, `US3.10`–`US3.12`. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Puzzle controls match `UI-puzzle-play.US1`; leave and reveal confirms match `UI-puzzle-play.US5`. |
| P2 | Headless and Graphical both pass. |
| P3 | The timed move holds 60 fps with no hitch longer than one frame (Performance). |
| P4 | S5 judges `UI-puzzle-play.US2` (`US2.1`–`US2.9`), in both environments. |
| P5 | S6–S8 judge `UI-puzzle-play.US3`: promotion commits the chosen piece, refusal keeps the selection, unavailable controls leave state. Covers `puzzle-play-choices.md#US3` and `puzzle-play-place.md#US3`, in both environments. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Required puzzle controls missing or misrouted | yes |
| F2 | A hitch longer than one frame during the timed move | yes |
| F3 | A `US2` or `US3` scenario fails: a region misreads, a promotion commits wrong, or an unavailable control changes state | yes |

## Evidence

Default evidence rules. Graphical: screenshot puzzle-play, leave confirm, and the promotion choice. `SIT.4` timing samples (device, browser, build id, repeat count) go in `notes.md`; one move sample is not evidence.
