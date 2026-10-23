# Headless notes — #550

Wave-2 sweep on `origin/main` `614746c`, Godot `4.7.2.stable.official.ed1daf0bf`, `ENV.1`.

## Prep

Import, headless smoke, 25 unit tests, 86.4% coverage (threshold 80), `gdformat`/`gdlint` clean, `spec_lint` clean — each in `logs/`.

## Story rows

#481's story-to-protocol map is `status:pending-review` and not on `main`, so rows were derived from each protocol file's `Cites` line per [`procedures.md`](../../../../../specs/playtest/procedures.md) step 2. A later sweep should copy #481's rows instead.

## The finding

`C2` opens the journey correctly, then the first deal refuses:

```
WARNING: puzzle stream: deal read failed (status)
    at: refused (res://puzzle_stream.gd:97)
    [2] enter (res://puzzle_play_flow.gd:44)
    [3] _enter_puzzle_play (res://session_router.gd:729)
```

`CatalogDealClient.is_available()` requires `T9` and `T10` (`B5`), and both are `""` here (`endpoint= key_set=false`). Nothing in the shipped path assigns them. This is the state #648 recorded; the sweep files it as **#655**, with the delivery mechanism pending on #479.

So `PTD-puzzle-stream` fails at K1 and `PTU-puzzle-play` fails at US1. The other puzzle rows are `not-judged`, not `pass`: with no open attempt there is no reset, no `END.L4`, no reveal, no abandon, no leave-confirm to judge.

## Why it is the build, not the driver

`probe/accept550_seam_crosscheck.gd` sets `T9`/`T10`, cancels the refused read, and supplies one `SCH-puzzle-catalog` record: `X550 RESULT deal=true`. The same path deals once the values exist, so the `fail` isolates the missing `T9`/`T10`. That is a seam build, not protocol evidence.

Independently, `puzzle_session_test` (in the 25 passing) exercises K2–K4, `END.L4`/`L5`/`L6`, `DIF.Y1`, and the `PRG.M1` commit on this same `main`. The behaviour is implemented; this build cannot reach it through the player-facing path, which is why those rows are `not-judged` rather than `fail`.

## Graphical twin

The UX protocols in scope are headless and graphical; the graphical half and its screenshots are in `../graphical-20261024T000000Z` on this build. `PTU-mode-pick` S6 (`SIT.6` phone width) is not re-judged: the post-boot reflow it needs is #546's open finding.

## Not fixed here

Per [`procedures-outcomes.md`](../../../../../specs/playtest/procedures-outcomes.md) the gate never fixes its own finding. #655 is filed against the wave that owns the behaviour; no `game/` file changed.
