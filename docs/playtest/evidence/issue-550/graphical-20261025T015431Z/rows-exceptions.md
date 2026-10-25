# Graphical `20261025T015431Z` — `PTU-exceptions` rows

Protocol verdict: **not-judged**.

One row per story row the map's protocol view lists, copied from `specs/playtest/traceability/story-protocol/protocols-design.md` and `protocols-ux.md` at `26b07af`, with its outcome and every `not-judged` reason (a bracketed `[not-judged]` cell names the scenario the run could not reach).

| Story row | Outcome | What the run observed |
|---|---|---|
| `exceptions.md#US1` | not-judged | US1.7 confirm shown on resign / US1.2 confirm cancel / US1.3/1.15 interrupt: cold boot returns mode-pick (log) / US1.4/US1.16 failed write of Player Elo + Last mode shows EX.save-failure (S3, committed false); earlier commit kept (Elo 1001.97) / US1.4 Dismiss continues the sitting (SS1) / [not-judged] US1.6 unsupported input needs a non-touch Web device |
| `exceptions-play.md#US1` | not-judged | US1.10 rejected place / US1.11 flash ends / US1.12 draw offer answered by Decline (C8) returns to S1 (SS6 → SS1, offer '') / [not-judged] US1.8/1.9 promotion needs a crafted position |
