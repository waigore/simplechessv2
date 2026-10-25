# Verdict — #879 acceptance run

The defect's expected behavior ("every press inside either mode-pick button activates it")
**holds** on the current published build ([readings](readings.md)). The "0 of 8" reading was not
activation loss: it was a press between two controls, which `specs/ux/controls.md` F1 says
activates nothing. No code change was needed, and the protocol rows the defect touches pass
([manifest results](manifest.md)).

## Independent checks made in this run (not taken from the implementation comment)

1. **The published frame is the issue's frame.** The cold-open frame this run captured is sha256
   `c20b06d2ce78…4b90`, byte-identical to `boardtap-69a03d4-00-mode-pick.png` cited by the issue and
   to the implementation leg's `published-00-mode-pick.png` and `export-00-mode-pick.png`.
2. **Box geometry, measured here from pixels.** `scripts/boxes.py` on that frame: painted panel rows
   at CSS y 24.5, 144.83, 181.67, 185.83, 223.0, 271.5 — C1 y 144.83–181.67, C2 y 185.83–223.00, a
   **4.16 px seam** between them; panel x 87.3–302.3 from a dark-row scan. The issue's 0/8 core
   point `(150,185)` and the export hold arms' `(195,185)`, `(240,185)` fall in that seam;
   `(60,185)`/`(330,185)` fall outside the panel's x range.
3. **The arm logs are internally consistent.** Every published-touch, export-touch and mouse arm has
   `preSha = c20b06d2…`, a post digest equal to the corresponding committed frame (`bbefbb38…` for
   C1, `bb8d41b1…` for C2) exactly when `advanced` is true, matching `last_mode`, and a page gesture
   log in every arm (`pointerdown`/`touchstart`/`pointerup`/`touchend`; `pointerdown`/`pointerup`/
   `click` on the mouse leg).
4. **The cited frames exist and agree.** The committed screenshots fetched from `origin/main`
   reproduce the digests in the arm logs: `published-01-shared-advanced` = `bbefbb38…`,
   `published-02-puzzle-advanced` = `bb8d41b1…`, `published-03-seam-150-185-unmoved` =
   `c20b06d2…`, `published-06-mouse-shared-advanced` = `bbefbb38…`.
5. **The deployment is current.** `curl -I` on `index.pck` during acceptance returned the same
   `content-length` the implementation leg measured (9 572 540 B) with `last-modified`
   2026-10-25T00:26:08 GMT.

## Defects

None filed. Every press inside a painted mode-pick control activated on the published build; the
presses recorded as lost are in the seam or outside the panel.

## What this run does not prove

- **No real phone.** All readings are CDP touch emulation at a 390×844 DPR-3 frame. A phone-specific
  delivery fault is not excluded; the seam explains every reading on record without one.
- **Not a bytes-level re-derivation of the pack.** The deployment was checked by HTTP headers and by
  the byte-identical frame, not by re-downloading and diffing `index.pck` against a local export; the
  implementation leg's `logs/pack-comparison.json` covers that (both 9 572 540 B, 158 routes,
  `index.html`/`index.wasm` identical).
- **S5/S6/P3/P5** of `PTU-mode-pick` and S6 of `PTU-controls` are not judged here.
- **Not a live press capture.** The press readings are the implementation leg's arm logs, re-derived
  here; see the capture limit in [notes.md](notes.md).

## Observations recorded and not judged as failures

The seam is `VBoxContainer` separation (design, not a hit-test bug); the painted control is 36.8 CSS
px tall at this viewport; the published console logs one `puzzle stream: deal read failed (status)`
warning per opened puzzle screen while the screen still paints and its controls work. None of these
is #879.
