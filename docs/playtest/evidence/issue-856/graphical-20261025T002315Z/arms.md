# Arms — rendered GPU path (#856)

Instrument and method: [`readings-ambient-off-paint.md`](readings-ambient-off-paint.md). Each row is
one cold open in `cold_open_aligned.mjs`: `firstPainted` = first frame whose canvas readback is
non-zero; `mode-pick` and `ambient` = the app's own console stamps, on the same page clock.

## The shipped change, one frame of deferral (rejected)

| Run | firstPainted | mode-pick | ambient |
|---|---|---|---|
| base 1 | 1762 | 1150 | 1632 |
| base 2 | 1967 | 1349 | 1843 |
| base 3 | 1747 | 1135 | 1630 |
| after 1 | 1777 | 1177 | 1752 |
| after 2 | 3160 | 1894 | 2403 |
| after 3 | 1888 | 1289 | 1864 |

No improvement: the paint still lands after the ambient stamp (1777 > 1752).

## Two frames of deferral (adopted)

| Run | firstPainted | mode-pick | ambient |
|---|---|---|---|
| base 1 | 1943 | 1298 | 1811 |
| base 2 | 1768 | 1149 | 1649 |
| base 3 | 1837 | 1199 | 1695 |
| after 1 | 1430 | 1298 | 1920 |
| after 2 | 1468 | 1330 | 1953 |
| after 3 | 1302 | 1172 | 1806 |

The paint precedes the ambient stamp in every after run.

## The branch under test, back to back at the same load

| Run | firstPainted | mode-pick | ambient |
|---|---|---|---|
| base 1 | 1827 | 1211 | 1692 |
| base 2 | 1811 | 1213 | 1685 |
| base 3 | 2058 | 1447 | 1938 |
| after 1 | 1324 | 1180 | 1841 |
| after 2 | 1329 | 1196 | 1831 |
| after 3 | 1576 | 1438 | 2085 |

Means: base 1899 ms, after 1476 ms.

## Files

| Arm | Logs |
|---|---|
| branch, back to back | `logs/ab-final-base.json`, `logs/ab-final-after.json` |
| two frames | `logs/ab-base2-1.json`, `logs/ab-after2-1.json` |
| one frame | `logs/ab-base-1.json`, `logs/ab-after-1.json` |
| measurement print | `logs/measurement-print.patch` |

The software-rasteriser arm is in [`arms-swiftshader.md`](arms-swiftshader.md).
