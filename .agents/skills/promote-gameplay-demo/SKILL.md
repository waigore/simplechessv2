---
name: promote-gameplay-demo
description: |-
  Reimplement one demo's confirmed keep list in the main tree. The list comes
  from require-demo-promotion. Writes assumptions into specs, covers the code
  in the technical design, then reimplements it under SOLID, the coding
  conventions, and the normal test bar. The demo stays unchanged as the reference.
  Use after that act has passed, or when a promotion task is ready to build.

  Examples:
    - user: "Promote the movement demo into the game" → require-demo-promotion, then reimplement its keep list
    - user: "Promotion task #30 passed review, build it" → implement phase only
---

# Promote gameplay demo

Contract: [Reimplementation in `docs/demo-promotion.md`](../../../docs/demo-promotion.md#reimplementation). The demo README's Promotion act is the keep list. Do not restate the gate.

Promotion is a reimplementation in the main tree with the demo as reference, not a file move.

## Steps

### Prepare

0. **Setup**: run [`ensure-project-setup`](../ensure-project-setup/SKILL.md) unless it already passed in this session. Continue only on Pass.
1. **Act**: run [`require-demo-promotion`](../require-demo-promotion/SKILL.md) unless it already passed for this demo in this session. Continue only on pass.
2. **Load** this demo's Promotion act. If the keep list is empty, stop. Load its code, the specs those elements cite, Accepted ADRs, and the technical design hub. Skip `specs/adr/archive/` and requirement notes.
3. **Keep list only**: if a kept decision disagrees with the current spec, stop and run `require-demo-promotion` again. Do not choose a winner here.
4. **Find spec work** for the keep list:
   - **Assumptions** in scope: each needs spec content before it can reach the main code.
   - **Technical coverage**: each module, component, contract, or schema the code needs per the `specs/technical/` rules that is not yet specified. When the promoted code loads assets, each one is in a load group in `specs/assets/access.md`, and no value it needs in `specs/technical/asset-access.md` is still TBD.
   - **Assets**: each asset in the demo README's **Assets** table that the promoted elements use. Kind/coverage and approval follow [`manage-asset`](../manage-asset/SKILL.md) / [`register-asset`](../register-asset/SKILL.md) and the asset hub; asset IDs and handles never change on promotion.
5. **Propose and confirm** the spec work for the keep list: assumptions needing spec wording, technical specs to author, and draft assets to approve. Wait for confirmation. Do not re-ask keep or drop.
6. **Write the specs**: for assumption TBDs, run [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md) scoped to those paths (or confirm answers then [`author-spec`](../author-spec/SKILL.md)); then author technical design the same way. Open a spec PR per [Spec PRs](../../../docs/pull-requests.md#spec-prs). Remove any element whose assumptions were not confirmed from the promotion scope.
7. **Track**: use the given task, or create one with `create-project-task` naming the demo, the elements in scope, the spec PR, and where the code goes. Implementation waits for `status:pending-implementation`; if the task is not there, stop and report the next workflow step.

### Implement

8. **Branch** `task/<n>-<slug>` from `main` after the spec PR has merged.
9. **Approve assets**: add the coverage IDs to the catalog entry of each asset in scope that lacks them; keep every asset ID and handle as it is. Main code cites assets by asset ID. For each draft asset in scope, re-run review through [`manage-asset`](../manage-asset/SKILL.md) or [`register-asset`](../register-asset/SKILL.md) as appropriate. When approval needs product-owner sign-off, stop and ask the user (or keep the PR draft) until they confirm; do not add `no-automerge` unless they ask.
10. **Reimplement** in the main tree per the technical design, [`docs/solid.md`](../../../docs/solid.md), [`docs/coding-conventions.md`](../../../docs/coding-conventions.md), and the existing structure, using the demo's decisions as reference. Add tests per the project's test bar. Do not import from `demos/` or copy its structure when SOLID, the conventions, or continuity disagree.
11. **Leave the demo unchanged**: no edits under `demos/`.
12. **PR** per [`docs/pull-requests.md`](../../../docs/pull-requests.md). Authority lists the promoted spec elements, the spec PR, and Accepted ADRs; Summary names the demo and its keep list. Then run [`implement-project-issue`](../implement-project-issue/SKILL.md).

## Rules

- Spec first: nothing reaches the main code on an assumption, a losing decision, or a requirement note.
- Never resolve an assumption without the user's confirmation.
- One demo per promotion task; split large promotions so each PR stays small.
- Verification and acceptance follow the issue workflow skills; do not restate their bars here.
