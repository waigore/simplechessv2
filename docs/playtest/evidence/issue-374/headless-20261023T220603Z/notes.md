# Notes

Build `origin/main` `ba6a59a`, environment `ENV.1`, **released** scene graph.

## Why this run exists

PR #518 (`ec3fa86`), #541 (`da5a5b1`) and #555 (`fd37dc1`) landed the client stream, and #534's acceptance already ran `PTD-move-advice` on `main_release.tscn`. What #374 still owed was its own evidence on the graph acceptance judges: `## Gate — #534` asks the advice-path criteria to be read on the released scene graph against a reachable backend, not from the simulated peer alone. This run records that plus the gates the criteria name.

## What was run

Import, `Web Release` export, then `logs/run_checks.py` — a fresh loopback peer per phase, `logs/drive.gd` against `res://main_release.tscn`, peer stopped. Three phases × three repeats; details in [`setup.md`](setup.md).

| Measurement | Worst of 3 |
|-------------|-----------|
| First E1 after C5 | 111 ms |
| E1 progression on one stream | `+19 → +28 → +41` cp, 0.20 s spread, E2 `cap` |
| HUD click-to-move while streaming | 30 ms |
| Drag-move while streaming | 15 ms |
| `advice.error` per failed stream | 1 |
| O1 `time_ms` (T6 unset) | 2000 (B3 default), every request |
| Exit cleanliness | 0 `ObjectDB` leak warnings, 0 script errors |

## Limits of this run

- **Telemetry (AC 15) is not captured here.** The released graph has no seam node, so `TEL.*` has nowhere to land; the emission code is the same one #375 captured through a recorder stand-in. Flagged, not claimed.
- **AC 13's bundle check here is this run's own string probe of the exported `index.pck`**, not #560's dedicated assertion (still pending).
- The peer is a scripted stand-in, not Stockfish — what ADR-0002 Testability asks of a hermetic headless run; the transport under it is the shipped one.

## Related

- #534 — accepted transport defect; its acceptance is the gate this run serves.
- #375 — owns the UI chrome and `EX.error`; its folder holds the seam-side telemetry reading.
