# #655 implementation pass (parallel id 5) — the empty-value guard now says so

Dispatcher: `issue-workflow-implement-agent`, unattended, `Assigned issue: 655`.
Status asserted at start: `status:pending-implementation` on `type:defect`.
Base: `origin/main` `689d1f6`. Godot `4.7.2.stable.official.ed1daf0bf`.

## What changed

`PuzzleStream.request()` reported `B5`'s empty-value guard with
`CatalogWireReader.REASON_STATUS` — the *same* reason a read the client actually sent
reports when its status is not successful. Every `#550`-family log therefore read
`puzzle stream: deal read failed (status)` whether or not a request ever left the
browser. That is exactly the ambiguity AC2 forbids: *"No refusal is `B5`'s empty-value
guard."*

- `game/catalog_wire_reader.gd` — `REASON_UNCONFIGURED = "unconfigured"`.
  `CTR-puzzle-catalog-read` O2 names no reason vocabulary and `FAIL.T14`'s Effect column
  names no reason, so this is a client-internal label and no `specs/` text moves.
- `game/puzzle_stream.gd` — `request()` checks `client.is_available()` before starting,
  and refuses with `REASON_UNCONFIGURED` instead of `REASON_STATUS`. The `started()`
  guard is unchanged; an available client that refuses to start still reports `status`.
- `game/puzzle_stream_test.gd` — the existing `B5` check now asserts the reason.

## What this does not do

It does **not** deliver `T9`/`T10`. Criteria 2, 3 and 6 of this defect are unchanged:
the pair is still `""` in the tree (`T10`: never committed), no pipeline step writes one
into a published bundle, and `#648`'s posture question is still open. This pass makes
the guard's presence measurable by language instead of inference, so the next `#550`
sweep and the next verify pass can distinguish *never sent* from *sent and refused*.
