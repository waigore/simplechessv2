# Setup — deal source and probe seam

## Deal source

The production path. `PuzzleStream.request()` →
`CatalogDealClient` → `Accept768CatalogPeer` (an answer-capable peer on the shipped
`FakeCatalogTransport` seam, ADR-0013 Testability) → `PuzzleStream.poll()` →
`PuzzleSession.deal()`. The record comes from a real catalog read carrying
`player_elo` and `recent_solved`, not from `deal([...])` injection. The persisted
document is the store's own memory backend.

## Probe seam

11 lines added to `game/session_router.gd` install the peer through
the existing `_puzzle_sim_factory()` hook (`probe/session-router-install-seam.diff`).
No product behaviour is changed; `game/puzzle_play_flow.gd` and every Domain file are
byte-identical to `origin/main`.
