# Headless `20261025T015431Z` — `PTD-pieces-common` rows

Protocol verdict: **not-judged**.

One row per story row the map's protocol view lists, copied from `specs/playtest/traceability/story-protocol/protocols-design.md` and `protocols-ux.md` at `26b07af`, with its outcome and every `not-judged` reason (a bracketed `[not-judged]` cell names the scenario the run could not reach).

| Story row | Outcome | What the run observed |
|---|---|---|
| `entities/pieces.md#PS1` | pass | e2 pawn White / Pawn / S1 ({ "color": "white", "kind": "pawn" }) / orthodox back rank R N B Q K B N R (seen ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]) |
| `entities/pieces/common.md#PS1` | pass | I4 friendly destination illegal |
| `entities/pieces/common-legality.md#PS1` | pass | I11 only side to move |
| `entities/pieces/common-attack.md#PS2` | not-judged | [not-judged] I5/I6 attacked-square rows need crafted positions |
