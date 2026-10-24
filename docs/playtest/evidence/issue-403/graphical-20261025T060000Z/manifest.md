# Manifest — #403 Every-release ADR rows on the shipped release

- **Issue**: #403 *Close out the Every-release ADR validation rows on the shipped release* (epic #37)
- **Build / session**: **published** release `c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96`, `Web release`
  run **`40118381611`** (2026-10-24T17:56:09Z, `success`), served at
  `https://waigore.github.io/simplechessv2/` (Pages `last-modified: Sat, 24 Oct 2026 17:57:05 GMT`).
  Read from the published URL. This build is **at or after #647's merge** (`bccdb1c`). See
  [builds.md](builds.md).
- **Environment**: macOS 27.0.1, Apple M5; Google Chrome **156.0.8078.47**, headless (`--headless=new`),
  390×844 CSS px at `--force-device-scale-factor=2`, `--use-angle=swiftshader
  --enable-unsafe-swiftshader`; CDP over a local debugging port.
- **Coverage mode**: `full` for the rows this folder reads; rows owned by another leaf are cited, not read.
- **Repeat count**: cold open **4** counted runs (+1 control), move-window frame reading **2** runs,
  FAIL.T1 **1** run (`SIT.4` requires a repeat count; 4 and 2 are stated per reading).
- **Timing source**: `SIT.4` on Graphical, as `specs/playtest/tools-situational.md` requires. The
  `EX.loading`→mode-pick reading is taken by in-page `gl.readPixels` per frame
  (`scripts/cold_open_exact.mjs`), not by screenshot.

## What was measured here

| Reading | Result | File |
|---|---|---|
| Cold open to first painted screen (mode pick) | **3039 / 3246 / 3249 / 4394 ms** — 4/4 over 3 s | [readings.md](readings.md), `logs/x{1..4}-*` |
| Published build reaches a board and accepts a move | `e2`→`e4`, header `White to move` → `Black to move` | `screenshots/mv1-01`…`09`, `screenshots/mv2-09-move+5000.png`, control cold open `screenshots/r2-01-first-painted.png` |
| Move-window frame budget (screencast off) | worst frame **33.4 ms**, 0 frames > 100 ms — but idle is equally slow, so the move rows are `not-judged` per #402's Performance row | `logs/mv{1,2}-timeline.json` |
| FAIL.T1 backend failure (`advice_client_test.gd`) | exit 0, **0 `FAIL ` lines** | `logs/advice-client-test-c5b8189.log` |
| Forced failed write keeps the prior commit | prior `last_mode: shared` intact, 1 failed write, one explicit log line, play continued | `logs/fw1-*`, `screenshots/store-*` |
| Release bundle carries no Stockfish | `--check-engine build/web` → exit 0 | `logs/check-engine-c5b8189.log` |
| Unit tests on `c5b8189` | **30 passed** | `logs/unit-tests-c5b8189.log` |
| Roots not mixed (`ACC.P1`–`P2`, `R1`/`O2`) | 32 entries, 38 cataloged = 38 on disk, 0 missing, 0 uncataloged, no engine/build files | `logs/roots-not-mixed-audit-c5b8189.log` |
| Manifest is generated, not hand-edited | byte-identical to a fresh regeneration | `logs/manifest-generated-not-edited-c5b8189.log` |

## Row results — the twelve ADR-0001/0002/0003 rows #403 records

Method text is quoted from the ADRs on `main`; the `reads` column names the owner record or the
file in this folder. `#402` rows are named by their `quality.md` row, as #402's record names them.

### ADR-0001 (`specs/adr/decisions/0001-godot-engine.md:75-79`)

| Check | Method (quoted) | Result | Evidence |
|---|---|---|---|
| Move hitch ≤1 frame | `quality.md frame-time` | **not-judged** | Read once from #402's **Performance** row on this same build (`not-judged` — *idle and move windows equally slow on SwiftShader, p50 50–66.7 ms both*). This folder's own `logs/mv{1,2}-timeline.json` **corroborates**: idle p50 33.3 ms vs move p50 33.2 ms, worst move frame 33.4 ms, 0 frames > 100 ms. A hitch cannot be isolated on a host that does not reach 16.7 ms frames even when idle — which is #402's reason, not a softened pass |
| Cold open ≤3 s | `quality.md timed open` | **fail** | #402's **Load time — board playable ≤ 3 s** row on `c5b8189` is `fail` (*first paint 5.5–6.1 s, FCP 8.2–8.7 s, 3/3*). This folder's independent per-frame readback agrees on the verdict: **3039–4394 ms** first painted screen, 4/4 over the bar (`readings.md`) |
| Sitting without forced exit | `quality.md sitting soak` | **not-judged** | No sitting soak was run for this record; #402's *Reliability — sitting* row is `not-judged` (*seat #558*), and #558 owns that soak |
| Piece shape and color-blind readability | `quality.md readability checks` | **not-judged** | #640 / #641 have returned no verdict (both `status:pending-implementation`); #402's *Accessibility — shape / no color-only* row is `not-judged` behind them |
| Locale spot-check | `quality.md locale spot-check` | **not-judged** | #643 has returned no verdict (`status:pending-implementation`); #402's *Localization — three locales* row is `not-judged` behind it |

### ADR-0002 (`specs/adr/decisions/0002-stockfish-advice-backend/non-functional.md:59-64`)

| Check | Method (quoted) | Result | Evidence |
|---|---|---|---|
| Move while advice in flight | `F-move-advice R6 automated test against a simulated peer, plus the playtest step` | **not-judged** | Both halves required. The R6 automated half is green in `logs/advice-client-test-c5b8189.log`; the playtest half needs **#400**, which has not run |
| Stream stops by 2000 ms | `quality.md Load time / latency: timed advice readiness (G2)` | **not-judged** | #402's *Load time — advice ready ≤ 2000 ms* row is `not-judged` (*seat #559*) |
| No client Stockfish endpoint | `Review / architecture test over the Web export (module M1 boundary)` | **not-judged** | #560's check `scan_release_bundle` is **absent** from `.github/scripts/web_export.py` at `c5b8189` (0 occurrences). Supporting (not substituting): `--check-engine build/web` → exit 0 |
| Backend failure clears advice | `Automated test ([FAIL.T1](../../../technical/failures.md))` | **pass (fresh)** | `logs/advice-client-test-c5b8189.log`: exit 0, 0 `FAIL ` lines; `_check_offline_clears` `:249` asserts `GS.online` false, both fields cleared, `advice.error`/`unavailable` reported, play continues, failed stream delivers nothing further |
| Advice timing/errors logged | `quality.md Observability log check` | **not-judged** | #402's *Observability* row on `c5b8189` is `not-judged` — the row judges the playtest-certified build (`H1`), and a release build emits no `TEL.*` by specification (#729, `CTR-playtest-drive` G2) |
| No move-path hitch | `quality.md Performance: frame-time capture during piece movement` | **not-judged** | Same measurement as *Move hitch ≤1 frame*, read once from #402's **Performance** row (`not-judged`, same reason). This folder's move reading agrees there is no visible hitch but cannot isolate one on this host |

### ADR-0003 (`specs/adr/decisions/0003-localstorage-persistence.md:76-79`)

| Check | Method (quoted) | Result | Evidence |
|---|---|---|---|
| Reload keeps Elo and Last mode | `quality.md quit/reload` | **pass** | #402's **Reliability — reopen after failure** row on `c5b8189` is `pass` (*`Page.crash` mid-session, reopen → mode pick, stored doc unchanged*; `screenshots/durability-01-reload-mode-pick.png` in that record) |
| Failed write keeps prior | `quality.md forced fail` | **pass** | #402's **Save durability** row on `c5b8189` is `pass`, and this folder's own `logs/fw1-forced-write.json` independently agrees: prior commit `last_mode: "shared"`, `setItem` made to throw, one failed write, document byte-identical, `last_mode` still `shared`, build logs `PersistStore: write failed; prior commit kept` at 10.947 s, play continues (`screenshots/store-04-play-continued.png`) |
| Cold open includes sync read | `quality.md timed cold open` | **fail** | Same reading as ADR-0001 *Cold open ≤3 s*: 3039–4394 ms, 4/4 |
| Persist failures in logs | `quality.md log check` | **pass** | #402's **Save durability** row's forced-failure step, plus this folder's own run: exactly one `PersistStore: write failed; prior commit kept` line and the UI surfaces it (`logs/fw1-console.log`, `screenshots/store-04-play-continued.png`: *"Save failed. Prior values kept."*) |

**#402 citation source for these rows**: `docs/playtest/evidence/issue-402/graphical-20261025T031500Z/manifest.md`
(commit `161b4a9`), which re-read the rows on the **same published build** `c5b8189` / run
`40118381611` as this folder. Its totals there: 2 `pass`, 1 `fail`, 7 `not-judged`.
Where it judged a row, this folder inherits the verdict and the reason; where it did not, the
row is `not-judged` rather than re-timed into a `pass`.

## Row results — ADR-0004 and ADR-0005 recorded here

### ADR-0004 (`specs/adr/decisions/0004-dual-playtest-environments/non-functional.md:61-63`)

| Check | Method (quoted) | Result | Evidence |
|---|---|---|---|
| Observability story IDs | `quality.md playtest check` | **not-judged** | Evidence owner **#400** (not run; its sweep evidence is untracked working-tree only, not a landed record). Story IDs exist only in the playtest build (ADR-0004, `H1`); a release build emits no `TEL.*` by specification (#729) |
| 60 fps with playtest I/O | `quality.md frame-time capture` | **not-judged** | Needs the playtest build, where playtest I/O is compiled in. The release build's idle window measured ~33 ms median, so this row is not judged on it. Read once for the same `quality.md` Performance measurement as ADR-0001/0002's move rows, which are `not-judged` on this host for the same reason |
| Sessions without engine-forced exit | `quality.md Reliability sitting soak, in the Headless and Graphical playtest builds` | **not-judged** | Evidence owner **#400** (not run); needs both playtest builds |

### ADR-0005 (`specs/adr/decisions/0005-asset-catalog-roots/imposes-validation.md:55`)

| Check | Method (quoted) | Result | Evidence |
|---|---|---|---|
| Roots not mixed | `Review of this ADR, ACC.P1–P2, and specs/technical/asset-access.md` | **pass (fresh Review)** | Below |

**Roots not mixed — Review evidence at `c5b8189`.**

- **P1** (`specs/assets/access.md:20` — *"The asset root (ADR-0005) holds only cataloged asset files and
  the engine's import sidecars."*): `game_assets/` holds **38 asset files plus its `.gitkeep`** across
  `board-backgrounds/`, `fonts/`, `icons/`, `interface-art/`, `music/`, `piece-sprites/`,
  `sound-effects/`. The set of files on disk and the set named by the 32 catalog entries' `files`
  are **the same 38** — `on disk but not cataloged: []`, `cataloged but missing: []`. Extensions:
  12 `.png`, 11 `.svg`, 7 `.ogg`, 5 `.woff2`, 3 `.txt` (the three OFL licence texts, each named in
  its font entry's `files` and `license.proof`). No `.import`/`.uid` sidecar is committed, which is
  consistent with P1 rather than a breach of it.
- **P2** (`specs/assets/access.md:21` — *"Engine resources and build outputs live outside the asset
  root (ADR-0005), are not cataloged, and are listed in the technical counterpart."*):
  `game/project.godot`, `game/asset_manifest.json`, `.godot/` and `build/web/` are all outside
  `game_assets/`, and **no catalog entry names them**. No `.gd`/`.tscn`/`.pck`/`.wasm`/`.godot`
  file exists under `game_assets/`.
- **R1 / O2** (`specs/technical/asset-access.md:13`, `:28`): `game/asset_manifest.json` is committed,
  outside both roots, `asset_root: "game_assets"` with **32** assets, and is **byte-identical to a
  fresh generation from `asset_catalog/`** — generated, never hand-edited. `asset_manifest.py
  --check` → **0 errors**.
- **R2** is cited, not re-run: the resolver's manifest-by-asset-ID behaviour is covered by
  `game/asset_resolver_test.gd`. **R3** (unresolved ID in a Release build skipped, session
  continues, one log line) is a Release-build observation and belongs to #654's *Sitting survives a
  failed resolve* record — named as handed off, not claimed here.
- `asset_catalog/` itself holds the 32 entry JSONs plus `.gitkeep`; no asset file sits in it.

**Verdict: `pass` for `ACC.P1`, `ACC.P2`, and `R1`/`O2`'s generation and currency.** The numbers
match the write-time measurement recorded on #403 (32 entries / 38 files / 0 missing / 0 errors).

## Rows named but not recorded here (named with their owner)

| ADR | Check | Recorded by | Today's outcome |
|---|---|---|---|
| 0002 | No client Stockfish endpoint | **#560** (definition) — run result here | `not-judged` — `scan_release_bundle` absent |
| 0002 | Move while advice in flight (playtest half) | **#400** | `not-judged` — #400 has not run |
| 0004 | Observability story IDs | **#400** (evidence) — recorded here | `not-judged` — #400 not run, #729 |
| 0005 | Sitting survives a failed resolve | **#654** | `not-judged` — handed off; R3 half |
| 0005 | 3 s open with boot/play groups | **#654** | `not-judged` |
| 0005 | Piece/font readability | **#654** | `not-judged` |
| 0005 | Locale font coverage | **#654** (#566 path) | `not-judged` |
| 0009 | Board playable within 3 seconds on the public URL | **#654** | build now serves a repaired release; COLD OPEN 3039–4394 ms ⇒ `fail` on the 3 s bar |

Arithmetic: **14** recorded here (5 ADR-0001 + 3 ADR-0002 + 4 ADR-0003 + 3 ADR-0004 + 1 ADR-0005)
+ **20** assigned to #654 + **1** #560 + **1** #400 = **36**.

## Defects

Filed from this run and linked back to #403 — see the record comment's *Defects* list.
