# Notes — #879 acceptance run

## What this run judged

Whether the published Web build activates the two mode-pick controls when a press lands **inside
them** — the defect's expected behavior — using the published client the issue and the
implementation leg both measured. Rows: `PTU-mode-pick` P1/P2/P4 (S1–S3) and the `PTU-controls` P3
pointer rule on `mode-pick`.

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
  other and against the committed screenshots' digests.
- The deployment was checked by HTTP headers at acceptance time (same `index.pck` size and
  `last-modified` as the implementation leg).
- A live acceptance capture of the presses themselves was attempted repeatedly on this host and
  could not be completed: Chrome 156 here detaches a CDP session when the Godot page reloads itself,
  and the capture aborted mid-run each time. The cold-open frame was captured and is committed
  (`screenshots/mode-pick-published-00.png`, `c20b06d2…`, empty `localStorage`). The press readings
  come from the arm logs of `../graphical-20261025T005759Z/`, whose frames, digests and per-arm
  fields were independently re-derived here (see `readings.md`). This limit is recorded rather than
  papered over.

## Readings

| Check | Reading |
|---|---|
| Cold-open mode-pick frame | `c20b06d2…` — same bytes as the issue's cited frame; empty `localStorage` |
| Shared game, press (195,163), 200 ms, published | **6/6** activate → `last_mode` = `shared`; frame `bbefbb38…` |
| Puzzle stream, press (195,204), 200 ms, published | **6/6** activate → `last_mode` = `puzzle`; frame `bb8d41b1…` |
| Same grid on a local `Web Release` export of the same sha | **6/6 + 6/6** |
| Plain mouse, no touch emulation | **3/3 + 3/3** |
| Boundary sweep | (195,170) ✓, (195,180) ✓ inside C1; (195,187) ✓, (195,217) ✓ inside C2 |
| Seam / off panel | (150,185) — the issue's 0/8 core — (195,183), (40,163), (195,400): no change |

The issue's recorded failure point `(150,185)` lies in the **4.16 px seam** between the two controls
(C1 ends at 181.67, C2 starts at 185.83), and the export hold arms that did not act were also in the
seam or outside the panel. Every press inside a painted control activated.

## Consequence for the defect

The defect's expected behavior ("every press inside either mode-pick button activates it") **holds**
on the current published build. The "0 of 8" reading was not activation loss: it was a press
between two controls, which `specs/ux/controls.md` F1 says activates nothing. No code change was
needed, and the protocol rows the defect touches pass.

## Limits

- Headless Chrome with CDP dispatch, not a physical phone. A phone-only delivery fault is not
  excluded, but no reading on record requires one.
- `PTU-mode-pick` S5 (Switch locale), S6/P5 (phone-width legibility) and P3, and `PTU-controls` S6,
  are `not-judged` here: they are outside this defect's delta.
- Observations recorded by the implementation leg and **not judged** as failures: the seam is
  `VBoxContainer` separation (design, not a hit-test bug); the painted control is 36.8 CSS px tall
  at this viewport; the published console logs one `puzzle stream: deal read failed (status)`
  warning per opened puzzle screen while the screen still paints and its controls work. None of
  these is #879.
