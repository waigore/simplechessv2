# Screen: Puzzle play

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Play the continuous Puzzle stream
- **Actors**: [`bottom-player.md`](../actors/bottom-player.md)
- **Serves**: Instant play, Cafe calm, Accessibility; [puzzle-stream](../../design/loops/puzzle-stream.md)
- **Mockup**: [`../mockups/screens/puzzle-play.html`](../mockups/screens/puzzle-play.html)
- **Glossary terms**: [Board coordinates](../glossary.md); [Player Elo](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | `GS.position` | puzzle open |
| R1 | Board coordinates (a–h, 1–8) | always — edges only |
| R1 | `GS.selectedPiece` | piece selected |
| R2 | `GS.playerElo` | always |
| R2 | Puzzle result cue | after solve or fail ([W1, L4–L6](../../design/end-conditions/conditions.md)) before next deal |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Board | Puzzle position | 8×8; edge coordinates; selection and legal marks. `IN.deselect` clears the selection |
| R2 | Elo and status | Rating and feedback | Player Elo; wrong-move / solved cues |
| R3 | Stream actions | Reveal, abandon, leave | Reveal, Abandon, Leave stream |

## Controls

C1–C6 are in [`puzzle-play-controls.md`](puzzle-play-controls.md). Focus order is that table.

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | In stream | R1–R3 | C1–C5 |
| S2 | `EX.confirm` | C3, C4, or C5 | Named confirm | Confirm runs action; Cancel → S1 |
| S3 | `EX.save-failure` | Elo persist failed | Save-failure | Dismiss; C1–C5 usable |
| S4 | `EX.promote` | Legal pawn place on the last rank | Queen, rook, bishop, knight sprites at that square, that order | C6. `IN.deselect` drops the choice and leaves the pawn selected |
| S5 | `EX.rejected` | Place the piece rules refuse | Danger flash on that square ([PER.R8](../../view/perception.md)); selection stays | C1–C5 as S1. No Dismiss |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| elo | Elo | R2 |
| reveal | Reveal | C3 |
| abandon | Abandon | C4 |
| leave | Leave stream | C5 |
| reveal_confirm | Reveal the solution? | S2 |
| abandon_confirm | Abandon this puzzle? | S2 |
| leave_confirm | Leave the puzzle stream? | S2 |
| confirm | Confirm | S2 |
| cancel | Cancel | S2 |
| save_failed | Save failed. Prior Elo kept. | S3 |
| dismiss | Dismiss | S3 |
| cue_solved | Solved | R2 |
| cue_wrong | Wrong move | R2 |
| cue_abandon | Abandoned | R2 |
| choose_promotion | Choose promotion | S4 |
| refused_place | Refused place | S5 |
| queen | Queen | C6 |
| rook | Rook | C6 |
| bishop | Bishop | C6 |
| knight | Knight | C6 |

## Experience intent

Untimed calm practice; leave without punishing an open puzzle; coordinates keep orientation clear. Meets Accessibility: pieces read by shape; no status by color alone; 44px-class touch targets.
