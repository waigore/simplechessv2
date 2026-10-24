# The delivery-owner gap, measured

Criterion 6 (and, through it, 2 and 3) need one thing: a **published client carrying a real `T9`/`T10` pair**. Every prerequisite earlier passes named has landed; the pair still does not exist. Re-checked on `161b4a9` (first recorded on `5d80029`).

## Landed

- **The decision** — catalog **enabled**. `specs/technical/configuration.md:43` (`B5`), `specs/technical/components/catalog-service.md:56`, both at `e19401f`.
- **The delivery decision** — #479, `f07eed6`: *"Client-side delivery of the configured endpoint and key is the deploy path, so it stays out of this decision and out of `specs/`…"*
- **The dealer code** — `X550 RESULT deal=true`: the path deals as soon as the values exist.

## Missing — three facts, re-checked this run

1. **Source must keep them empty.** `game/session_router.gd:33-34` is `""` by design (`T10`: never committed; set per deployment). Only `game/advice_ui_test.gd:40-41` assigns either.
2. **The publish pipeline has no step that could set them.** `logs/release-workflow-check.log`: `.github/workflows/web-release.yml` names no `T9`, `T10`, `ADVICE`, or `advice` value and no secret beyond `GITHUB_TOKEN`/`GH_TOKEN`; `.github/scripts/web_export.py` writes no advice value. There is **no mechanism in the repo** by which a value reaches a published client.
3. **No issue owns the step.** **#648** decides (its AC-4 is a *server-side* measurement and it is now in `pending-clarification` on exactly this posture); **#479** excludes delivery from `specs/`; **#671** measures the served snapshot on the host; **#505** records the backend posture; **#786** is `superseded` into #655. Nothing open is scoped or carries a deliverable for putting the pair into a published bundle.

## Why an implement dispatch cannot close it

**`game/`** — the only allowed change is item 4's `C5`/`S1` repair, and that leg conforms (probe `S1 → S2 (leave_confirm) → S1`). **`specs/`** — criterion 8 forbids it, and `f07eed6` deliberately names no mechanism there. **A committed value** — `T10` is never committed.

What remains is a mechanism **outside the source tree** — a deploy step, an operator procedure producing a published artefact, or a CI input. Choosing one is a product/planner decision.

## The published build today

`index.pck` → `HTTP/2 200`, `etag "6adcf171-91ff1c"`, `last-modified` 2026-10-24 17:57:05 GMT, 9,568,028 bytes. Live deployment **`7302318984`**, sha **`c5b8189b`**, from `Web release` run **`40118381611`** (`success`) — unchanged across the last two implement runs. The drive of this same artefact (`review-20261025T022500Z`) made **zero** catalog or advice requests on a cold open and logged `puzzle stream: deal read failed (status)` twice — client-side, inside `B5`'s empty-value guard.

## The decision that ends the loop — now two decisions, not one

1. **The delivery task**: file the task that takes a real `T9`/`T10` pair to a published bundle, or supersede #655 into it, keeping this record as the measurement.
2. **The posture**: whether a "published release" exists at all — see [`posture-conflict.md`](posture-conflict.md). Until it is answered, criterion 6 is neither pass nor legitimately `held`.

No native edge is added or implied here.
