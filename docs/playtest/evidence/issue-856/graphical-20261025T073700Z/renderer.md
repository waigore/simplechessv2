# The software-rasteriser cross-check

Under `--use-angle=swiftshader` the same builds take 3.9–9.7 s (published) and 5.2–5.6 s
(fix export). That is the `ENV.3` arm the defect was filed from, and it is reproduced here —
but it is a cross-check, not the judging leg. Its first WebGL2 context alone costs 0.25–5.5 s,
more than the whole hardware cold open, and the host load during those runs (17–24, against
5–11 for the hardware runs) makes the published and fix arms non-comparable against each
other.

A software rasteriser is not the environment a player opens the game in, `SIT.4` samples
timing "on Graphical, where a browser renders", and nothing in the playtest method names a
software rasteriser; so this run judges `P4` on `ENV.2` and records `ENV.3` as a cross-check.

**What this run does not settle:** whether the project also wants the bar held on software
rasterisation. That question is #402's Load time row and #403's ADR-0001 / ADR-0003 rows,
both `status:pending-verification`, and it is theirs to decide; this folder neither adopts
nor contradicts their `fail` verdicts, it records what the same builds do on the other
renderer. If software rasterisation is to govern, the remaining lever is the ~6.3 MB of
packed ambient beds (ADR-0014), not `game/`.
