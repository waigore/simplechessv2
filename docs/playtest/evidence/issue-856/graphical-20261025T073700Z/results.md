# Story rows

Protocol verdict: **pass** on the judged steps (S1, `P4`). S2–S6 are `not-judged` here;
readings are in [`readings.md`](readings.md).

| Story row | Outcome | What the run observed |
|---|---|---|
| `screens/mode-pick.md#US1` — S1 cold open: `EX.loading` start → mode pick interactive within 3 s (`P4`, `UI-mode-pick.S2` → `S1`, `US1.6`) | **pass** | `ENV.2`, published release: mode pick painted at 1811 / 1857 / 1876 / 2039 ms, 4/4 under 3 s. Fix export: 844 / 883 / 1032 / 1053 ms. `EX.loading` screenshotted with no mode control reachable, and a tap on the mode band during it does not route (`screenshots/*-s1-loading-600ms.png`, `logs/*-drive.json`) |
| `screens/mode-pick.md#US1` — S1 warm open within 3 s (`P4`) | **pass** | `ENV.2`: published 1254 ms; base export 901 ms; fix export 653 ms |
| `screens/mode-pick.md#US1` — S2–S6 (mode entries, Last mode, locale switch, phone-width text) | not-judged | Out of this defect's deliverable; the #400 sweep judges S2–S5 and #546 owns S6. The drive did reach Shared game setup and puzzle stream, which is logged but not claimed as a row verdict |
| `screens/mode-pick-unavailable.md#US1` | not-judged | Not driven; #400 owns it |

The story row is judged on its S1 timing only; every other scenario cell of `US1` is
`not-judged` with the #400 sweep named as owner.
