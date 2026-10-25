# Arms — the #403 instrument (#856)

`cold_open_layers.mjs` (`--use-angle=swiftshader`), the runner the defect was filed on: one browser
per run, three runs per arm, arms taken in base/after pairs. Instrument and method:
[`readings-ambient-off-paint.md`](readings-ambient-off-paint.md). Rendered-path arms:
[`arms.md`](arms.md).

| Run | firstPainted | engine banner | mode-pick | ambient |
|---|---|---|---|---|
| base 1 | 14405 | 9959 | 12877 | 13370 |
| base 2 | 13293 | 10461 | 11935 | 12408 |
| base 3 | 13604 | 10421 | 11763 | 12267 |
| after 1 | 11631 | 8017 | 10810 | 12094 |
| after 2 | 12926 | 9020 | 11716 | 13406 |
| after 3 | 12897 | 9091 | 11807 | 13385 |

**Ordering, which this arm resolves**: ambient → paint in all three base runs, paint → ambient in
all three after runs.

**Absolute seconds, which it does not**: base mean 13.77 s vs after mean 12.48 s, but each run is a
fresh browser and the engine banner alone spreads 8.0–10.5 s across the six; `paint − banner` does
not separate the arms (3487 ms mean base, 3776 ms mean after). On a host at load 66 this arm is
direction only, and it is not offered as a new absolute reading of the published page.

## Files

| Arm | Logs |
|---|---|
| base | `logs/sw-base-1..3.json` + `logs/sw-base-1..3-console.log` |
| after | `logs/sw-after-1..3.json` + `logs/sw-after-1..3-console.log` |
