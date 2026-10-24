---
name: require-demo-promotion
description: |-
  Require the promotion act before main-code work. At least one demo must
  exist; its scope may be minimal. Walk every included element of every demo
  under demos/, default keep, and ask keep or drop. Resolve demo-vs-demo and
  demo-vs-spec conflicts with the user, write the winner into specs, and do
  not promote a losing decision. Record the act in each demo README.
  Use before main-code work, or when the user asks to promote a demo.

  Examples:
    - user: "Start implementing movement" and demos/ is empty → stop; at least one demo is required
    - user: "Promote the demos we have" → walk each element, resolve conflicts, record the act
    - issue-workflow-implement-agent: before edits outside demos/ → run this; continue only on pass
---

# Require demo promotion

Contract: [`docs/demo-promotion.md`](../../../docs/demo-promotion.md). Apply the Gate. Do not restate it.

## Steps

1. **Setup**: run [`ensure-project-setup`](../ensure-project-setup/SKILL.md) unless it already passed in this session. Continue only on Pass.
2. **Require a demo**: if `demos/` has no demo, stop. At least one is required. Offer [`scope-gameplay-demo`](../scope-gameplay-demo/SKILL.md) and [`create-gameplay-demo`](../create-gameplay-demo/SKILL.md). Its scope may be minimal.
3. **Already satisfied**: if every act is complete and no kept decision disagrees with another kept decision or with the current spec, return pass. Do not walk a completed act again.
4. **Walk**: for each incomplete demo, for each included element, ask keep or drop. Default keep. Wait for that element before the next.
5. **Conflicts**: among kept decisions, and between a kept decision and the current spec, stop at each disagreement and ask. Write the winner with [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md) or [`author-spec`](../author-spec/SKILL.md). Open a spec PR per [Spec PRs](../../../docs/pull-requests.md#spec-prs). Drop the losing decision from its keep list, including on an act that was already complete. Leave demo behavior unchanged.
6. **Merge**: if a spec PR from this act is open, the act is not complete. Say so and stop.
7. **Record**: write each demo's Promotion act table (element, keep or drop, conflict choice) and mark the act complete. Do not otherwise edit the demo.
8. **Hand off**: for each non-empty keep list, reimplementation is [`promote-gameplay-demo`](../promote-gameplay-demo/SKILL.md). An empty list does not start it. Return pass only when every demo's act is complete.

## Rules

- Requirement notes are not authority.
- Do not reimplement demo code here.
- Do not edit main code here.
