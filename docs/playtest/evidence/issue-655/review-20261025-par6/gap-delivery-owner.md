# Why criterion 6 cannot move, and who would have to move it

Criterion 6 asks for the published-release rows, or for the published leg to be recorded **held**. The `held` device belongs to *Expected behavior*'s sequencing note, which held the published leg until two things landed. Both have landed:

- #648's `specs/` sentence — `specs/technical/configuration.md:43` (`a9192a0`), `specs/technical/components/catalog-service.md:56` (`a94210d`).
- #479's delivery decision — merged as `f07eed6`: client delivery of the pair is the **deploy path, outside `specs/`**.

So the published artefact is judged as it is. Measured this run (`logs/published-identity.log`):

| Read | Result |
|---|---|
| `HEAD https://waigore.github.io/simplechessv2/index.pck` | `HTTP/2 200`, `etag "6adcf171-91ff1c"`, `last-modified` 2026-10-24 17:57:05 GMT, 9,568,028 bytes |
| `GET https://waigore.github.io/catalog/deal` | `404` |

The same bytes were driven in earlier passes: the client refuses inside `B5`'s empty-value guard before any transport, which `B5` itself calls *"a deployment fault, not accepted"*. That is a fail, not `held`.

## Owner set, read live (`logs/owner-state.log`)

| Issue | State | What it owns |
|---|---|---|
| #648 | `open`, `pending-clarification` | The **posture** question its acceptance run escalated: does ADR-0015's *no project backend* govern `B5`/R9, or is a hosted catalog route owed? Not a delivery mechanism. |
| #479 | `open` | The decision that client delivery stays out of `specs/` (`f07eed6`). |
| #550 | `open` | The wave-2 sweep that filed this defect. |
| #505 | `open` | The advice backend deployment posture record. |
| #671 | `open` | The served-snapshot measurement on the catalog host. |
| #329 | `closed` | The serve route, accepted against an **operator-run** server — never a project deployment. |

**No open issue owns taking a real `T9`/`T10` pair into a published client bundle.**

## The pipeline half, re-measured

`.github/scripts/deploy_advice_backend.sh` now exists and builds the catalog (`python3 -m advice_backend.catalog build`) behind a required `ADVICE_API_KEY`. That is an **operator-run server start**, consistent with ADR-0015's posture. No workflow invokes it, and neither `.github/workflows/web-release.yml` nor `.github/scripts/web_export.py` writes an advice value into a client export — `logs/release-workflow-check.log` shows both name advice only as a thing they strip or do not publish. So the client-delivery half has no mechanism in the repository, under either posture.

## What would end this loop

Criteria 2, 3 and 6 need work this defect may not do: the source tree must stay `""` (`T10`: never committed), `specs/` may not name a delivery mechanism or a posture without the owner's word (and criterion 8 forbids the edit), and no task owns the pipeline step.

Two decisions, in this order:

1. **Answer #648's clarification** — which posture governs `B5`/R9. Until then criterion 6 has no verdict other than fail.
2. **Give the delivery step an owner** — file the task that takes a real `T9`/`T10` pair to a published bundle (or, under posture (a), restate criterion 6 as an operator-run condition), or supersede #655 into it, keeping the twelve-run record as the measurement.

Until both happen, an implement dispatch on #655 measures the same three rows and returns.
