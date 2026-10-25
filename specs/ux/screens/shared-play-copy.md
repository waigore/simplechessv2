# Screen: Shared play copy

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

Part of [`shared-play.md`](shared-play.md). Literal actor-facing strings for `UI-shared-play`.

- **Job, Actors, Serves, Mockup, Glossary terms**: see [`shared-play.md`](shared-play.md).

## Shows

N/A — [`shared-play.md`](shared-play.md).

## Regions

N/A — [`shared-play.md`](shared-play.md).

## Controls

N/A — [`shared-play-controls.md`](shared-play-controls.md).

## States

N/A — [`shared-play-states.md`](shared-play-states.md).

## Copy

All keys below vary by locale (`en`, `zh-Hant`, `ja`), except `queen`, `rook`, `bishop`, and `knight`, which stay the `en` value in every locale ([L3](../localization.md)).

| Key | String | Used in |
|-----|--------|---------|
| advice_on | Advice On | C3 |
| advice_off | Advice Off | C3 |
| resign | Resign | C4 |
| resign_confirm | Resign this game? | S2 |
| offer_draw | Offer draw | C5 |
| offer_confirm | Offer a draw? | S2 |
| accept | Accept | C7 |
| decline | Decline | C8 |
| withdraw | Withdraw | C9 |
| draw_offered | Draw offered | S6 |
| confirm | Confirm | S2 |
| cancel | Cancel | S2 |
| advice_error | Advice unavailable. Play continues. | S3 |
| dismiss | Dismiss | S3 |
| white_to_move | White to move | R2 |
| black_to_move | Black to move | R2 |
| check | Check | R2 |
| choose_promotion | Choose promotion | S4 |
| refused_place | Refused place | S5 |
| queen | Queen | C6 |
| rook | Rook | C6 |
| bishop | Bishop | C6 |
| knight | Knight | C6 |

Copy owner `shared-play`; keys and `en` source per [localization.md](../localization.md) L1. Strings resolve through the locale's string table ([`CTR-localization`](../../technical/contracts/localization.md)) (A1).

## Experience intent

N/A — [`shared-play.md`](shared-play.md).
