# Manifest — #557 crash, reload, and faulted-session durability

- **Issue**: #557 — Exercise crash, reload, and faulted-session durability of Player Elo and Last mode
- **Environment**: `graphical` (`ENV.2`)
- **Build / session id**: published release build `https://waigore.github.io/simplechessv2/` at commit `a68640a604aba249b93a1e61db44af7f28c3b5e0`, deployed by `Web release` on 2026-10-23T22:44:44Z. No `TEL.3` session id: `TEL.3` lives on `CMP-playtest-seams` (`game/playtest_seams.gd:229`), absent from `main_release.tscn` (ADR-0004 `G2`), so none is invented here.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run. Recorded: macOS/arm64 desktop, Google Chrome 156.0.8078.47 (`puppeteer-core` 23, headless, `--enable-unsafe-swiftshader`), 390×844 CSS px at DPR 2; one cold open per leg, 30 s settle.
- **Coverage mode**: `critical-only`, scoped to the three legs this issue names (quit/reload, crash, faulted session).
- **Cited design/UX protocol**: none in scope. This is a `quality.md` durability check, not a design or UX protocol, so there are no story rows and no protocol verdict — the rows below are the three legs plus the two quality claims they support.

## Results

| Row | Claim | Outcome | Basis |
|---|---|---|---|
| Leg 1 — quit/reload | A `SEQ-puzzle-result-commit` S1–S4 commit survives close-and-reopen; mode pick shows the committed Player Elo and Last mode | `not-judged` | `puzzle-play` never opened, so no result commit ran and there is no R2 Elo to read before the close |
| Leg 2 — crash | Mid-session uncommitted Last-mode selection is dropped; reopen shows the last committed Elo and Last mode | `not-judged` | mode pick never rendered, so no uncommitted selection could be made or abandoned before the kill |
| Leg 3 — faulted session | Forced failed write through the devtools `localStorage.setItem` wrapper leaves the prior document intact (`CTR-persist-document` `G2`, `I2`) and shows `EX.save-failure`; reopen shows the committed values | `not-judged` | no commit was attempted on the build, so the wrapper received no write and the save-failure surface was never reached |
| Quality — Reliability (recovery half) | "After a failure, next open is mode pick with the last committed Player Elo and Last mode" | `not-judged` | all three legs are `not-judged`; a leg that never reached mode pick cannot support a pass |
| Quality — Save durability | "Committed Player Elo and Last mode survive quit, crash, and reload; a failed write leaves the previous commit intact" | `not-judged` | no commit path was reachable, so survival and prior-commit integrity are both unobserved |

**Why `not-judged`, not `fail`**: the build never gets past `EX.loading`. `game/presentation.gd` hides that label at `:364`, which runs once mode pick is ready; when a boot preload group fails, `game/asset_resolver.gd` returns without emitting `boot_ready`, so mode pick is never entered. That is a screen-wide defect outside this task's scope, not a durability behavior that ran and misbehaved. Per `specs/playtest/evidence.md`, `not-judged` never counts as `pass`.

## Defects

- **#630**, **#648** / **#479** — see `notes.md` §Defects for both, why neither is re-filed, and what each blocks.

Paths to every artifact: `paths.md`.
