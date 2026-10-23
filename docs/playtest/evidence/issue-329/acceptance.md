# Issue #329 — acceptance probes (2026-10-24)

Acceptance testing: the checks judged in the verification comment, reproduced
from a clean checkout of `origin/main` (`a68640a`; the round-2 deliverable PR
#579 / `3e549da` is merged). No playable behaviour is involved, so no headless
or graphical playtest applies.

Inputs: a 3-record slice written for this run (`advice_backend/` never carries
the export, ADR-0008), player Elo 1480, `CFG` defaults (match range 100, widen
50, recent window 20).

Served-slice probes — deploy path, wire contract, release bundle, client
failure path, and clean-tree unit tests/lint — are in
[acceptance-served-slice.md](acceptance-served-slice.md).

## 1. `select_puzzle` / `DIF.Y1` (probe script, `PYTHONPATH=<clean tree>`)

| Probe | Expected | Got |
|---|---|---|
| unseen 1680 vs solved-on-last-deal 1480 | unseen | `unseen` |
| recent 1570 (in band) vs unseen 1591 (one widen step out) | unseen | `unseen` |
| unseen 2480 vs solved one deal ago 1480 | unseen | `far` |
| two unseen at 1400 / 1500 | nearest | `b` (1500) |
| only a recent record available | deal it, never None | `r` |
| empty snapshot | None | `None` |
| 25 solved ids, the 25th back outside the window | fresh | `target` |
| `recent_window` 0 | nothing recent | `r` |

## 2. Integrity checks (`python3 -m advice_backend.catalog check`)

| Snapshot | Result | Exit |
|---|---|---|
| served-count gate, 3-record slice | `I1: expected 6157341 records, found 3` | 1 |
| 3-record slice, `--expected-count 3` | (no findings) | 0 |
| one row with `Moves` = `e2e4` | `row 0: s1: fewer than two moves` | 1 |
| one row with `mateIn1` and three moves | `row 0: s1: mateIn1 needs exactly two moves` | 1 |

## 3. Not recorded here: I1 against the real 6,157,341-record snapshot

The Lichess export is host-side (ADR-0008); the repository holds no snapshot
bytes. The checks above show the I1 gate enforced at the served count and
passing at a slice's own count, but the operator run on the host is still open:

```bash
python3 -m advice_backend.catalog build <lichess-export.csv> <snapshot.json>
python3 -m advice_backend.catalog check <snapshot.json>   # PUZZLE_CATALOG_EXPECTED_COUNT unset
```
