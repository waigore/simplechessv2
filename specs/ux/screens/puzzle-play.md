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
| R2 | Puzzle result cue | after solve / fail / abandon before next deal |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Board | Puzzle position | 8×8; edge coordinates; selection and legal marks; C1/C2 tap squares |
| R2 | Elo and status | Rating and feedback | Player Elo; wrong-move / solved cues |
| R3 | Stream actions | Reveal, abandon, leave | Reveal, Abandon, Leave stream |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Select piece | `IN.select` | puzzle open; not in confirm | Sets selection |
| C2 | Place move | `IN.move` | selection set | Asks puzzle move / wrong-move handling |
| C3 | Reveal | `IN.activate` | puzzle open | → `EX.confirm` reveal |
| C4 | Abandon | `IN.activate` | puzzle open | → `EX.confirm` abandon |
| C5 | Leave stream | `IN.activate` | always | → `EX.confirm` leave → `mode-pick` (NAV.T9) |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | In stream | R1–R3 | C1–C5 |
| S2 | `EX.confirm` | C3, C4, or C5 | Named confirm | Confirm runs action; Cancel → S1 |
| S3 | `EX.save-failure` | Elo persist failed | Save-failure | Dismiss → S1 |

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

## Experience intent

Untimed calm practice; leave without punishing an open puzzle; coordinates keep orientation clear. Meets Accessibility: pieces read by shape; no status by color alone; 44px-class touch targets.
