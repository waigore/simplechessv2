# Manifest — #557 crash, reload, and faulted-session durability

- **Issue**: #557 — Exercise crash, reload, and faulted-session durability of Player Elo and Last mode
- **Environment**: `graphical` (`ENV.2`)
- **Build / session id**: published release build `https://waigore.github.io/simplechessv2/` at commit `46cec71aaaa72439d9dce4fb19299f374efe2cdb`, deployed by `Web release` run `40041185072` on 2026-10-23T23:42:44Z. Source: **published URL** — the preferred source under `specs/playtest/procedures.md` *Prep*, and the only source this issue permits. No `TEL.3`: the release build strips `CMP-playtest-seams` (ADR-0004 `G2`), so none is invented.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run. Recorded: macOS/arm64, `Chrome/156.0.8078.47` headless, 390×844 at DPR 2; one cold open per leg and reopen, 25 s settle.
- **Coverage mode**: `critical-only`, scoped to the three legs.
- **Cited design/UX protocol**: none in scope. This is a `quality.md` durability check, not a design or UX protocol, so there are no story rows and no protocol verdict.

## Results

| Row | Claim | Outcome | Basis |
|---|---|---|---|
| Leg 1 — quit/reload | A `SEQ-puzzle-result-commit` commit survives close-and-reopen; mode pick shows committed Elo and Last mode | `not-judged` | `puzzle-play` never opened, so no commit ran and there was no R2 Elo to read |
| Leg 2 — crash | An uncommitted Last-mode selection is dropped; reopen shows committed values | `not-judged` | mode pick never rendered, so no selection could be made and abandoned |
| Leg 3 — faulted session | A forced failed write through the devtools wrapper leaves the prior document intact (`G2`, `I2`) and shows `EX.save-failure` | `not-judged` | wrapper installed and restored, but the build attempted **0** persist writes; the round-trip check was never reached |
| Quality — Reliability (recovery half) | "After a failure, next open is mode pick with the last committed Player Elo and Last mode" | `not-judged` | all three legs are `not-judged` |
| Quality — Save durability | "Committed Player Elo and Last mode survive quit, crash, and reload; a failed write leaves the previous commit intact" | `not-judged` | no commit path was reachable |

**Why `not-judged`, not `fail`**: the build never leaves `EX.loading`. Every open logs 15 `game_assets/…` file failures then `Preload boot left 9 approved IDs unresolved`; `_preload` returns without emitting `boot_ready`, so the router never leaves `STAGE_LOADING`. That is a screen-wide boot defect outside this task's scope, not a durability behaviour that misbehaved. Per `specs/playtest/evidence.md`, `not-judged` never counts as `pass`. Details: `build-observations.md`, `notes.md`.

**Screenshot note**: all seven captures are byte-identical (`md5 7ba3b2c7…`) — the measured consequence of the stall. `run.json` carries the md5 set so the claim is checkable. No `pass` state was captured because none occurred.

## Defects

- **#630** — sole cause of every row (the shipped release never leaves `EX.loading`). Already open; **not re-filed**; a `not-judged` row files no per-row defect.
- **#648** / **#479** — independent second blocker behind #630: no `T9`/`T10`, so no puzzle is dealt. Already tracked; **not re-filed**.
- No `type:defect` against **#35**: the rule is one per *failing* leg, and no leg failed.

Paths: `paths.md`.
