# Notes — save durability — #626 mobile-browser sitting

The Elo caveat on the durability rows, and what a physical-phone run still owes. Rows in
[manifest.md](manifest.md).

## The committed-document reading

The committed document was read in the page's own origin store (`localStorage`, key
`simplechessv2.persist.v1`) after each cycle — never through a desktop devtools path.

`last_mode` is the value a quitting session commits, and it survived every cycle unchanged. The
**Elo half stays at its starting `1000`** because nothing on this build can change it: Elo moves
only at a puzzle-result commit (`SEQ-puzzle-result-commit`), and the release build deals no
puzzles (**#655**, open). So this run shows that a committed document survives the three
mobile cycles; it does not show a *changed* Elo surviving them, because no Elo change can exist
on this build. #557's leg 1 records the same limit from the desktop side.

## What a physical-phone run still owes

Tab discard, `localStorage` eviction under device storage pressure, OS suspension, and a real
network's latency. Those are the residual risk this run names rather than covers; they are
`not-judged` in the results table.
