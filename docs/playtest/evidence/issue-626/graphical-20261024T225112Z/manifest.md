# Manifest — #626 phone-browser sitting and durability reading

- **Issue**: #626 — run #558's sitting soak and #557's durability legs on a phone browser
- **Environment**: `graphical` (`ENV.2`), **not obtained** — no phone browser was reachable from the dispatch host
- **Build / session id**: published `c5b8189`, `Web release` run **`40118381611`** ([build-resolution.md](build-resolution.md)). No `TEL.3` session id: the `Web Release` export strips the seam (ADR-0004 `G2`, #729); none is recorded and none invented.
- **Timing (`SIT.4`)**: none. No load-to-mode-pick or frame-time sample was taken on a phone; a desktop software-WebGL sample is not a device reading.
- **Coverage mode**: `critical-only`, zero rows selected for reading ([preconditions.md](preconditions.md)).

Driving the published build in headless Chrome (the method #402 and #557 used) was deliberately **not** done: on this host it produces a desktop, software-rendered reading — exactly the reading *Actual behaviour* says must not stand in for the mobile rows.

## Results

Not one row is judged. Per `specs/playtest/evidence.md`, `not-judged` never counts as `pass`.

| Row | Method the phone would use | Build read | Verdict |
|---|---|---|---|
| Reliability — sitting soak, crash-free 15–40 min with ≥1 background/return | continuous sitting, wall-clock start/end, interruption log | `c5b8189` (not opened) | `not-judged` — no phone; no sitting ran |
| Reliability — tab discarded / resumed / lost on return | background the browser, use another app, return | `c5b8189` (not opened) | `not-judged` — no phone |
| Reliability — reopen at mode pick with committed Player Elo and Last mode | quit/reopen in the sitting; read values with the browser's own UI | `c5b8189` (not opened) | `not-judged` — no phone |
| Save durability — background/return and quit/reopen keep committed values | same sitting, per #557's legs | `c5b8189` (not opened) | `not-judged` — no phone |
| Advice-Off observed on that browser (`PTU-shared-play` S3 driving step) | Advice Off, make a move, no marks; then offline + Advice On | `c5b8189` (not opened) | `not-judged` — no phone |

**Totals: 0 `pass`, 0 `fail`, 5 `not-judged`.** No `type:defect` is filed: this issue's rule files a defect for every **failing** row, and none was read.

## What this run does establish

The **Build under test** half of AC 1: the published URL serves `c5b8189`, which carries #647's repair, so no fallback export is used ([build-resolution.md](build-resolution.md)). A completing run need not re-derive it. Nothing else is claimed; #402's accepted record is **not** touched, since no row was re-read.

## Paths

- [build-resolution.md](build-resolution.md) — the Build under test field and its measurements
- [preconditions.md](preconditions.md) — precondition table and what a completing run needs
- [notes.md](notes.md) — judgement text and what was deliberately not changed
- `screenshots/`, `logs/`: none — no session ran (marked waiting, not a fail, per `specs/playtest/evidence.md` *Headless run*)

## Defects and seat

None filed: the blocker is device access at execution time, not a game or interface behaviour, so it has no `quality-regression-owners.md` row. Rows seat on **#626 itself** ([notes.md](notes.md)).
