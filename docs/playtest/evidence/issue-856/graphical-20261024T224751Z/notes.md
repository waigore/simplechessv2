# Notes — #856 cold-open layers

**What was judged:** nothing in the story rows. This run establishes *where* the release
build's cold open spends its time ([`readings-cold-open-layers.md`](readings-cold-open-layers.md))
and tests whether a page-level change shortens it ([`trials.md`](trials.md)). The `≤ 3 s` bar is
[`quality.md`](../../../../../specs/definition/quality.md) Load time.

**Headline:** the bar is met or missed by one phase — the shell's WebGL2 capability probe,
which costs 0.04 s with a warm GPU process and 1–3.6 s while it initialises on the software
rasteriser. Neither moving that probe after `startGame()` nor preloading the wasm and pack
moves the first painted screen beyond run-to-run noise (see the table in the readings), because
the pack download already starts within 1 ms of the probe returning.

**Why nothing was fixed in this PR:** the two changes within reach of the issue's scope — a
custom shell that starts the engine before the probe, and preload links — both measure as
no-ops on this build, and a page change that only sometimes helps (and that would cost a
maintained custom shell plus an export check) is not a fix. The residual is the 39.5 MB wasm
download (10.2 MB gzip on Pages) plus the probe on a cold GPU process; both are outside
`game/` application code.

**The lever that would matter, left for a scoped issue:** 6.3 MB of the 9.6 MB pck is the two
ambient beds, which `AST.G3` keeps off the cold open. They are packed as imported
`.oggvorbisstr` resources; ADR-0014 records the packed route. Serving them loose would shrink
the cold-open pack by ~65 % without a decompress step — an ADR change first, then an export
change.

**Marks (non-blocking):**

- The measurement harness needed one correction to be trustworthy: `Runtime.consoleAPICalled`
  timestamps are not on the page clock, and mixing them with `performance.now()` mis-read the
  same runs by ~1.2 s. Both runners now stamp console lines in-page instead.
- `--use-angle=swiftshader` hides `rel=preload` fetches from Resource Timing; only the aligned
  runner can read the preload arms.
- Absolute times here are inflated by host load (25–28 on 10 cores). Arms are compared only
  with arms taken minutes apart.
