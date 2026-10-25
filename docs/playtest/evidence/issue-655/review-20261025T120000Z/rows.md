# #550 rows this run changes

Read against [`issue-550/headless-20261024T000000Z/manifest.md`](../../issue-550/headless-20261024T000000Z/manifest.md).

| Row | Was | Now |
|-----|-----|-----|
| `PTD-puzzle-stream` S1/P1 (K1) | fail — `dealt=false`, `T9`/`T10` empty (#655) | **fail** on the shipped configuration: nothing dealt. The reason is now `unconfigured` (`B5`'s empty-value guard), so the row still cites #655 and no longer reads as a transport failure. |
| `PTU-puzzle-play` US1 | fail — no puzzle open | **fail**, unchanged — no build can deal until #479 delivers the pair |
| `PTU-puzzle-session` S2–S3 leave | judged in the graphical twin | **pass** — `C5` on `S1` with no puzzle open raises `leave_confirm`; Cancel returns to `S1` |
| `PTU-puzzle-session` verdict | pass (entry; leave in twin) | **pass** — entry and leave both observed headless |

Its `Defects` line still names #655.
