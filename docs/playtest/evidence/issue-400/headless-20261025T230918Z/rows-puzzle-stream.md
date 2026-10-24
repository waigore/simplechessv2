# #400 headless-20261025T230918Z — `puzzle-stream` rows

One row per cited story row, with the outcome and its `not-judged` reason.

| `puzzle-stream` | `loops/puzzle-stream.md#PS1` | pass | K1/R1–R2 mode pick defaults to Shared, dealt w400i / R3 snapshot presented (side black, rating 1040) / K3 sequence completes → END.W1, Elo 994.88 → 1006.17, one deal owed / R4 mateIn1 record opened (true) / K2 wrong move keeps the same puzzle (w400k, SS1, puzzle.wrong rows 1 → 2), no deal / K3 a second, correct attempt scores END.L4 (retryable, puzzle.wrong rows 1 → 2) / W2.2 reveal → END.L5 (results 7 → 8) / W2.3 abandon → END.L6 (results 8 → 9, S = 0) / K4/E1 leave unscored, Elo kept (979.84) |
| `puzzle-stream` | `loops/puzzle-stream-advance.md#PS1` | pass | next deal after the settled attempt (w400j) |
| `puzzle-stream` | `features/puzzle-catalog.md#PS1` | pass | X2 the playtest peer stands in for the catalog (seams peer true, unset default endpoint true) / B5 the shipped build configures no catalog endpoint; the playtest peer answered |
| `puzzle-stream` | `features/puzzle-catalog-select.md#PS2` | pass | I1 window match deals the in-band record ({ "ok": true, "puzzle_id": "near", "rating": 1510 }) / I1 recent ids are passed over (["fresh"] of [near, fresh]) / D1 a deal outside the window widens by CFG.ELO_BAND_WIDEN ({ "ok": true, "puzzle_id": "wide", "rating": 1700 }) / X1 a one-move record deals nothing and keeps Elo (1006.17) / X2 an unreadable record deals nothing and keeps Elo |
| `puzzle-stream` | `scenarios/puzzle-stream-visit.md#PS1` | pass | W1.1–W2.4 one visit: C2 → deal (true) → play (true) → leave → mode-pick, Elo 979.84 |
