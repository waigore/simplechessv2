# Notes

Build `b171a3f` (`main`: PR #518 `ec3fa86`, #541 `da5a5b1`, #555 `fd37dc1`, #711 `b171a3f`), environment `ENV.1`, **released** scene graph.

## Why this run exists

This is the acceptance re-run for #374 after the 2026-10-24T01:07Z acceptance fail on **AC 15** (no `advice.cleared` telemetry). PR #711 added the event and `_check_cleared_reports_story`; the verifier passed it at 2026-10-24T01:34Z. Acceptance asks for the advice-path criteria (AC 1, AC 10, AC 11, AC 12) on the released scene graph against a reachable backend per [`## Gate — #534`](https://github.com/waigore/simplechessv2/issues/374#gate--534), and may take AC 15 from the suite. This folder records both on the post-#711 build, in a session separate from the implementor's and the verifier's.

## What was run

Fresh checkout at `b171a3f`; import, `Web Release` export, then `logs/run_checks.py` — a fresh loopback peer per phase, `logs/drive.gd` against `res://main_release.tscn`, peer stopped. Three phases × three repeats. Gates re-run in the same checkout. Details in [`setup.md`](setup.md); readings in [`results.md`](results.md).

## Limits of this run

- **Telemetry (AC 15) is not observable on the released graph.** With no `PlaytestSeams`, `TEL.*` has nowhere to land, so a clear cannot be read from this folder's logs. AC 15 is carried by `game/advice_client_test.gd` `_check_cleared_reports_story` (six clear rules plus the silent case), which runs green in `logs/unit-tests.log` on this same build; #711's fail-closed behaviour was checked by the verifier's mutation. This folder does not claim a captured cleared event.
- **AC 13's bundle check is this run's own string probe of the exported `index.pck`**, not #560's dedicated assertion (still pending); the criterion's own text — no Stockfish endpoint in the shipped bundle — is met.
- The peer is a scripted stand-in, not Stockfish — what ADR-0002 Testability asks of a hermetic headless run; the transport under it is the shipped `AdviceStreamTransport`.
- The suite is hermetic in CI: `logs/unit-tests.log` was taken with `ADVICE_STREAM_PEER` unset, and `logs/advice-suite-peer.log` is the same suite with the peer armed, so the two peer checks ran rather than skipping.

## Related

- #534 — accepted transport defect; its acceptance is the gate this run serves.
- #375 — owns the UI chrome and `EX.error`; its folder holds the seam-side telemetry reading.
- #711 — the PR that closed AC 15.
