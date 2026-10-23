# Notes — issue #528 headless run

## What was judged

The defect's playable deliverable is the client deal read on the production path: the
browser asks the catalog service for one puzzle, validates the one record, hands it to
`PuzzleSession.deal()`, and a failed read deals nothing. `PTD-puzzle-stream` covers the
deal, the reset, the advance, and leave; `PTU-puzzle-session` / `PTU-puzzle-play` cover the
journey and the screen's controls. All of it was driven through `main.tscn` and
`SessionRouter`, never by constructing a session by hand.

The service stand-in is the ADR-0013 Testability peer the seam build already installs
(`FakeCatalogTransport`), so no key travels over a network in this run. Its shipped form
never answers, which gives the "unresponsive catalog" case for free; each scripted case
first retires that unanswered entry read through the stream's own S4 path.

## What passed

- One request per deal; the request carries `player_elo`, at most `ELO_RECENT_WINDOW`
  recent ids, and the configured key; one record is validated and dealt unchanged.
- All five O2 reasons behave as X2 asks: nothing dealt, `GS.puzzleId` none, `GS.playerElo`
  unchanged, reason readable by the caller (`PuzzleStream.last_failure`) and carried to the
  screen as `puzzle.deal_failed` telemetry.
- The reader refuses a list body, a file body, a missing field, a wrong-typed field, a
  foreign `snapshot_id`, an unmarked mate, and a one-move record.
- A Wrong move keeps the same puzzle and sends no request; finishing that attempt settles
  `L4`, never `W1`. A clean attempt settles `W1` and owes exactly one next deal. Reveal
  settles `L5` and deals the next record.
- Leave retires an in-flight read in ~1.2 ms against a 3000 ms cap, applies no Elo penalty,
  returns to mode-pick, and the retired record never deals — including with a real socket
  that accepts and never answers (`logs/real-socket-retire.log`).

## Observations, not findings against #528

1. **No screen-level exit while a failed read leaves the puzzle screen empty.** With no open
   puzzle, `PuzzlePlayFlow.control("C5")` reaches `PuzzleSession.request_confirm`, which
   refuses (`has_open_puzzle()` false), so Leave does nothing. The panel itself reports C5
   available (`control_available`: `ui_state != "S2" and != "S4"`), so the button is enabled
   and inert. This is the puzzle-play screen's failure state, owned by #333 (still
   `status:pending-verification`), not this defect's read. #528's AC3 asks only that the
   failure be observable to the caller, and it is.
2. **The `4 ObjectDB instances leaked at exit` warning is pre-existing.** A baseline that
   mounts `main.tscn`, detaches `PlaytestHarness`, runs 30 frames, and quits — no deal read
   at all — prints the same warning (`logs/baseline-30-frames.log`, graphical twin too).
   The prior verification also saw it on `63f744c`. Unrelated to this defect.
3. **`CatalogDealTransport.reap()` was not needed to avoid a stuck worker here.** The 2026-10-23
   verification's `[CONT]` note said a retired worker stays alive until the next deal read.
   In this run, after the 3000 ms cap with no later `start()`/`close()`, `_retiring` was
   empty and the process exited with no "resources still in use" line
   (`logs/real-socket-retire.log`). The behaviour the note worried about did not reproduce;
   it is recorded, not filed.

## Environment

- Headless `ENV.1` only. The same drive ran with a window for the UX halves; see
  `../graphical-20261023T212229Z/`. The graphical captures carry the playtest debug layer
  because a seam build mounts it (`PlaytestSeams`, G2 keeps it out of `main_release.tscn`).