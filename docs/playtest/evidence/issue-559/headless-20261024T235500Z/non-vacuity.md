# Non-vacuity — #559

`mutations.py` breaks one behavior at a time in a scratch copy of a main script,
runs `game/advice_readiness_test.gd` headless against it, restores the file, and
keeps the FAIL line. A mutation that still passes would mean the test is not
measuring its claim. All four fail (`logs/mutations.log`):

| Mutation | Observed |
|---|---|
| `start()` waits for the first answer | `repeat 0: start must return before any update exists (anti-tautology)` |
| `T6` ignored, always 3500 | `T6 500 must be sent as O1 time_ms (R7), sent 3500` |
| move path waits 120 ms on the stream | `a local move waited 130 ms on advice (ceiling 40, I1)` |
| move path stalls 300 ms | `a local move waited 312 ms on advice (ceiling 40, I1)` |

The 300 ms row is why the move ceiling is 40 ms and not the observed 0 ms: a slow
move fails too, not only a hung one. The first mutation also fails under the
`Coverage` job's instrumented build
(`logs/coverage-with-start-waiting-mutation.log`), the build CI measures.
