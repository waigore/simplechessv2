# Notes — #879 acceptance run

## What this run judged

Whether the published Web build activates the two mode-pick controls when a press lands **inside
them** — the defect's expected behavior — using the published client the issue and the
implementation leg both measured. Rows: `PTU-mode-pick` P1/P2/P4 (S1–S3) and the `PTU-controls` P3
pointer rule on `mode-pick`. Read the [manifest](manifest.md) first for environment and build.

## How

- Fresh browser profile, so `localStorage` starts empty: the cold open is a real first visit.
- The mode-pick frame was captured and is committed
  (`screenshots/mode-pick-published-00.png`, sha256 `c20b06d2ce78…4b90`). It is **byte-identical**
  to the frame the issue cites (`boardtap-69a03d4-00-mode-pick.png`) and to both legs of the
  implementation re-measurement.
- The controls' boxes were re-read here from that frame (`scripts/boxes.py`): C1 y 144.83–181.67,
  C2 y 185.83–223.00, seam y 181.67–185.83, panel x 87.3–302.3.
- The arm logs of `../graphical-20261025T005759Z/` were re-derived, not taken on trust: per arm the
  `preSha`/`postSha`, `advanced` flag, `last_mode` and gesture list were cross-checked against each
  other and against the committed screenshots' digests ([readings.md](readings.md)).
- The deployment was checked by HTTP headers at acceptance time (same `index.pck` size and
  `last-modified` as the implementation leg).

## The capture that did not complete

A live acceptance capture of the presses themselves was attempted repeatedly on this host and
could not be completed: Chrome 156 here detaches a CDP session when the Godot page reloads itself,
and the capture aborted mid-run each time. The cold-open frame was captured and is committed
(`screenshots/mode-pick-published-00.png`, `c20b06d2…`, empty `localStorage`). The press readings
come from the arm logs of `../graphical-20261025T005759Z/`, whose frames, digests and per-arm
fields were independently re-derived here (see [readings.md](readings.md)). This limit is recorded
rather than papered over.

## Limits

- Headless Chrome with CDP dispatch, not a physical phone. A phone-only delivery fault is not
  excluded, but no reading on record requires one.
- `PTU-mode-pick` S5 (Switch locale), S6/P5 (phone-width legibility) and P3, and `PTU-controls` S6,
  are `not-judged` here: they are outside this defect's delta.
