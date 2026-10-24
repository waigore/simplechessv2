# Manifest — #626 phone-browser sitting and durability reading

- **Issue**: #626 — run #558's sitting soak and #557's durability legs on a phone browser
- **Environment**: `graphical` (`ENV.2`), **not obtained** — no phone browser was reachable from the dispatch host
- **Build / session id**: published `c5b8189`, `Web release` run **`40118381611`** (see [build-resolution.md](build-resolution.md)). No `TEL.3` session id: the `Web Release` export strips the seam (ADR-0004 `G2`, #729); none is recorded and none is invented — this issue asks for the id, and its absence here is the same absence #625 records, not a second gap.
- **Timing (`SIT.4`)**: none. No load-to-mode-pick or frame-time sample was taken on a phone; a desktop software-WebGL sample is not a device reading.
- **Coverage mode**: `critical-only`, and **zero** rows selected for reading — see *Why no row was read*.
- **Cited design/UX protocol**: none in scope. This is the device reading of the `quality.md` Reliability and Save durability rows plus #558's Advice-Off leg.

## Why no row was read

This issue's readings are defined by the device they are taken on: a **phone browser at a café table**, with the tab backgrounded and left long enough for the mobile OS to suspend or discard it. Every one of its preconditions is a property of hardware the agent does not hold:

| Precondition (issue *Reproduction steps*, ACs) | State at dispatch |
|---|---|
| iOS Safari **and** one Chromium mobile browser on a physical phone | **Not met** — the dispatch host is the project's macOS development machine (Apple Silicon); no phone is attached to it, and iOS Safari does not exist anywhere off an iOS device |
| A host the phone can reach for the fallback export (LAN or tunnel) | **Moot** — the published URL already serves the repaired commit, so the fallback is not used |
| A 15–40 minute wall-clock sitting with real background/foreground interruption | **Not met** — an agent run cannot sit at a café table; a scripted suspension in a desktop browser is not what a mobile OS does to a backgrounded tab, and recording it as the mobile behaviour would be the desktop extrapolation this issue exists to end |
| `localStorage` read "with the method the mobile browser allows (not a desktop devtools path)" | **Not met** — any reading taken here is necessarily the desktop devtools path the AC excludes |

Driving the published build in headless Chrome (the method #402 and #557 used) was deliberately **not** done for these rows: on this host it produces a desktop, software-rendered reading — exactly the reading *Actual behaviour* says must not stand in for the mobile rows. A `not-judged` from that method would also be indistinguishable from the seat's real `not-judged`, which would blur what the record can and cannot say.

## Results

Not one row is judged. Per `specs/playtest/evidence.md`, `not-judged` never counts as `pass`.

| Row | Method the phone would use | Build read | Verdict |
|---|---|---|---|
| Reliability — sitting soak, crash-free 15–40 min with ≥1 background/return | continuous sitting, wall-clock start/end, interruption log | published `c5b8189` (resolved, not opened) | `not-judged` — no phone browser; no sitting ran |
| Reliability — tab discarded / resumed / lost on return | background the browser, use another app, return | published `c5b8189` (resolved, not opened) | `not-judged` — no phone browser |
| Reliability — reopen at mode pick with committed Player Elo and Last mode | quit/reopen inside the sitting; read values with the browser's own UI | published `c5b8189` (resolved, not opened) | `not-judged` — no phone browser |
| Save durability — background/return and quit/reopen keep committed values | same sitting, per #557's legs | published `c5b8189` (resolved, not opened) | `not-judged` — no phone browser |
| Advice-Off observed on that browser (`PTU-shared-play` S3 driving step) | Advice Off, make a move, no marks; then offline + Advice On | published `c5b8189` (resolved, not opened) | `not-judged` — no phone browser |

**Totals: 0 `pass`, 0 `fail`, 5 `not-judged`.** No `type:defect` is filed: this issue's rule files a defect for every **failing** row, and none was read.

## What this run does establish

The **Build under test** half of AC 1 — which build a phone run should open, and whether the export fallback applies — is answered and recorded in [build-resolution.md](build-resolution.md): the published URL serves `c5b8189`, which carries #647's repair, and `Deploy to Pages` is green, so **no fallback export is used**. A completing run does not have to re-derive it.

Nothing else is claimed. #402's accepted record is **not** touched: no row was re-read, so there is nothing to supersede and no re-read comment was posted.

## Paths

- [build-resolution.md](build-resolution.md) — the Build under test field, with the measurements behind it
- [notes.md](notes.md) — judgement text, the device gap, and what would complete the issue
- `screenshots/`: none — no phone browser, so none could be captured (marked waiting, not a fail per `specs/playtest/evidence.md` *Headless run*)
- `logs/`: none — no session ran to capture a console from

## Defects

- None filed by this run. The blocker here is device access at execution time (hardware, a café-grade network, a seated person), not a game or interface behaviour, so it has no `quality-regression-owners.md` row to belong to.

## Seat

The rows seat on **#626 itself**. #402's record already marks the sitting soak `not-judged` with its seat named (#558); this run neither replaces that seat nor adds a second one.
