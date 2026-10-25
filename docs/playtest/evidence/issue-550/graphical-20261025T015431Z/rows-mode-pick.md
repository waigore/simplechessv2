# Graphical `20261025T015431Z` — `PTU-mode-pick` rows

Protocol verdict: **pass**.

One row per story row the map's protocol view lists, copied from `specs/playtest/traceability/story-protocol/protocols-design.md` and `protocols-ux.md` at `26b07af`, with its outcome and every `not-judged` reason (a bracketed `[not-judged]` cell names the scenario the run could not reach).

| Story row | Outcome | What the run observed |
|---|---|---|
| `screens/mode-pick.md#US1` | pass | S1 shows Title/Shared/Puzzle/Quit/locale / US1.3 C1 → shared-setup / US1.4 C2 → puzzle-play / US1.5/1.7 C3 → S3, Cancel → S1 / US1.8 save-failure → S4, Dismiss → S1 / S6 phone-width viewport 390×844: body text 21.0 px (UIS.T2 ≥ 16 at a 640 px frame; frame height 844.0) |
| `screens/mode-pick-unavailable.md#US1` | pass | US1.10 C1 unavailable in S3 (ui_state S3, stage mode-pick) / US1.11 C2 unavailable in S3 (ui_state S3, stage mode-pick) / US1.13 C4 does not switch locale in S3 (locale en → en, stage mode-pick) / US1.12 no second confirm / US1.14 Confirm ends session / US1.15 S4 keeps S1 controls available (Dismiss → S1) |
