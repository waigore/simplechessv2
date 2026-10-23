# Issue #329 — fixes for the failed verification
 — fixes for the failed verification

The first verification of #329 failed on two acceptance criteria. Both are
addressed here; the tests above still pass, and six new ones cover the fixes
(68 tests, OK).

### 1. `DIF.Y1` recent-id ordering

`select_puzzle` relaxed the band before the recent-id rule, so it walked band
0 over both groups, band 1 over both groups, and so on. A just-solved puzzle at
the player's Elo therefore beat an unseen one a single widen step away. Order
is now group-first: every unseen puzzle across every band, then — only once
widening has spanned the snapshot — the nearest recently solved one.

The three probes from the verification comment, re-run before and after:

| Probe (player Elo 1480) | Before | After |
|---|---|---|
| unseen 1680 vs solved-on-last-deal 1480 | `recent` | `unseen` |
| two records: recent 1570 vs unseen 1591 | `recent` | `unseen` |
| unseen 2480 vs solved one deal ago 1480 | `recent` | `far` |

Regression tests: `test_an_unseen_puzzle_outranks_a_just_solved_one_inside_the_band`,
`test_an_unseen_puzzle_one_widen_step_away_beats_a_tighter_recent_one`,
`test_an_unseen_puzzle_far_outside_the_band_beats_the_previous_deal`,
`test_the_nearest_unseen_puzzle_wins_once_the_band_spans_them_all`.

### 2. The deploy path is demonstrable on a prepared slice

`check_snapshot` and the `check` command take `expected_count`
(`--expected-count`), and the deploy script forwards
`PUZZLE_CATALOG_EXPECTED_COUNT`. Unset, I1 still requires the served
snapshot's 6,157,341 records, so serving the real snapshot is unchanged.

Ran from a clean checkout of this branch (`git archive` of `HEAD` into an empty
directory, plus the two changed files), with a 3-record slice:

```
$ ADVICE_API_KEY=k PUZZLE_CATALOG_CSV=slice.csv PUZZLE_CATALOG_PATH=snap.json \
    .github/scripts/deploy_advice_backend.sh
I1: expected 6157341 records, found 3        # exits 1 — the default gate holds

$ PUZZLE_CATALOG_EXPECTED_COUNT=3 ... .github/scripts/deploy_advice_backend.sh
snapshot snap.json: 3 records
INFO advice_backend listening on 127.0.0.1:8080 catalog_records=3

$ curl -X POST /catalog/deal -d '{"player_elo":1480,"recent_solved":["s1"],"api_key":"k"}'
puzzle_id: s2   (rating 1560 — the unseen puzzle, not the just-solved s1 at 1480)
$ curl -X POST /catalog/deal -d '{...,"api_key":"bad"}'
401
```

Regression tests: `test_a_slice_passes_i1_at_its_own_count`,
`test_a_slice_still_fails_i1_at_a_count_it_does_not_hold`,
`test_the_expected_count_defaults_to_the_served_snapshot`,
`test_the_check_command_accepts_a_slice_count`.

### Still open for acceptance

I1 recorded against the **real** 6,157,341-record snapshot remains an operator
run on the host, since the export is not in the repository (ADR-0008). The
command is the same one above with `PUZZLE_CATALOG_EXPECTED_COUNT` unset.
