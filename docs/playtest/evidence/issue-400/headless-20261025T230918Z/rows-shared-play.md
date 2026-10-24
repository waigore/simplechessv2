# #400 headless-20261025T230918Z — `shared-play` rows

One row per cited story row, with the outcome and its `not-judged` reason.

| `shared-play` | `screens/shared-play.md#US1` | pass | US1.2 C1 on e2 → selectedPiece e2 / US1.3 C2 e2→e4 placed, selection cleared / US1.10 C10 clears selection / US1.4 C3 toggles advice true → false / US1.1/1.6 C4 → SS2 resign confirm / US1.8 Cancel resign → SS1 / US1.9 resign end → shared-result / US1.5 Blitz shows a running clock (W 0:59 · B 1:00) / US1.7 Advice Off visible in play chrome |
| `shared-play` | `screens/shared-play-regions.md#US2` | pass | US2.1/2.2 board renders GS.position (e1 = { "color": "white", "kind": "king" }) / US2.4 White to move shown / US2.6 no clock when Untimed / US2.3/2.10 selection + 2 legal marks on d2 / US2.9 no advice marks when unset |
| `shared-play` | `screens/shared-play-choices.md#US3` | pass | US3.1/3.12 offer confirm opens SS2 (offer) / US3.12 C5 while S2 does not open a second confirm / US3.15 offer panel after Confirm (SS6, drawOffer white, panel true) / US3.7 decline → SS1, offer  / US3.9 withdraw → SS1, offer  / US3.5 accept ends game (shared-result) |
| `shared-play` | `screens/shared-play-place.md#US3` | not-judged | US3.11 refused place → SS5, selection kept (e2) [squares e2 → e2, place returned false] / US3.16 pick-and-drag place asked / US3.13 promotion-shown and US3.14 lapsed offer need a last-rank pawn not reachable in this run |
| `shared-play` | `screens/shared-play-unavailable.md#US4` | not-judged | US4.1/4.13 C1/C10 in S2 refused / US4.2 C2 in S2 no place / US4.3 C3 in S2 / US4.4 C4 in S2 / US4.5 C5 in S2 / US4.6–4.8 C7/C8/C9 without an offer stay S1 (["S1", "S1", "S1"]) / US4.11 C4 in S6 refused (SS6 → SS6) / US4.12 C5 in S6 refused (SS6) / US4.9/4.10 need S4 (promotion) not reachable in this run |
| `shared-play` | `actors/bottom-player.md#US1` | pass | US1.6 Bottom selects its own piece on e2 / US1.5 place |
| `shared-play` | `actors/top-player.md#US1` | pass | US1.11 no select off turn (Top cannot select White on Black's turn) / US1.1 select on Top turn (e7) / US1.2 place on Top turn (e7 → e5) / US1.4 advice toggle path |
