# Manifest — #557 crash, reload, and faulted-session durability

- **Issue**: #557 — Exercise crash, reload, and faulted-session durability of Player Elo and Last mode
- **Environment**: `graphical` (`ENV.2`)
- **Build / session id**: published release build `https://waigore.github.io/simplechessv2/`, commit `c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96`, deployed by `Web release` run `40118381611` (success). Source: **published URL**, per [`procedures.md`](../../../../../specs/playtest/procedures.md) *Prep*. The commit was cross-checked against the `github-pages` deployment that served the URL, not against a failed run. No `TEL.3` session id: the release strips `CMP-playtest-seams` (ADR-0004 `G2`).
- **Timing (`SIT.4` runs)**: not a `SIT.4` run. Headless Chrome 156.0.8078.47, `puppeteer-core@23`, 390×844 DPR 2, six cold opens, 20 s settle.
- **Coverage mode**: `critical-only`, scoped to the three legs.
- **Cited design/UX protocol**: none in scope — a `quality.md` durability check, not a protocol, so no story rows and no protocol verdict.

## Results

| Row | Claim | Outcome | Basis |
|---|---|---|---|
| Leg 1 — quit/reload | A `SEQ-puzzle-result-commit` survives close-and-reopen; mode pick shows the committed Player Elo and Last mode | `not-judged` | build reached mode pick and `puzzle-play`, but `puzzle stream: deal read failed (status)` — no puzzle dealt, so no result committed |
| Leg 2 — crash | Reopen is mode pick with the last committed values, not an uncommitted mid-session value | `pass` | renderer killed with an uncommitted setup toggle; reopen held `last_mode: shared`, `player_elo: 1000` |
| Leg 3 — faulted session | A forced failed write leaves the prior document intact (`CTR-persist-document` `G2`, `I2`), shows the save-failure surface, and a clean reopen matches | `pass` | one write forced to fail; build reported `write failed; prior commit kept`, showed `Save failed. Prior values kept.`, document unchanged, reopen matched |
| Quality — Reliability (recovery half) | "After a failure, next open is mode pick with the last committed Player Elo and Last mode" | `not-judged` | legs 2 and 3 show the recovery shape, but Elo only changes at a puzzle-result commit and none ran, so the Elo half is shown only at its unchanged start value |
| Quality — Save durability | "Committed Player Elo and Last mode survive quit, crash, and reload; a failed write leaves the previous commit intact" | `not-judged` | crash/reload and failed-write legs hold; the quit leg after a **puzzle result** is unreachable |

**Why leg 1 is `not-judged`, not `fail`**: the build now leaves `EX.loading` (#630, closed) and reaches both screens. The blocker is upstream — the release ships `advice_endpoint` / `advice_api_key` empty, and the only assignment lives in `game/advice_ui_test.gd`, which the export excludes, so nothing is dealt. Per [`evidence.md`](../../../../../specs/playtest/evidence.md), `not-judged` never counts as `pass`.

Details: `readings.md`, `notes.md`, `build-observations.md`.

## Defects

- **#630** — the loading stall. **Closed**; the build now reaches mode pick. Not re-filed.
- **No `type:defect` filed**: legs 2 and 3 passed, and leg 1 is `not-judged`, which files no per-row defect. The cause (no deal) is owned by open **#648** / **#655** / **#479**.

Paths: `paths.md`. Reproduce: `setup.md`.
