# Notes — `review-20261025-par6`

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

## Criterion 3 — fail

Probe: `X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>`.

No puzzle is dealt, so `L-puzzle-stream` K1 is not met. The absence is also not committed as `F-puzzle-catalog.X2` — committing it is a `game/` or `specs/` change this defect's criterion 8 forbids. The body names this exactly: *"A screen still in `S1` with no dealt puzzle and no failed-read record is a `fail`."*

## Criterion 4 — holds as an observable

Elo `1000.00` before and after, no puzzle id, `last_failure=<status>`, and `puzzle stream: deal read failed (status)` appears twice in `logs/x655-probe.log` (once from the seam-free flow, once from the router at `session_router.gd:756`). No player-facing absence copy is required by `specs/` (`FAIL.T14`'s Effect column names none, and `B5` names `T14` and "log"); none was invented.

## Criterion 5 — pass, eleventh conforming measurement

```
X655 PANEL_C5_GATE=true
X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true
X655 CANCEL state=S1 has_puzzle=false
X655_PROBE pass
X655 ROUTER booted=mode-pick entered=puzzle-play C5=S2 after_confirm=mode-pick flow_left=true
X655 ROUTER_JOURNEY pass
```

`TEL.3` `sess-1792883679081-94520-playtest-273473`: `puzzle.enter` (`J-puzzle-session.S1`) → `puzzle.confirm` (`leave_confirm`) → `puzzle.leave` (`S2`). The `C5` exemption is at `game/puzzle_session.gd` (`needs_puzzle = false` for `C5`, documented at the `S1` gate; see `logs/c5-gate-source.log`). Item 4's repair clause does not fire.

## Criterion 6 — fail, and why no further implement pass can move it

The published artefact is live but unchanged (`logs/published-identity.log`): `index.pck` → `HTTP/2 200`, `etag "6adcf171-91ff1c"`, `last-modified` 2026-10-24 17:57:05 GMT, 9,568,028 bytes. The served catalog route is `GET /catalog/deal` → `404`. Since the same bytes were measured loading and refusing client-side, the published leg is a **fail**, not `held`.

The owner set, read live this run (`logs/owner-state.log`):

- **#648** `OPEN`, `pending-clarification` — the posture question, not a delivery mechanism.
- **#479** `OPEN` — its decision excludes client delivery from `specs/`.
- **#550** `OPEN` — the sweep that found this.
- **#505** `OPEN` — the deployment posture record.
- **#671** `OPEN` — the served-snapshot measurement on the catalog host.
- **#329** `CLOSED` — the serve route; accepted against an operator-run server, never a project deployment.
- No open issue owns putting a real `T9`/`T10` pair into a published client bundle.

## Unit / import / lint

- `godot --headless --path game --import --quit` → exit 0 (`logs/import.log`).
- `python3 .github/scripts/gdscript_tests.py test` → `32 headless unit test(s) passed`, exit 0 (`logs/unit-tests.log`). `GODOT_BIN` must be set on macOS; without it the script exits 1 with its own message.
- Coverage: **86.9% (4826/5551), threshold 80**, `gdtoolkit==4.5.0` in a throwaway venv (`logs/coverage.log`). One flake is recorded honestly: the first wrapper attempt stopped at `Fail: res://presentation_audio_test.gd`; that test then passed standalone with exit 0 (`logs/presentation-audio-direct.log`) and passed inside the second wrapper run, so the number is from a clean pass.
- `python3 .github/scripts/spec_lint.py` → `0 error(s), 1 warning(s)`; the warning is the pre-existing duplicate `Diagram` glossary entry (`logs/spec-lint.log`).

## Scope

Added: this folder only. No `game/`, `specs/`, `asset_catalog/`, or `game_assets/` change.
