# Screen: Puzzle play

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Play the Puzzle stream
- **Actors**: [`bottom-player.md`](../actors/bottom-player.md), [`top-player.md`](../actors/top-player.md)
- **Serves**: Instant play, Cafe calm, Accessibility; [puzzle-stream](../../design/loops/puzzle-stream.md)
- **Mockup**: [`../mockups/screens/puzzle-play.html`](../mockups/screens/puzzle-play.html)
- **Glossary terms**: [Board coordinates](../glossary.md); [Player Elo](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | `GS.position` | puzzle open |
| R1 | Board coordinates (a–h, 1–8) | always, edges |
| R1 | `GS.selectedPiece` | piece selected |
| R2 | `GS.playerElo` | always |
| R2 | Puzzle result cue | after [W1, L4–L6](../../design/end-conditions/conditions.md), before next deal |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Board | Puzzle position | 8×8; edge coords; selection and legal marks; `IN.deselect` clears selection |
| R2 | Status | Rating, feedback | Elo; result cues |
| R3 | Stream actions | Reveal, abandon, leave | R3's three controls |

## Controls

C1–C6 are in [`puzzle-play-controls.md`](puzzle-play-controls.md), the focus order.

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | In stream | R1–R3 | All controls |
| S2 | `EX.confirm` | C3–C5 | Named confirm | Confirm acts; Cancel → S1 |
| S3 | `EX.save-failure` | Elo persist failed | Save-failure | Dismiss |
| S4 | `EX.promote` | Legal pawn place on last rank | Q/R/B/N sprites, in order | C6; `IN.deselect` keeps pawn |
| S5 | `EX.rejected` | Illegal place | Danger flash ([PER.R8](../../view/perception.md)); selection stays | C1–C5 |

## Copy

All keys vary by locale (`en`, `zh-Hant`, `ja`) except the six piece-type names (L7), identical in every locale, never drawn, and the pieces' accessible names ([R7](../../technical/components/presentation.md)).

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
| cue_solved | Solved | R2 (END.W1) |
| cue_wrong | Wrong move | R2 |
| cue_failed | Failed | R2 (END.L4, END.L5) |
| cue_abandon | Abandoned | R2 (END.L6) |
| choose_promotion | Choose promotion | S4 |
| refused_place | Refused place | S5 |
| pawn | Pawn | R1 |
| king | King | R1 |
| queen | Queen | R1, C6 |
| rook | Rook | R1, C6 |
| bishop | Bishop | R1, C6 |
| knight | Knight | R1, C6 |

## Experience intent

Untimed calm practice; leaving never punishes an open puzzle. Pieces read by shape, not color.
