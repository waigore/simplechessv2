# Exception States

Authoring rules: [`.agents/specs/rules/ux/exceptions.md`](../../.agents/specs/rules/ux/exceptions.md).

- **Serves**: Instant play; Load time, Reliability, Save durability, Localization (quality); [mode-pick](../design/flows/mode-pick.md) interrupt; [progression.md](../design/progression.md) save-failure.

## Exceptions

| ID | Key | When it appears | Actor sees | Actor can | Blocks the screen | Recovery |
|----|-----|-----------------|------------|-----------|-------------------|----------|
| `EX.loading` | `loading` | Cold open until the board is playable ([quality.md](../definition/quality.md) load time) | Loading message; no mode controls yet | Wait | yes | Ends on `mode-pick` default when ready |
| `EX.confirm` | `confirm`, `cancel` | Destructive or hard-to-undo choice: quit session, resign, offer a draw, abandon puzzle, leave stream, reveal solution | Confirm and Cancel; names the action | Confirm or Cancel | yes | Confirm runs the action; Cancel returns to the prior screen state |
| `EX.promote` | `choose_promotion`, `queen`, `rook`, `bishop`, `knight` in `shared-play` and `puzzle-play` | A legal pawn place is on the last rank ([I33](../design/entities/pieces/pawn.md)) | Queen, rook, bishop, then knight sprites of that color at the destination, upright for the side to move | Tap one sprite to commit that type, or `IN.deselect` to drop the choice and leave the pawn selected | no | Commit completes the place; drop returns to the selected pawn. A running shared-game clock keeps running |
| `EX.rejected` | `shared-play.refused_place`, `puzzle-play.refused_place` | A place the piece rules refuse ([I11](../design/entities/pieces/common.md), [K2](../design/loops/two-player-game.md)) | A short danger flash on the attempted square ([PER.R8](../view/perception.md)). Selection, legal marks, and position stay | Try another square or clear the selection at once | no | The flash ends on the same screen. No Dismiss. The running clock keeps running |
| `EX.draw-offer` | `shared-play.draw_offered`, `shared-play.accept`, `shared-play.decline`, `shared-play.withdraw` | The side to move confirmed a draw offer ([END.D2](../design/end-conditions/conditions.md)) | One shared panel: Draw offered, with Accept, Decline, and Withdraw | Accept, Decline, or Withdraw; the side to move may also move | no | Accept commits [END.D2](../design/end-conditions/conditions.md). Decline, Withdraw, or a move by the side to move lapses the offer and returns to play, same side to move, that clock still running |
| `EX.interrupt` | none | Close, refresh, or reopen during Shared play or Puzzle play ([mode-pick U1](../design/flows/mode-pick.md)) | Next open is mode pick (no mid-game resume) | Use mode pick | n/a (new open) | Arrives at `mode-pick` |
| `EX.save-failure` | `puzzle-play.save_failed`, `puzzle-play.dismiss` | Failed commit of Player Elo or Last mode ([quality.md](../definition/quality.md) save durability) | Save failed; prior values kept | Dismiss; continue | no | Dismiss; previous commit intact |
| `EX.error` | `shared-play.advice_error`, `shared-play.dismiss` | Recoverable failure (e.g. Advice fetch while On) | What failed; play may continue | Dismiss | no | Dismiss; local moves never wait |
| `EX.unsupported-input` | `unsupported_input` | Non-touch primary input on Web | Input not supported for play | Use touch | no | Switch to touch; control unchanged |

The Key column is the copy source of the `exceptions` owner ([localization.md](localization.md)): a bare key is a new `exceptions` key, and `owner.key` cites a screen key.
