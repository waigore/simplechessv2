# Manifest — #557 crash, reload, and faulted-session durability

- **Issue**: #557 — Exercise crash, reload, and faulted-session durability of Player Elo and Last mode
- **Environment**: `graphical` (`ENV.2`)
- **Build / session id**: published release build `https://waigore.github.io/simplechessv2/` at commit `fb1e57e3a07a573ec2f5c08a1bb24e22c43d07c1`, deployed by `Web release` run `40053375882` (2026-10-24T02:14:59Z). Source: **published URL** — the preferred source under `specs/playtest/procedures.md` *Prep*, and the only source this issue permits. No `TEL.3` session id: the release build strips `CMP-playtest-seams` (ADR-0004 `G2`), so none is invented.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run. Headless Chrome (`puppeteer-core@23`), 390×844 at DPR 2, six cold opens, 20 s settle.
- **Coverage mode**: `critical-only`, scoped to the three legs this issue names.
- **Cited design/UX protocol**: none in scope. This is a `quality.md` durability check, not a design or UX protocol: no story rows, no protocol verdict.

## Results

| Row | Claim | Outcome | Basis |
|---|---|---|---|
| Leg 1 — quit/reload | A `SEQ-puzzle-result-commit` commit survives close-and-reopen; mode pick shows the committed Player Elo and Last mode | `not-judged` | no committed document existed before the close; mode pick never rendered |
| Leg 2 — crash | An uncommitted Last-mode selection is dropped; reopen shows the last committed Elo and Last mode | `not-judged` | mode pick never rendered, so no selection could be abandoned; nothing committed to compare |
| Leg 3 — faulted session | A forced failed write leaves the prior document intact (`CTR-persist-document` `G2`, `I2`) and shows `EX.save-failure`; reopen shows the committed values | `not-judged` | wrapper installed and restored, but the build attempted **0** persist writes; the round-trip check was never reached |
| Quality — Reliability (recovery half) | "After a failure, next open is mode pick with the last committed Player Elo and Last mode" | `not-judged` | all three legs `not-judged` |
| Quality — Save durability | "Committed Player Elo and Last mode survive quit, crash, and reload; a failed write leaves the previous commit intact" | `not-judged` | no commit path reachable |

**Why `not-judged`, not `fail`**: every open stalls in `EX.loading` — nine unresolved `game_assets/` paths, then `Preload boot left 9 approved IDs unresolved` without `boot_ready` (#630's stall, not a durability behaviour that ran). Per `specs/playtest/evidence.md`, `not-judged` never counts as `pass`.

**Readings**: `localStorage` held no key before or after any leg; all seven screenshots are byte-identical (`md5 7ba3b2c7…`) — the measured consequence of the stall.

Details: `readings.md`, `build-observations.md`, `notes.md`.

## Defects

- **#630** — the shipped release never leaves `EX.loading`. Sole cause of every row; already open, **not re-filed**.
- **#655** / **#648** / **#479** — no deal, so no result commit. Already open, **not re-filed**.
- **#677** — the read path is open and `Web release` fails its `--check-assets` step (run `40053375882`), so no repaired build publishes. Already open, **not re-filed**.
- No `type:defect` against **#35**: that rule is one per *failing* leg, and none failed.

Paths: `paths.md`. Reproduce: `setup.md`.
