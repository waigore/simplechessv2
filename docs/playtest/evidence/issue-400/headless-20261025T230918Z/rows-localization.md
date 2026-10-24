# #400 headless-20261025T230918Z — `localization` rows

One row per cited story row, with the outcome and its `not-judged` reason.

| `localization` | `screens/mode-pick.md#US1` | pass | US1.9 first C4 → locale zh-Hant, R3 繁體中文 / FAIL.T13 misses in run log: true |
| `localization` | `screens/mode-pick-unavailable.md#US1` | pass | S3 quit confirm does not block C1/C2/C4 (US1.10, US1.11, US1.13) |
| `localization` | `localization.md#US1` | not-judged | LOC.US1.3 title/shared/puzzle differ; locale own names 繁體中文 日本語 / LOC.US1.2 own-name row reads its own name / LOC.US1.2 S2 five screens × 3 locales: every string is its Copy-table value / LOC.US1.3 S3 piece-name rows stay the en value in every locale (queen reads ["Queen", "Queen", "Queen"]) / LOC.US1.1 key names are a spec review |
| `localization` | `localization.md#US2` | none — LOC.US2 is out of playtest scope; judged by spec read | [#788](https://github.com/waigore/simplechessv2/issues/788) |
