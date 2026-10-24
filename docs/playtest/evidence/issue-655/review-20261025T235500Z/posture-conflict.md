# The posture conflict — named, not adjudicated

Criterion 6 asks a published-release question, and `main` currently says two incompatible things about whether a published release exists.

## What `main` says

`specs/technical/configuration.md:43` (`B5`, `e19401f`):

> Ships enabled in the release: a missing T9 or T10 there is a deployment fault, **not accepted**.

`specs/technical/components/catalog-service.md` `R9` reads the same way: a real deal at the published URL is a release criterion.

## What the dispatch says

The instruction set supplied with this dispatch (not a repo file, so not citable by path) records that **no public release exists**, that the **project deploys no backend**, and that where a published release does not exist the requirement is recorded as **held, not failed**.

## Where it is already escalated

#648's own acceptance run hit this and stopped rather than choosing: [its acceptance comment, 2026-10-24T21:54Z](https://github.com/waigore/simplechessv2/issues/648#issuecomment-6382425591) moved #648 to `status:pending-clarification` asking the owner which posture governs `B5`/`R9` — the ADR-0015 *no project backend* posture, or a hosted one. #648 is still `pending-clarification`.

## Why this pass cannot turn `fail` into `held`

1. **The grant is conditional on a fact the repo contradicts.** `held` presumes no published release exists; `B5` presumes one does and that an unset pair there is a fault.
2. **`held` is not a third named outcome here.** Item 3 and criterion 3 admit exactly two: `K1` dealt, or the `F-puzzle-catalog.X2` absence *committed*. The body ties the second to the catalog-disabled branch and calls that branch *"no longer a live branch"*.
3. **An implement pass may not pick a posture.** Choosing it would rewrite the sentence #648 exists to own, and criterion 8 forbids `specs/` edits here.

So criterion 6 is recorded **fail**; `held` is not claimed; and the ordering this pass recommends is: answer #648's clarify first, then file the delivery task (or supersede #655 into it). No native edge is added or implied.
