# Headless notes

Evidence run for #375 (advice UI on the Shared screens) on `origin/main` `d164acb`.

## Scope

#375 changes playable behavior — advice marks, eval, the C3 / C4 toggles, the S3 `EX.error` state. The intersect with `full` coverage is the three UX protocols it names: `PTU-shared-play`, `PTU-shared-setup`, `PTU-exceptions`. UX protocols need headless **and** graphical; this folder is the headless half.

## Why this run exists

AC11 requires the R3 advice display to be established on the shipped release scene graph against a reachable backend, not from the simulated peer alone. `docs/playtest/evidence/` had no `issue-375/` folder even though the implementation PR #531 merged on 2026-10-23, so this run closes that gap and nothing else.

The drive loads `res://main_release.tscn` — what the `Web Release` export ships. With no `PlaytestSeams` node, `_advice_sim_factory()` returns `null` and the shipped `AdviceStreamTransport` is the only advice path, which is exactly what the criterion is about.

## Honest limits

- **No browser.** Headless plus a loopback HTTP peer. The transport is real (`HTTPClient` + worker `Thread`), so display behavior is real; the **pixels are not**. AC4 (`PAL.C7` contrast, `UIS.T2` size, 10% coverage, silhouette) and the graphical halves of AC10 are owed, marked owed in [`verdicts.md`](verdicts.md), not passed.
- **Telemetry.** `TEL.*` goes only through `PlaytestSeams`, absent from the release graph (G2). So `TEL.3` has no session id here, and the `telemetry` phase records the router's real emissions through a recorder where the seam would be. It proves the router emits `shared.advice` / `toggled` / `UI-shared-play.US1.4` on C3; it does not prove a shipped build writes telemetry anywhere, because by design it does not.
- **A reachable peer is not Stockfish.** The peer speaks CTR-advice-stream with scripted values, as ADR-0002 Testability intends for a client check. Backend correctness is #373's and #534's evidence, not this folder's.
- **Exit status.** `play` and `toggle` can fault on process exit (thread teardown) after their summary line; assertions are complete before that. Noted in [`verdicts.md`](verdicts.md).

## Judgement

Nothing observable here failed, so no defect was filed. Headless halves of the three UX protocols pass; the graphical halves and pixel-level quality criteria stay open and are listed as owed. Design: [`setup.md`](setup.md). Assertions: [`results.md`](results.md). Per-criterion judgement: [`verdicts.md`](verdicts.md).
