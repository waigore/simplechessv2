# Results — `PTU-mode-pick` S1 / `P4` on #856's builds

Protocol verdict: **pass** on the judged steps (S1, `P4`). S2–S6 are `not-judged` here.

## Story rows

| Story row | Outcome | What the run observed |
|---|---|---|
| `screens/mode-pick.md#US1` — S1 cold open: `EX.loading` start → mode pick interactive within 3 s (`P4`, `UI-mode-pick.S2` → `S1`, `US1.6`) | **pass** | `ENV.2`, published release: mode pick painted at 1811 / 1857 / 1876 / 2039 ms, 4/4 under 3 s. Fix export (`79d5780`, carries #877): 844 / 883 / 1032 / 1053 ms. `EX.loading` screenshotted with no mode control reachable, and a tap on the mode band during it does not route (`screenshots/*-s1-loading-600ms.png`, `logs/*-drive.json`) |
| `screens/mode-pick.md#US1` — S1 warm open within 3 s (`P4`) | **pass** | `ENV.2`: published 1254 ms; base export 901 ms; fix export 653 ms |
| `screens/mode-pick.md#US1` — S2–S6 (mode entries, Last mode, locale switch, phone-width text) | not-judged | Out of this defect's deliverable; the #400 sweep judges S2–S5 and #546 owns S6. The drive did reach Shared game setup and puzzle stream from mode pick, which is logged here but not claimed as a row verdict |
| `screens/mode-pick-unavailable.md#US1` | not-judged | Not driven; #400 owns it |

The story row is judged on its S1 timing only; every other scenario cell of `US1` is
`not-judged` with the #400 sweep named as owner.

## Per-run readings

Page-clock milliseconds, one page load each, HTTP cache disabled, one fresh profile per cold
run. `panel` is the first animation frame whose readback of the mode-pick control band is
non-blank; `FCP` is `PerformancePaintTiming` first-contentful-paint.

| Arm | Renderer | Open | panel (ms) | FCP (ms) | first WebGL2 context (ms) |
|---|---|---|---|---|---|
| published release `69a03d4` | hardware Metal | cold ×4 | 1811 / 1857 / 1876 / 2039 | 1816 / 1860 / 1880 / 2044 | 185 / 229 / 198 / 202 |
| published release `69a03d4` | hardware Metal | warm ×1 | 1254 | 1256 | 224 |
| base export `69a03d4` | hardware Metal | cold ×4 | 1442 / 1225 / 1257 / 1222 | 1448 / 1228 / 1260 / 1224 | 15 / 10 / 15 / 11 |
| base export `69a03d4` | hardware Metal | warm ×1 | 901 | 904 | 11 |
| fix export `79d5780` | hardware Metal | cold ×4 | 844 / 883 / 1032 / 1053 | 1148 / 1188 / 1384 / 1416 | 14 / 10 / 17 / 19 |
| fix export `79d5780` | hardware Metal | warm ×1 | 653 | 1008 | 13 |
| published release `69a03d4` | SwiftShader (cross-check) | cold ×3 | 3907 / 8523 / 9664 | 3944 / 8596 / 9712 | 533 / 230 / 253 |
| fix export `79d5780` | SwiftShader (cross-check) | cold ×3 | 5184 / 5590 / 5264 | 5608 / 6040 / 5680 | 24 / 19 / 12 |

The published arm carries the Pages transfer (`responseStart` 177–223 ms, then the 39.5 MB
wasm and 9.6 MB pck), which the two localhost arms do not; that is why the same commit reads
1.8–2.0 s published and 1.2–1.4 s base-export. The fix arm is the same commit's code plus
#877, so base-export ↔ fix-export is the in-code comparison: every fix run is below every
base run, 0.17–0.60 s earlier, with no other change.

The drive's own cold open (published 2613 ms, fix export 1290 ms at a host load of 14–21)
is higher than the quiet-host runs of the same arm because the drive screenshots and polls
while the page boots; it is a second observation, not the reading of record.

## Environment note

The software-rasteriser cross-check (`ENV.3`) is not the judging leg. Its first WebGL2
context alone costs 0.25–5.5 s here, which is larger than anything #877 moves, and the host
load during those runs (17–24) makes the two arms non-comparable. See [`notes.md`](notes.md).
