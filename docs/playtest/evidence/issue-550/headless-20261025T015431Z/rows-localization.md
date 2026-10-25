# Headless `20261025T015431Z` — `PTU-localization` rows

Protocol verdict: **not-judged**.

One row per story row the map's protocol view lists, copied from `specs/playtest/traceability/story-protocol/protocols-design.md` and `protocols-ux.md` at `26b07af`, with its outcome and every `not-judged` reason (a bracketed `[not-judged]` cell names the scenario the run could not reach).

| Story row | Outcome | What the run observed |
|---|---|---|
| `screens/mode-pick.md#US1` | pass | US1.9 first C4 → locale zh-Hant, R3 繁體中文 / FAIL.T13 misses in run log: true |
| `screens/mode-pick-unavailable.md#US1` | pass | — |
| `localization.md#US1` | not-judged | LOC.US1.3 title/shared/puzzle differ; locale own names 繁體中文 日本語 / LOC.US1.2 own-name row reads its own name / LOC.US1.2 S2 five screens × 3 locales: every string is its Copy-table value / LOC.US1.3 S3 piece-name rows stay the en value in every locale (queen reads ["Queen", "Queen", "Queen"]) / LOC.US1.2 S2 `shared-play` advice_on/advice_off/advice_error in three locales: each reads its Copy-table value / [not-judged] LOC.US1.1 key names are a spec review |
| `localization.md#US2` | none — `LOC.US2` is out of playtest scope; judged by spec read | [#788](https://github.com/waigore/simplechessv2/issues/788) |
