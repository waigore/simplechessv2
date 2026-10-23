# Issue #329 — catalog service evidence

Server-side only: no playable behavior changed, so no headless or graphical
playtest applies (`docs/playtest` §What needs evidence).

## Unit tests

`python3 -m unittest discover -s advice_backend/tests -t .` — 60 tests, OK
(`unit-tests.log`). 33 of them are `test_catalog_service.py`:

- **I1–I3 gate** — record count, moves length, and the mate-in-one mark are
  checked by `python3 -m advice_backend.catalog check`; a failing snapshot
  exits 1 and `build` publishes nothing when a row is refused.
- **`DIF.Y1`** — nearest rating inside ±`CFG.ELO_MATCH_RANGE`, recent-id
  preference, widening by `CFG.ELO_BAND_WIDEN`, allowing a recent id, and the
  `CFG.ELO_RECENT_WINDOW` bound.
- **Route** — one record per deal (never a list or page), `401` for a missing
  or wrong key, `400` for a malformed request, `503` for a rapid-fire refusal
  or an unconfigured catalog, `404` for every non-deal path, and the advice
  route still working beside it.
- **Rate limit** — the 30th request per key per minute is the last allowed;
  counts are per key and recover a minute later.

## Integrity check on the real snapshot

Not run in this session: the 6,157,341-record Lichess export is not in the
repository (ADR-0008 keeps it host-side). The check that must be recorded
against the served snapshot on the host is:

```bash
python3 -m advice_backend.catalog build <lichess-export.csv> <snapshot.json>
python3 -m advice_backend.catalog check <snapshot.json>
```

`check` reports I1 (6,157,341 records), I2 (every `moves` length ≥ 2), and I3
(`any_checkmate_wins` iff `mateIn1`, then `moves` length 2). Against a
deliberately short snapshot it exits 1 with `I1: expected 6157341 records,
found N`, which is the failure this session verified.

## Verification round 2

Fixes for the failed verification (DIF.Y1 recent-id order and the slice-exercisable deploy path) are in [`verification-round-2.md`](verification-round-2.md).
