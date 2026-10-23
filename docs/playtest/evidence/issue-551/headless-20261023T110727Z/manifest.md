# Manifest

- **Issue**: 551
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf, `972e2a1` on `main`. That build carries the defect's deliverable as the merge of PR #563, `9376bc5`; the only later commit (`972e2a1`, PR #564) changes `PTU-localization` docs and no client code. Smoke `TEL.3`: `sess-1792753551805-1930891-playtest`; probe `TEL.3`: `acc551-probe`.
- **Coverage mode**: full, intersected with issue scope: `PTD-difficulty` (Design, `DIF`) and `PTD-game-state` (Design, `GS` persist fields) — both **headless only**. No UX protocol is in scope: the `CFG.ELO_K` correction changes no screen, control, copy, or journey step, so no graphical run applies.
- **Defects**: none — no protocol failed.
- **Screenshots**: not required. Both selected protocols are Design protocols whose Evidence row reads "Default evidence rules (Headless: no screenshots)".

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTD-difficulty` S1 / P1 — `PS1.1` `END.W1` at equal ratings reaches 1010 | pass |
| `PTD-difficulty` S2 / P1 — `PS1.2` `END.L6` (abandon) at equal ratings reaches 990 | pass |
| `PTD-difficulty` S2 / P1 — `END.L5` (reveal) at equal ratings reaches 990 | pass |
| `PTD-difficulty` F1 — Elo does not move opposite `DIF` | pass |
| `PTD-difficulty` P1 — the defect's K=32 numbers (1016 / 984) are gone | pass |
| `PTD-difficulty` S3 / P2 — Shared endings leave Player Elo unchanged | pass |
| `PTD-game-state` S5 / P2 — `playerElo` survives reopen (3010) | pass |
| `PTD-game-state` S5 — `lastMode` survives reopen | pass |
| `PTD-game-state` S5 — `recentSolved` survives reopen | pass |
| `PTD-game-state` P2 / `EX.save-failure` — a failed write keeps the prior commit | pass |
| **Protocol verdict `PTD-difficulty`** | **pass** (headless) |
| **Protocol verdict `PTD-game-state`** | **pass** (headless) |

## Paths

- `notes.md`
- `prep-and-criteria.md`
- `probe/accept551_probe.gd` — the script that produced the judgements
- `logs/import.log`
- `logs/unit-tests.log`
- `logs/coverage.log`
- `logs/lint.log`
- `logs/spec-lint.log`
- `logs/playtest-headless.log`
- `logs/headless-smoke.log`
