# Held clause — spent, measured

Detail for [`manifest.md`](manifest.md), criterion 6.

Criterion 6 permits **held** only *"while #648's `specs/` sentence and #479's delivery
decision are unlanded"*. As of this pass **both halves have landed**
([`logs/held-condition.log`](logs/held-condition.log)):

- **#648's sentence** — `configuration.md:43` `B5` (`a9192a0`, PR #822) and
  `catalog-service.md:56` (`a94210d`, PR #815), both ancestors of `origin/main`.
- **#479's delivery decision** — PR [#806](https://github.com/waigore/simplechessv2/pull/806)
  merged `f07eed6` (2026-10-24T19:59:17Z). ADR-0010 now reads: *"Client-side delivery of the
  configured endpoint and key is the deploy path, so it stays out of this decision and out
  of `specs/`: no delivery mechanism is named there, and none is required."*

So the defect cannot be parked as *held*. It is judged, and on the current published
artefact it fails: `index.pck` (`etag "6adcf171-91ff1c"`) predates both commits and still
refuses inside `B5`'s empty-value guard, before any transport.

## Where the fix now belongs

Criteria 2, 3 and 6 need a published client carrying a real `T9`/`T10` pair. After PR #806,
that delivery is the deploy path, outside `specs/`, and no issue in the graph owns that
deploy-path step. Nothing dispatched to an implement agent can move criteria 2, 3 or 6 until
one does, because:

- `specs/` deliberately names no delivery mechanism (ADR-0010, `f07eed6`);
- `game/session_router.gd:33-34` is the shipped default and must stay empty in the source
  tree (a committed key is forbidden by `T10`);
- setting the values requires the deploy step that fills them into a published bundle.

That is a planner decision — file the deploy-path task, or supersede this defect into it.
It is not taken here, and no `game/` default is changed to fake a deal.
