# Manifest

- **Issue**: 550
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf`, `origin/main` `614746c`. Probe `TEL.3` `sess-1792788917499-38686-playtest` (`logs/playtest-headless.log`). Same build as the graphical twin.
- **Coverage mode**: `full` (critical IDs: none), intersected with #550's scope: design `PTD-puzzle-stream`, `PTD-difficulty`, `PTD-progression`, `PTD-game-state`, `PTD-pieces-common`; UX `PTU-puzzle-session`, `PTU-puzzle-play`, `PTU-mode-pick`, `PTU-navigation`, `PTU-controls`, `PTU-exceptions`, `PTU-localization`. View stories excluded.
- **Story-row source**: the protocol files' own `Cites` rows; #481's map is not on `main`. See `notes.md`.
- **Defects**: #655 — Puzzle stream deals nothing on the shipped path (`T9`/`T10` unset).
- **Screenshots**: waiting on `../graphical-20261024T000000Z/screenshots/`, the same build. A headless run omits them without a fail.
- **Log window cited by `SIT.5`**: `sess-1792788917499-38686-playtest`, 6 events.

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTD-puzzle-stream` S1/P1 — deal yields a puzzle (K1) | **fail** — `dealt=false`, read refuses (`status`); `T9`/`T10` empty (#655) |
| `PTD-puzzle-stream` S2–S6, F1 (K2–K4, `END.L4`–`L6`) | not-judged — no open attempt |
| `PTD-difficulty` S1/P1 (`DIF.Y1`) | not-judged — no dealt Rating |
| `PTD-progression` S1–S3 (`PRG.A1`, `P1`, `P3`, `M1`) | not-judged — no outcome to score |
| `PTD-game-state` (`GS.puzzle*`, `V1`, `V3`, `H1`) | not-judged — fields unset with no deal |
| `PTD-pieces-common` S1 | not-judged — no puzzle position |
| `PTU-puzzle-session` S1/P1 — `C2` opens the stream | pass — `stage=puzzle-play` |
| `PTU-puzzle-session` S2–S3 — leave confirm/cancel | judged in the graphical twin |
| `PTU-puzzle-play` S1/P1 — playable on a dealt puzzle (US1) | **fail** — no puzzle open |
| `PTU-puzzle-play` S2–S4 | not-judged — no open attempt |
| `PTU-mode-pick` US1/P1 — both entries offered | pass |
| `PTU-mode-pick` S5/P3 — locale row reads its own name | pass — 繁體中文 |
| `PTU-navigation` S1–S3/P1 — `C1`, Back, no dead end | pass |
| `PTU-controls` S1–S2/P1 | graphical twin |
| `PTU-exceptions` S2/P1 — illegal place refused | pass |
| `PTU-localization` P2 — copy differs per locale | pass — 選擇遊玩方式 / 遊び方を選ぶ |
| `PTU-localization` P5 — Copy values, not raw keys | pass |
| `SIT.5` — seam reports its log window | pass — `session_id` = `TEL.3`, 6 events |
| **`PTD-puzzle-stream` verdict** | **fail** |
| **`PTD-difficulty` verdict** | **not-judged** |
| **`PTD-progression` verdict** | **not-judged** |
| **`PTD-game-state` verdict** | **not-judged** |
| **`PTD-pieces-common` verdict** | **not-judged** |
| **`PTU-puzzle-play` verdict** | **fail** |
| **`PTU-puzzle-session` verdict** | **pass** (entry; leave in twin) |
| **`PTU-mode-pick` verdict** | **pass** |
| **`PTU-navigation` verdict** | **pass** |
| **`PTU-localization` verdict** | **pass** |
| **`PTU-controls` verdict** | **pass** (twin) |
| **`PTU-exceptions` verdict** | **pass** |

## Paths

- `notes.md`
- `probe/accept550_probe.gd` — driver and judgements
- `probe/accept550_seam_crosscheck.gd` — isolates the failure to the missing values
- `logs/playtest-headless.log`, `logs/seam-crosscheck.log`
- `logs/import.log`, `logs/headless-smoke.log`
- `logs/unit-tests.log` — 25 passed
- `logs/coverage.log` — 86.4% (4466/5167), threshold 80
- `logs/gdformat-check.log`, `logs/gdlint.log`, `logs/spec-lint.log`

## Defects

- #655 — `T9`/`T10` unset at `session_router.gd:729`, so every catalog read refuses (`B5`, `F-puzzle-catalog.X2`). Delivery decision: #648, blocked by #479.
