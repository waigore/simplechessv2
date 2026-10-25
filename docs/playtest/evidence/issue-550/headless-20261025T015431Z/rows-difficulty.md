# Headless `20261025T015431Z` — `PTD-difficulty` rows

Protocol verdict: **pass**.

One row per story row the map's protocol view lists, copied from `specs/playtest/traceability/story-protocol/protocols-design.md` and `protocols-ux.md` at `26b07af`, with its outcome and every `not-judged` reason (a bracketed `[not-judged]` cell names the scenario the run could not reach).

| Story row | Outcome | What the run observed |
|---|---|---|
| `difficulty.md#PS1` | pass | Y1 a solve raises Player Elo (991.56 → 1004.58) / Y1 a failure drops Player Elo (1004.58 → 1003.49) / Y1 expected score E = 1 / (1 + 10^((puzzle − player)/400)) (0.240) |
| `difficulty-repeat.md#PS1` | pass | Y-r the in-band candidate set passes over the recent id (["n1"] of [r4, n1]) / recentSolved is trimmed to CFG.ELO_RECENT_WINDOW newest ids (20) |
