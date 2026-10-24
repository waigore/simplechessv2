# Readings — move-window frame budget (SIT.4)

## Move-window frame budget (`SIT.4`)

Two runs, **screencast off** (`--no-cast`): a JPEG stream competes for the frames it measures.
Both took `e2`→`e4`; both landed.

| Window | Run | frames | fps | p50 | p95 | p99 | worst | > 100 ms |
|---|---|---|---|---|---|---|---|---|
| idle (1.2 s before) | `mv1` | 38 | 33.1 | 33.3 | 33.4 | 50.1 | 50.1 | 0 |
| move +0…1000 ms | `mv1` | 40 | 39.7 | 33.2 | 33.4 | 33.4 | **33.4** | 0 |
| move +0…2000 ms | `mv1` | 83 | 41.0 | 16.7 | 33.4 | 33.4 | **33.4** | 0 |
| idle | `mv2` | 41 | 35.8 | 33.3 | 49.9 | 50.1 | 50.1 | 0 |
| move +0…1000 ms | `mv2` | 39 | 39.3 | 33.3 | 33.4 | 33.4 | **33.4** | 0 |
| move +0…2000 ms | `mv2` | 80 | 40.5 | 16.8 | 33.4 | 33.4 | **33.4** | 0 |

No move-window frame exceeds 33.4 ms and none exceeds 100 ms. But **the idle window sits at the
same ~33 ms median**, so this host never delivers 16.7 ms frames even with nothing moving — a
move hitch is *not isolatable* here.

That is #402's finding on the same build (*idle and move windows equally slow on SwiftShader,
p50 50–66.7 ms both*), so the move rows inherit **`not-judged`**; this is corroboration, not a
verdict. Claiming `pass` would be the softening the citation rule forbids: on a host that cannot
reach the frame rate, absence of a hitch is indistinguishable from general slowness.

Whole-run max is 733–850 ms, all of it in the open and route, never in the move window.

