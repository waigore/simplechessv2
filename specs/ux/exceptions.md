# Exception States

Authoring rules: [`.agents/specs/rules/ux/exceptions.md`](../../.agents/specs/rules/ux/exceptions.md).

- **Serves**: Instant play; Load time, Reliability, Save durability, Localization (quality); [mode-pick](../design/flows/mode-pick.md) interrupt; [progression.md](../design/progression.md) save-failure.

## Exceptions

| ID | Key | When it appears | Actor sees | Actor can | Blocks the screen | Recovery |
|----|-----|-----------------|------------|-----------|-------------------|----------|
| `EX.loading` | `loading` | Cold open until the board is playable ([quality.md](../definition/quality.md) load time) | Loading message; no mode controls | Wait | yes | Ends on `mode-pick` default when ready |
| `EX.load-failure` | `load_failure`, `reload` | Boot assets fail to resolve on cold open ([`CTR-asset-resolve`](../technical/contracts/asset-resolve.md) E4) | What failed: art could not load; loading gone | Reload the game | yes | Reload loads the game again from the start: Boot assets, then `mode-pick` or this row |
| `EX.confirm` | `confirm`, `cancel` | Destructive or hard-to-undo choice: quit, resign, offer a draw, abandon puzzle, leave stream, reveal | Confirm and Cancel; names the action | Confirm or Cancel | yes | Confirm runs it; Cancel returns to the prior state |
| `EX.promote` | `choose_promotion`, `queen`, `rook`, `bishop`, `knight` in `shared-play` and `puzzle-play` | A legal pawn place is on the last rank ([I33](../design/entities/pieces/pawn.md)) | Queen, rook, bishop, then knight sprites of that color at the destination, upright for the side to move | Tap one sprite to commit that type, or `IN.deselect` to drop the choice and keep the pawn selected | no | Commit completes the place; drop returns to the selected pawn; the clock keeps running |
| `EX.rejected` | `shared-play.refused_place`, `puzzle-play.refused_place` | A place the rules refuse ([I11](../design/entities/pieces/common.md), [K2](../design/loops/two-player-game.md)) | Danger flash on the attempted square ([PER.R8](../view/perception.md)); selection, legal marks, position stay | Try another square or clear the selection at once | no | The flash ends on the same screen. No Dismiss; the clock keeps running |
| `EX.draw-offer` | `shared-play.draw_offered`, `shared-play.accept`, `shared-play.decline`, `shared-play.withdraw` | The side to move confirmed a draw offer ([END.D2](../design/end-conditions/conditions.md)) | Draw offered, with Accept, Decline, Withdraw | Accept, Decline, or Withdraw; the side to move may also move | no | Accept commits [END.D2](../design/end-conditions/conditions.md); Decline, Withdraw, or a move lapses it, same side to move, clock still running |
| `EX.interrupt` | none | Close, refresh, or reopen during play ([mode-pick U1](../design/flows/mode-pick.md)) | Next open is mode pick (no resume) | Use mode pick | n/a (new open) | Arrives at `mode-pick` |
| `EX.save-failure` | `puzzle-play.save_failed`, `puzzle-play.dismiss` | Failed save of Player Elo or Last mode ([quality.md](../definition/quality.md) save durability) | Save failed; prior values kept | Dismiss; continue | no | Previous commit intact |
| `EX.error` | `shared-play.advice_error`, `shared-play.dismiss` | Recoverable failure (e.g. Advice fetch while On) | What failed | Dismiss | no | Local moves never wait |
| `EX.unsupported-input` | `unsupported_input` | Non-touch primary input on Web | Input not supported | Use touch | no | Switch to touch |

The Key column is the copy source of the `exceptions` owner ([localization.md](localization.md)): a bare key is an `exceptions` key; `owner.key` cites a screen key.
