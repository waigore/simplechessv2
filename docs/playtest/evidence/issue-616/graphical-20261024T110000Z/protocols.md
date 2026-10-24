# Protocols — issue #616 acceptance run (graphical)

Rows for the four protocols the manifest puts in scope. Index: [`manifest.md`](manifest.md). What was
run: [`run.md`](run.md). Why the `not-judged` rows are not failures: [`scope.md`](scope.md).

| Protocol / unit | Cited | Outcome |
|-----------------|-------|---------|
| `PTU-mode-pick` P1 — both entries work | `UI-mode-pick.US1` | pass (graphical) — Shared game and Puzzle stream both entered; screenshots 01, 03, 05 |
| `PTU-mode-pick` P3 — Switch locale | `UI-mode-pick.US1` | not-judged — no step of this run switched locale |
| `PTU-mode-pick` P4 — `EX.loading` window | `UI-mode-pick.S2`, `US1.6` | not-judged — `SIT.4` timing, no `SIT.4` run here |
| `PTU-mode-pick` P5 — legibility at 390×844 | `UIS.T2`, `SIT.6` | pass (graphical) — `body_text_px=21` for an 844 px frame; smallest label renders 21 px; no clipping or panel overflow. See the note on the debug overlay in [`marks.md`](marks.md) |
| `PTU-mode-pick` verdict | — | **not-judged** — P3 and P4 are out of scope for this run |
| `PTU-shared-setup` P1 — controls and Start/Back match story | `UI-shared-setup.US1` | pass (graphical) — panel centered, 10 controls, 0 outside the frame, smallest label 18 px at 1280×720 |
| `PTU-shared-setup` verdict | — | **pass** |
| `PTU-shared-result` P1 — result actions match story | `UI-shared-result.US1` | pass (graphical) — panel centered, 8 controls, 0 outside the frame |
| `PTU-shared-result` verdict | — | **pass** |
| `PTU-exceptions` S3 — interrupt leave/resign with cancel | `EX.US1` | pass (graphical) — Resign confirm opened centered; Cancel returned to shared play with the session intact |
| `PTU-exceptions` verdict | — | **not-judged** — S1 and S2 are not steps this defect's deliverables touch, and this run did not drive them |
| Screenshot completeness | `evidence.md` | pass — one rendered image per judged state and per frame size (19 files, [`paths.md`](paths.md)) |

Defects filed against a failed protocol: none.
