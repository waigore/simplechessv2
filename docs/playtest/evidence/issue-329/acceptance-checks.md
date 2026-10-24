# Issue #329 — client failure path and clean-tree checks (2026-10-24)

Index and input notes: [acceptance.md](acceptance.md). Deploy path, wire
contract, and release bundle:
[acceptance-served-slice.md](acceptance-served-slice.md).

## 1. Client failure path (`F-puzzle-catalog` X2)

`game/puzzle_stream.gd` `poll()` sends a non-`ok` outcome to `refused()`, which
never calls `session.deal()`; `leave()` (K4) drops an owed deal. The Elo is held
by the session and is untouched on both paths. Exercised server-side through
the `400` / `401` / `503` no-record responses (wire contract in
[acceptance-served-slice.md](acceptance-served-slice.md)).

## 2. Unit tests and lint (clean tree)

- `python3 -m unittest discover -s advice_backend/tests -t .` → **68 tests, OK**
- `python3 .github/scripts/spec_lint.py` → **0 errors, 1 warning** (pre-existing
  `specs/view/glossary.md` duplicate `Diagram`)
