# Per-run readings

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
1.8–2.0 s published and 1.2–1.4 s base-export. The panel reading sits below FCP on the fix
arms because it samples the canvas rather than the page paint: two instruments for one state.

The drive's own cold open (published 2613 ms, fix export 1290 ms at a host load of 14–21) is
higher than the quiet-host runs of the same arm because the drive screenshots and polls while
the page boots; it is a second observation, not the reading of record.

The SwiftShader arm is a cross-check, not the judging leg ([`renderer.md`](renderer.md)); the
#877 comparison across the two localhost exports is in [`fix-effect.md`](fix-effect.md).
Story rows are in [`results.md`](results.md).
