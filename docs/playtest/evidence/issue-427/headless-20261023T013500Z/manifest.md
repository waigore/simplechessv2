# Manifest

- **Issue**: 427
- **Environment**: headless (autodrive) plus a graphical pass of the same build under Xvfb (`xvfb-run`, OpenGL3) for the frame measurements below
- **Build / session id**: Godot 4.7.2 stable (`logs/build-id.txt`)
- **Coverage mode**: demo task #63 rework; items 1, 3, and 4 of defect #427 verified at demo level
- **Screenshots**: `screenshots/exercise.png`, `screenshots/mate.png` — both from the same graphical autodrive run (`DEMO_SHOT_DIR`, outputs copied here)

## Results

| Check | Result | Measurement |
|-------|--------|-------------|
| Demo autodrive (headless, whole game) | pass | `logs/autodrive.log`: every scripted move inside the 150 ms budget, `[demo] PASS`, exit 0 |
| #427 item 1 — piece size | pass | Drawn body heights per square, before → after: rook 0.569 → 0.847, knight 0.625 → 0.847, bishop 0.625 → 0.847, queen 0.681 → 0.847, king 0.722 → 0.861, pawn 0.514 → 0.847 square units (`SPC.E1` = 0.85; the king reads 0.861 because its outline sits inside the old 0.85 canvas box, i.e. every body is now within 1.3% of the extent) |
| #427 item 3 — coordinates | pass | All eight file letters and all eight rank numbers present on the wooden lip in `PAL.C9`, never inside a square; measured ink contrast 2.36:1 on the shadowed lip and 4.86:1 on the lit lip — the lit-side placement meets `PER.R7`'s ≥ 4.5:1 |
| #427 item 4 — wooden bevel | pass | Lit lip (`PAL.C2`) on top and left, shadowed lip (deepened `PAL.C5`) on bottom and right, raised `PAL.C5` frame and dark outline outside; the band lies in the board's outer margin and covers no square |
| Asset catalog integrity | pass | `logs/asset-catalog.log`: 0 errors |

## Failures / open follow-ups

- **#427 item 2 (select cue)** is not changed here: the cue is a cataloged, approved, PO-confirmed SS1 anchor, and regenerating it needs the ElevenLabs CLI (not available in this run). Measured cause of the "jarring" report: the select cue's spectral centroid is ~5.6 kHz against the settle knock's ~1.4 kHz, with a lower peak (−7.1 dBFS vs −1.7 dBFS), i.e. it is brighter where the settle is woody. Follow-up: `manage-asset` `APR.update` of `01a151f8-b7d8-7ae6-84af-767ba53d09f6` with a low-passed, warmer woody body, then `review-asset` and a version bump.
- This is demo-level evidence for a defect on the demo build; main-code `verify-project-issue` and acceptance remain with their own sessions.

## Paths

- `manifests` — `manifest.md`
- `notes` — `notes.md`
- `logs` — `logs/build-id.txt`, `logs/autodrive.log`, `logs/asset-catalog.log`
- `screenshots` — `screenshots/exercise.png`, `screenshots/mate.png`
