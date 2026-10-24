# Notes — `review-20261025-par6` (part 1: what this pass is, the branch, criteria 1–2)

Part 2 — criteria 3–6, unit/import/lint, scope — is in [`notes-2.md`](notes-2.md).

## What this pass is

An implement dispatch for #655 that measured, on the newest `origin/main`, the same three legs the last five implement passes measured. It writes no `game/` code, for a reason that is measured below rather than inherited: item 4 is the only `game/` change this defect may own, and it measures conforming.

## The branch, and the posture question behind it

#648's recorded answer is **catalog enabled in the release**. The dispatcher supplied with this run does not carry #648's clarification; the live read (`logs/owner-state.log`) shows **#648 is `status:pending-clarification`**, and its last comment is an acceptance run asking the product owner which posture governs `B5` and `CMP-catalog-service` R9 (ADR-0015 *no project backend* vs a project-hosted catalog route).

That question is not this defect's to answer (criterion 8: no `specs/` change), and it does not change any row measured here:

- Criterion 1 cites the sentence that is on `main`, and passes.
- Criterion 2 measures `B5`'s empty-value guard in the **source tree**, which stays empty under either posture (`T10`: never committed; the value would arrive per deployment).
- Criterion 3 measures the stream's outcome on the build that exists.
- Criterion 6 is the row the posture decides. `held` was a device for "the published leg cannot be judged yet because #648's sentence and #479's decision are unlanded"; both landed (`a9192a0`/`a94210d`, `f07eed6`), so the clause is spent and the published artefact is judged as it is. That reading does not depend on which posture the owner picks.

## Criterion 1 — the sentence

`specs/technical/configuration.md:43` (`B5`), introduced at **`a9192a0`**:

> Ships enabled in the release: a missing T9 or T10 there is a deployment fault, not accepted (every deal fails, `FAIL.T14`; Elo kept; log). Arrival: #479 (delivery)

`specs/technical/components/catalog-service.md:56`, introduced at **`a94210d`**:

> Because the route ships enabled, a missing T9/T10 or an unreachable route on the published release is a deployment fault, never an accepted state.

Both are ancestors of `6e9cb7e`.

## Criterion 2 — fail, and the guard is the message

`logs/criteria-1-2-3-source.log`:

- `game/session_router.gd:33-34` — `advice_endpoint := ""`, `advice_api_key := ""`.
- `git grep` over `game/` finds no assignment anywhere except the test seam `game/advice_ui_test.gd:40-41` (`http://advice.test/advice`, `test-key`).
- `CatalogDealClient.is_available()` (`game/catalog_deal_client.gd:39-40`) is `not endpoint.is_empty() and not api_key.is_empty()`.
- The empty pair reaches the deal at `game/session_router.gd:756` (`puzzle_flow.enter(_persist, advice_endpoint, advice_api_key, …)`).

Probe: `X655 B5 endpoint=<> key_set=false is_available=false`.

**This pass found that the pipeline now has a backend deploy script** — `.github/scripts/deploy_advice_backend.sh` builds the catalog (`python3 -m advice_backend.catalog build`) and requires `ADVICE_API_KEY`. That script starts an **operator-run server**; `logs/release-workflow-check.log` confirms no workflow calls it and that neither `web-release.yml` nor `web_export.py` sets `T9`/`T10` into a client export. So the gap the previous pass recorded ("the publish pipeline has no step that could set either value") still holds for the client, and its server half is now a manual path, which is what ADR-0015 describes.
