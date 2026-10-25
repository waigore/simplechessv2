# Readings — forced failed write, FAIL.T1, gate runs

## Forced failed write keeps the prior commit

`quality.md` Save durability: *"a failed write leaves the previous commit intact"*. The build
writes one document under `simplechessv2.persist.v1` through `Storage.prototype.setItem`
(`persist_store.gd` `_web_set`, whose comment names the quota case), so the fault is a **throw** —
clearing storage would prove nothing about a failed write.

| Step | Observed |
|---|---|
| Prior commit seated (the build's own Shared-game choice) | `last_mode: "shared"` |
| Fault armed | `setItem` throws `QuotaExceededError` |
| Build's next write (pick `Puzzle stream`) | **1** failed write |
| Build's own report | `ERROR: PersistStore: write failed; prior commit kept` at 10.947 s |
| Storage after | byte-identical; `last_mode` still `shared` |
| Play | continues; UI shows *"Save failed. Prior values kept."* |

Only the run with `failedWrites: 1` is cited: an earlier attempt tapped the wrong button, so the
fault never fired and proved nothing.

## Backend failure clears advice (FAIL.T1)

`advice_client_test.gd` on `c5b8189` (`logs/advice-client-test-c5b8189.log`): exit 0,
**0 `FAIL ` lines**. `_check_offline_clears` (`:249`) pushes a live `d2d4`, ends the stream
`REASON_ERROR`, then asserts `GS.online` false, both advice fields cleared (`:264`), the failure
reported as `advice.error` / `unavailable` with **play continuing** (`:266`), and the failed
stream delivering nothing further (`:279`).

The `Parse JSON failed` line there is expected: `_check_wire_handles_partial_and_junk` (`:488`)
feeds deliberate junk to prove the reader ignores it.

## Gate runs on `c5b8189`

| Run | Result | File |
|---|---|---|
| `gdscript_tests.py test` | 30 passed | `logs/unit-tests-c5b8189.log` |
| `web_export.py --check-engine build/web` | exit 0 | `logs/check-engine-c5b8189.log` |
| `asset_manifest.py --check` | 0 errors | `logs/asset-manifest-check-c5b8189.log` |
| manifest vs fresh generation | byte-identical | `logs/manifest-generated-not-edited-c5b8189.log` |
| roots audit | 32 entries, 38 = 38 | `logs/roots-not-mixed-audit-c5b8189.log` |
