# Manifest — #403 Every-release ADR rows on the shipped release

- **Issue**: #403 (epic #37). **Build**: **published** release `c5b8189`, `Web release` run
  `40118381611`, served at `https://waigore.github.io/simplechessv2/`. At or after #647's merge —
  unlike #402's first record. See [builds.md](builds.md).
- **Environment**: macOS 27.0.1 / Apple M5; Chrome **156.0.8078.47** headless; 390×844 CSS,
  DPR 2, `--use-angle=swiftshader`; CDP.
- **Coverage mode**: `full` for the rows read here; other-owner rows are cited, not read.
- **Repeat count**: cold open **4** (+1 control); move window **2**; FAIL.T1 **1**.
- **Timing**: `SIT.4` on Graphical. Cold open is an in-page `gl.readPixels` probe sampled once per
  frame (`scripts/cold_open_exact.mjs`), so it times the first *painted* screen.

## Results — 17 rows: 5 `pass`, 2 `fail`, 10 `not-judged`

Quoted Methods and per-row evidence: [rows-adr-0001.md](rows-adr-0001.md),
[rows-adr-0002-0003.md](rows-adr-0002-0003.md), [rows-adr-0004-0005.md](rows-adr-0004-0005.md).

| Check | Verdict |
|---|---|
| ADR-0001 Move hitch ≤1 frame | not-judged |
| ADR-0001 Cold open ≤3 s | **fail** |
| ADR-0001 Sitting without forced exit | not-judged |
| ADR-0001 Piece shape and color-blind readability | not-judged |
| ADR-0001 Locale spot-check | not-judged |
| ADR-0002 Stream stops by 2000 ms | not-judged |
| ADR-0002 Backend failure clears advice | **pass** |
| ADR-0002 Advice timing/errors logged | not-judged |
| ADR-0002 No move-path hitch | not-judged |
| ADR-0003 Reload keeps Elo and Last mode | **pass** |
| ADR-0003 Failed write keeps prior | **pass** |
| ADR-0003 Cold open includes sync read | **fail** |
| ADR-0003 Persist failures in logs | **pass** |
| ADR-0004 Observability story IDs | not-judged |
| ADR-0004 60 fps with playtest I/O | not-judged |
| ADR-0004 Sessions without engine-forced exit | not-judged |
| ADR-0005 Roots not mixed | **pass** |

## Readings

| Reading | Result | File |
|---|---|---|
| Cold open to first painted screen | 3039 / 3246 / 3249 / 4394 ms, 4/4 over 3 s | [readings-cold-open.md](readings-cold-open.md) |
| Board accepts `e2`→`e4` | `White to move` → `Black to move`, pawn on e4 | [readings-cold-open.md](readings-cold-open.md) |
| Move-window frame budget | worst 33.4 ms, 0 frames > 100 ms, idle equally slow | [readings-move-window.md](readings-move-window.md) |
| Forced failed write | prior commit byte-identical, one log line, play continues | [readings-storage-advice.md](readings-storage-advice.md) |
| FAIL.T1 backend failure | exit 0, 0 `FAIL ` lines | [readings-storage-advice.md](readings-storage-advice.md) |
| Roots audit | 32 entries, 38 cataloged = 38 on disk, 0 missing | [roots-not-mixed.md](roots-not-mixed.md) |

## Defects

- **#856** — release Web cold open 3.0–4.4 s, over the 3 s bar (ADR-0001 *Cold open ≤3 s*,
  ADR-0003 *Cold open includes sync read*).

`not-judged` rows cite their seats (#558, #559, #640/#641, #643, #400, #560) rather than
duplicating them.

## Paths

`logs/` (probe sessions, frame stamps, console, gate runs) · `screenshots/` · `scripts/` (harness
as run) · method and traps: [notes.md](notes.md).
