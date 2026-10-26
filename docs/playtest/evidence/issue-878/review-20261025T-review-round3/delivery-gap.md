# #878 round 3 — the deliverability defect

AC4 makes this task a conditional of `#648`'s answer. On `main` neither branch is writable.

## 3a. Nothing assigns `T9`/`T10` in `game/`

```
grep -rn "advice_endpoint\s*=\|advice_api_key\s*=" game/*.gd   (non-test)
  no match — both assignments are in advice_ui_test.gd:40-41
grep -rn "OS.get_environment" game/*.gd                        (non-test)
  no match — four test-harness reads only
grep -n "T9\|T10\|ADVICE" .github/scripts/web_export.py
  lines 82, 554-555 only — engine-bundle comments, no assignment
game/export_presets.cfg: no script arguments
```

`session_router.gd:33-34` initialises both to `""`; `:502`, `:571`, `:793` only read. `main.tscn`
carries no value. So `main` has no build-time injection, no entry UI, no fetched config.

AC2 asks for "the run that set them recorded (build commit, timestamp)" — that needs a mechanism
`main` lacks. AC4 forbids this task building it, and `CMP-catalog-service` `R6`/`R7` plus `T10`'s
never-committed rule constrain what one may be.

## 3b. The posture branch the body treats as the narrow one cannot proceed

- **Operator-run** (ADR-0015 as written): the operator enters or injects the pair on the build.
  That is the missing mechanism of §3a. The refinement comment said Deliverables 1 and 3 collapse
  here; Deliverable 2 does not.
- **Project-hosted**: requires the superseding ADR and `B5`/`R9` rewritten **before**
  implementation, though the ACs are written against today's `B5`/`R9`. AC4 says that rewrite
  belongs to "that task, never to this one" — and names no task, so the gate may not exist.

`#892` ("one deploy-time source for T9/T10…") was `status:pending-review` and no merged `main`
commit carries such a source. If it lands, it removes §3a's missing source but not §3b's
conditional, and AC2 still owes the operator's run.

## 3c. AC7 asks for comments on issues whose state contradicts the ask

`#550` and `#402` are `status:pending-verification`, not pending-acceptance; "can be re-judged"
has no step to land on there, and both sit in a step this task does not own. AC7 is satisfiable as
a comment only.
