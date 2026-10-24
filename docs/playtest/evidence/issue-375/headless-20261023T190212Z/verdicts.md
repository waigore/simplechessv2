# Verdicts against #375's acceptance criteria

Back to [`notes.md`](notes.md). Judged only on what this run observed; anything it could not observe is **owed**, not passed.

| AC | Verdict | Basis |
|----|---------|-------|
| 1. R3 marks + eval only while On, online, values set | partial — behavior pass, graphical owed | On: `from=e2 to=e4`, `+0.18`. Off: cleared same frame. Nothing before the first E1 or after a completed move. The "online" leg is the `error` phase, where a failed fetch clears marks and parks the client. Rendered contrast/size not judged. |
| 2. C3 toggles `GS.advice`; Off clears at once; On re-evaluates | pass (behavior) | `advice: false`, marks `children=0`, eval `<null>`, then `from=e2 to=e4`. S2/ended gating is unit-covered; this run did not enter S2. |
| 3. Setup R1 row + C4 On/Off; default On, not persisted | pass (headless) | `setup_advice_default_on` true; C4 → Off → On before C5. Row visibility is graphical and owed. |
| 4. `PAL.C7` ≥ 2:1 both squares, eval ≥ `UIS.T2`, ≤ 10% coverage, silhouette kept | **owed (graphical)** | Not judged. Marks are drawn (`children=11`) and the eval label carries body-size text; contrast, rendered size, coverage, and silhouette need pixels. Passing this headlessly is the fake-green AC11 forbids. |
| 5. Marks show/clear via `CTR-presentation.E4` → `CMP-presentation.R4`, no new operation | pass | Marks follow the session fields through `BoardPresentation.render_advice()`; no `CTR-presentation` operation touched. |
| 6. Failed fetch → `EX.error`/S3: names the failure, playable, Dismiss → S1, move never waits | pass (headless) | S3 raised; panel `Advice unavailable. Play continues.`; `e2e4` landed in S3; Dismiss hid it and returned `S1`; one request, no retry storm. |
| 7. "Advice ready" medium priority, move not delayed | pass (headless); presentation owed | `waited_ms=15`; ready at 29 ms. Priority read is graphical. |
| 8. Every advice string via its Copy key | pass (headless) | Panel text is `shared_play("advice_error", "en")`, dismiss uses `shared_play("dismiss")`; `advice_ui_test.gd` asserts key equality. zh-Hant / ja stay #62's. |
| 9. No new sound; not colour alone; 44px targets; focus order | partly owed | No audio event around advice in any phase. Colour-alone and 44px are unit + graphical; not judged here. |
| 10. `shared-play`, `shared-setup`, `exceptions` pass headless **and graphical** | **headless pass, graphical open** | Headless halves pass ([`results.md`](results.md)); graphical halves did not run, so the pair is incomplete. |
| 11. R3 result on the shipped release graph against a reachable backend, under this folder | pass | `main_release.tscn`, no seam node, `sim_factory == null`, shipped transport over HTTP to a reachable peer, request log kept. |

**Summary.** Shipped-path behavior is established: the stream reaches the board, marks and eval render and clear, C3/C4 move `GS.advice`, and S3 holds without blocking play. Presentation-quality criteria (AC4, AC9 visual legs, AC1 rendered leg) and the graphical half of AC10 need a browser and are not claimed. AC11 is satisfied as written; it does not cover AC4. See [`verifier.md`](verifier.md).
