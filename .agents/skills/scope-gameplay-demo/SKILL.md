---
name: scope-gameplay-demo
description: |-
  Decide which spec gaps block a gameplay demo from what that demo must show
  or apply. The gate lives in docs/demos.md Before building.
  Use when scoping a demo, or when create-gameplay-demo starts its scope phase.

  Examples:
    - user: "Demo only the HUD; combat rules can stay TBD" → combat does not block
    - user: "What has to be decided before a movement demo?" → apply the gate to that scope
    - create-gameplay-demo: Scope → run this; do not restate the gate
---

# Scope gameplay demo

Contract: [Before building](../../../docs/demos.md#before-building) and the [Types](../../../docs/demos.md#types) section. Apply them. Do not restate them.

## Steps

1. **Setup**: run [`ensure-project-setup`](../ensure-project-setup/SKILL.md) unless it already passed in this session. Continue only on Pass.
2. **Always-on specs**: check the spec items on the Always list. On a miss, stop, name it, and offer [`capture-requirements`](../capture-requirements/SKILL.md) or [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md).
3. **Already scoped**: when the given task is `status:pending-implementation` and its body has a confirmed scope, classify that scope and return pass or the misses. Do not confirm again.
4. **Draft the scope**: one demo question; the type; the qualified IDs this demo must show or apply; everything else excluded with a one-line reason. Prefer one loop, the features its steps need, and one stage or test arena. When in doubt, exclude.
5. **Classify** gaps in the included set (`TBD`, `<!-- fill in -->`, missing specs, contradictions) with the contract's rule for any other gap. Non-blocking gaps inside what the demo shows become assumptions. When style or assets are included, classify those gaps per [demo-style-assets Before building](../../../docs/demo-style-assets.md#before-building).
6. **Confirm** question, type, included IDs, assets only if shown or played, exclusions, blockers, and assumptions. Wait.
7. **Resolve blockers** the demo must show or apply: [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md), [`author-spec`](../author-spec/SKILL.md), or [`capture-requirements`](../capture-requirements/SKILL.md). Open a spec PR per [Spec PRs](../../../docs/pull-requests.md#spec-prs). Never encode an unconfirmed answer.
8. **Track**: use the given task, or create one with [`create-project-task`](../create-project-task/SKILL.md) whose body carries the confirmed scope. Building waits until the task is `status:pending-implementation`. If it is not, stop and report the next workflow step. Return pass only then.

## Rules

- Requirement notes are not authority.
- Do not build the demo. When [`create-gameplay-demo`](../create-gameplay-demo/SKILL.md) called this skill, return pass to it.
