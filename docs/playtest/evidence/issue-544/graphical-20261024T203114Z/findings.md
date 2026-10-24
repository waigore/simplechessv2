# Findings — `S11` on `1894f31` (`ENV.2`)

Parent run: [`notes.md`](notes.md). Logs under `logs/`, probes under `probe/`.

## 1. A self-closed window consumes its own report (`D2`, AC 1, AC 3)

`PlaytestMeasure.observe()` closes a window the moment its close predicate holds, by calling `report(...)`, which disarms. The caller's next `measure(kind)` then takes `if not _armed: return _refuse(kind, "no window")` and returns `status: "refused"`, `detail: "no window"`, empty `kind` and `events` — immediately after `measurement.last()` recorded `{"status":"ok","sample_count":7,"max_ms":10.40}` (`logs/probe-loading-shared-run1.log`, repeated in `logs/probe-shared-close-run2.log` / `run3`).

Not a wrong-kind mistake: **every** argument fails identically against a self-closed window — `frame_times`, `""`, `loading_ready`, `bogus` (`logs/probe-measure-arguments.log`) — and `measure("")` routes to `disarm()`, whose own `_refuse("", "no window")` is what an empty caller meets. So the `frame_times` reading `PTU-shared-play` S5 / `PTU-puzzle-play` S4 need is unreachable through `PlaytestSeams`; `PlaytestMeasure.last()` holds it, but `last()` is not exposed there.

**Refinement direction:** return the closed report when that kind's window was consumed by `observe()`, keeping "one arm measures one window" (never hand it back twice), and state what an empty `kind` returns once a window has self-closed.

## 2. A load-time reading is empty (AC 4)

`loading_ready` closed `ok` with `sample_count: 0`, `max_ms: 0.0`, `events.end: {}` (`logs/probe-loading-shared-run1.log`). `observe()` appends a sample per observed frame and the loading phase produced none between arm and the `mode-pick` snapshot, so `PTU-mode-pick` S1/P4 ("mode pick ready within 3 s") has no number — the seam reports `ok` about nothing.

**Refinement direction:** decide what `loading_ready` samples — the load frames, or the span from `measure.start` `TEL.2` to the close `TEL.2` as a first-class field. `ok` with `sample_count: 0` should not be reachable for a window that met its close predicate.

## 3. `disarm_measurement()` is named but absent (`D4`)

`grep -rn disarm_measurement game/ specs/` on `1894f31` returns nothing; only the empty-kind `measure("")` bridges it, behind finding 1. **Refinement direction:** name the API that exists and make it the documented disarm, or add the named method.

## Not judged — puzzle-play `frame_times` (AC 3, puzzle half)

The stream's first deal is refused on this build (`game/puzzle_stream.gd:97` ← `request` ← `enter`), because `FakeCatalogTransport` answers only when a test seeds a record, so `puzzle_id` stays `"none"` and the arm is correctly refused. Environment gap, not a seam failure — judging it needs the mock catalog service the #400 sweep runs against. The even-length `sequence_index` close is covered by the unit suite only, so this half stays `not-judged`.

## Routing

- Findings 1–3 are inside this leaf's deliverables, so they route on **#544**; no new defect, and not #506 (`D3` reserves that route for a snapshot field the seam cannot publish).
- The shipped-build blocker — no `quality.md` row observable on the published release because it never leaves `EX.loading` — is **#630** (`type:defect`, `status:accepted`) with repair leaf **#647** open. Not filed again here, and not `S11`'s work.
