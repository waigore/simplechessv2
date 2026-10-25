# Drive — how the run reached the screen

- **Entry and leave** through the shipped controls: `mode-pick` `C2` and
  `puzzle-play` `C3` / `C4` / `C5` / `confirm`.
- **Moves** through `SessionRouter.handle_input_commit()` (select, then place) — the
  same gesture path the board uses.
- **The deal** through the production stream: `PuzzleStream.request()` →
  `CatalogDealClient` → `Accept768CatalogPeer` → `PuzzleStream.poll()` →
  `PuzzleSession.deal()`. Earlier puzzle evidence injected records with
  `deal([...])`; this run does not, so S4's `recent_solved` and S5's widen are
  observed on a real catalog read.
- **The peer** answers every read from a queue, and holds a read open when the queue
  is empty — that open read is the X2 case. It carries `recent_solved` from the O1
  message, so S4 checks what the session *asked for*, not only what came back.
- **The persisted document** is `PersistStore.memory_backend`, the store's own path.

## Deal order under S4

S4's step asks that a solved id inside `CFG.ELO_RECENT_WINDOW` is not dealt. The run
checks both halves: the O1 request the session sent carries the solved id in
`recent_solved`, and `PuzzleProgression.candidate_set` — the function `deal()` itself
calls, at the session's live Elo and recent list — returns only the unsolved member.
One offer in this run (`accept768-s1`) was already solved, so it is skipped, as `I1`
requires.
