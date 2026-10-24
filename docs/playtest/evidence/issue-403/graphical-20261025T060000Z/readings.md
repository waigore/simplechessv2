# Readings — cold open, first legal move, and the move-window frame budget

Build: the **published** release `c5b8189` served by `40118381611` (`builds.md`). Every number
below is from `https://waigore.github.io/simplechessv2/`. No number comes from the local
export.

## Why the cold open is measured with a readback, not a screenshot

`Page.captureScreenshot` can return a frame the compositor is still holding, and a passive
screencast on an off-screen page is unreliable. The probe used here is the build's **own
canvas**: `gl.readPixels` over a 96×208 patch, once per `requestAnimationFrame`, inside the
page. A frame counts as *painted* when the readback carries any non-zero pixel, which on this
build is the cream mode-pick panel (mean ≈ 240) rather than the near-black loading screen.

`cold_open_exact.mjs` installs that probe on the build's document and stamps every frame with
`performance.now()` from that document's `timeOrigin`. The open is measured from `timeOrigin`
— the moment the document began — which is the "open" the budget counts from.

## Cold open to the first painted screen (mode pick)

Four clean runs on an idle machine (no other headless Chrome); between runs the machine was
left quiet.

| Run | First frame sampled | **First painted screen** | Frames probed | Over the ≤ 3 s bar |
|---|---|---|---|---|
| `x1` | 2230 ms | **4394 ms** | 408 | yes |
| `x2` | 1996 ms | **3346 ms** | 661 | yes |
| `x3` | 1778 ms | **3039 ms** | 746 | yes |
| `x4` | 1377 ms | **3249 ms** | 774 | yes |

**4 of 4 runs paint their first screen after 3000 ms.** The spread is 3039–4394 ms; the
fastest run misses the bar by 39 ms and the slowest by 1394 ms.

`x1` is also the run whose engine start was slow on the console
(`Godot Engine v4.7.2…` at 2.857 s, against 2.210 s in `x3`), which is the same ordering as its
first painted frame — the two read the same stall, not two different ones.

A fifth run, kept only as a control, gave **3208 ms** under the screencast harness
(`screenshots/r2-01-first-painted.png`, session JSON from that run, same build). It agrees; it
is not counted in the four because that harness polls the readback every 250 ms and so cannot
resolve the boundary.

### Earlier runs that are not counted

Three runs on a machine loaded by leaked `cap402` headless Chromes (GPU helpers pinned at
~420 % CPU each, load average 33) gave 9449 / 9204 / 9310 ms. They are **not** used: they
measure the machine, not the build. Killing the strays (`pkill -9 -f
"user-data-dir=cap402"`) brought the load to ~4 and produced the four runs above. They are
mentioned so the record is not surprised to find them on disk.

## Time to a first legal move, and proof the board accepts one

Route on the published build: `Shared game` (195,172) → `Start` (120,312) → tap `e2`
(214,632) → tap `e4` (214,554).

| Reading | Value |
|---|---|
| First painted screen | 3208 ms (control run `r2`) |
| Tap reaches a live board | mode-pick tap at 9.53 s, setup tap at 12.28 s, `e2` at 17.83 s, `e4` at 20.60 s (`mv1`) |
| Header after the move | `White to move` → **`Black to move`** |
| Pawn position after the move | `e2` empty, white pawn on **`e4`** (`screenshots/mv1-09-move+5000.png`) |

**The published build does reach a playable board and accepts a real move.** Every earlier
"no move was reachable on the published build" note in this session came from a wrong square
map (DPR-2 pixels read as CSS px) and is withdrawn. The corrected map at 390×844 CSS px is
`fileA = 59.5`, `row8 = 399.5`, `step = 38.75`; `probe_input.mjs` separately confirmed that
CDP touch, pointer, and mouse events all land on `CANVAS#canvas` at the tap point, so input
was never blocked.

## Move-window frame budget (`SIT.4`)

Two runs, **screencast off** (`--no-cast`): a JPEG stream competes for the same frames and is
not a clean reading of the move window. Both runs took `e2`→`e4`; both landed.

| Window | Run | frames | fps | p50 | p95 | p99 | worst | > 100 ms |
|---|---|---|---|---|---|---|---|---|
| idle (1.2 s before the move) | `mv1` | 38 | 33.1 | 33.3 | 33.4 | 50.1 | 50.1 | 0 |
| move +0…1000 ms | `mv1` | 40 | 39.7 | 33.2 | 33.4 | 33.4 | **33.4** | 0 |
| move +0…2000 ms | `mv1` | 83 | 41.0 | 16.7 | 33.4 | 33.4 | **33.4** | 0 |
| idle | `mv2` | 41 | 35.8 | 33.3 | 49.9 | 50.1 | 50.1 | 0 |
| move +0…1000 ms | `mv2` | 39 | 39.3 | 33.3 | 33.4 | 33.4 | **33.4** | 0 |
| move +0…2000 ms | `mv2` | 80 | 40.5 | 16.8 | 33.4 | 33.4 | **33.4** | 0 |

**What this can and cannot decide.** No frame in the move window exceeds 33.4 ms, and neither
run has a frame over 100 ms. But **the idle window sits at the same ~33 ms median**, so this
host does not deliver 16.7 ms frames even when nothing is moving. On that reading a move hitch
is *not isolatable*: 33.4 ms is the second step of this harness's frame delivery, not a stall
caused by the move.

That is exactly #402's finding on the same build — *idle and move windows equally slow on
SwiftShader (p50 50–66.7 ms both)* — so the move rows inherit **`not-judged`**, and this
measurement is the corroboration, not a verdict of its own. Claiming a `pass` from it would be
the mistake the citation rule forbids: absence of a hitch on a host that cannot reach the frame
rate is indistinguishable from a host that is simply slow.

Whole-run max is 733–850 ms, all of it in the open and route, never in the move window.

## A cross-record conflict: #845's “one rank above” does not reproduce here

#402's `Load time` row fails partly on *board not playable by touch (#845)*. **This folder's
reading contradicts #845's premise**, and the record states it rather than carrying it silently.
The verdict is unaffected: that row fails on **time** (5.5–6.1 s there, 3.0–4.4 s here), so
`fail` stands either way. What differs is the *reason*.

- #845 says *“a touch on the painted e2 pawn selects the painted e1 king”*, and its reading
  places the tap at CSS `(219, 654)`.
- On this build the board's rank-1 square spans about **y 651–690** (e1 centre ≈ 671), and
  rank 2 spans about **y 613–651** (e2 centre ≈ 632). So `y = 654` **is inside e1** — the tap
  selected the square it landed on. #402's own screenshot `board-01-tap-visible-e2-selects-e1.png`
  shows the ring on the **e1 king**, whose centre is ≈ 670, consistent with this map and not
  with “654 is e2”.
- The rank sweep's finding that *only y 620–680 produced a selection* is also what a **correct**
  map gives: at the start position only ranks 1 and 2 carry pieces, so taps on the empty
  e4/e5/d4 squares have nothing to select. That is normal chess UI, not a lost tap.
- This folder's `e2`→`e4` move — tap `(214, 632)` then `(214, 554)`, i.e. rank 2 then rank 4 —
  **landed** (`Black to move`, pawn on e4, `screenshots/mv1-09-move+5000.png`), and
  `probe_input.mjs` showed the touch reaching `CANVAS#canvas` at the tap point.

So this record does **not** cite #845 as a cause of any row. A verifier should treat #845 as
`needs-recheck` against the map above before it is used to gate touch play. The coordinate
class of error is the same one `notes.md` records for this session's earlier readings.

## Backend failure clears advice (fresh evidence)

Not a browser reading — the `Unit tests` run on the shipped commit
(`logs/advice-client-test-c5b8189.log`): exit 0, **0 `FAIL ` lines**.
`_check_offline_clears` (`game/advice_client_test.gd:249`) pushes a live `d2d4` update, then
ends the stream with `REASON_ERROR` and asserts the FAIL.T1 behaviour: `GS.online` false, both
advice fields cleared (`:264`), the failure reported as `advice.error` / `unavailable` and
**play continued** (`:266`), and the failed stream delivers nothing further (`:279`).

The `Parse JSON failed` line in that log is expected: `_check_wire_handles_partial_and_junk`
(`:488`) feeds deliberate junk (`"not json"`) to prove the reader ignores it.

## Forced failed write keeps the prior commit (fresh evidence, published build)

ADR-0003 *Failed write keeps prior* / quality.md Save durability. The build writes one document
under `simplechessv2.persist.v1` through `Storage.prototype.setItem` (`game/persist_store.gd`
`_web_set`, whose comment names the quota case), so the fault is injected there as a throw —
clearing storage would prove nothing about a *failed* write.

| Step | Observed |
|---|---|
| Prior commit seated (the choice the build makes on Shared game) | `last_mode: "shared"` present in `simplechessv2.persist.v1` |
| Fault armed | `setItem` throws `QuotaExceededError` from then on |
| The build's next write (pick `Puzzle stream`) | **1** failed write |
| The build's own report | `ERROR: PersistStore: write failed; prior commit kept` at 10.947 s |
| Storage after | byte-identical to before; `last_mode` still `shared` |
| Play | continues; UI shows *"Save failed. Prior values kept."* over the mode pick, with `Shared game · Last` still highlighted |

The one failed write is the whole point: a run where the fault never fires proves nothing, and
an earlier attempt on this build did exactly that by tapping the wrong button (a coordinate
error, the same class as the board-square one in `notes.md`). Only the run with
`failedWrites: 1` is cited.
