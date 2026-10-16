# Demo style and assets

Every [gameplay demo](demos.md), engine or gameplay type, is a proof of concept for the game's style and its asset pipeline. It expresses the style in [`specs/aesthetics/`](../specs/aesthetics/aesthetics.md), and every asset it shows or plays is cataloged per [`specs/assets/`](../specs/assets/assets.md). Assets may be agent-made or human-made; agent generation is optional.

## Before building

Always:

- The aesthetics hub and every style element in scope hold no TBD.
- The asset hub names its catalog root, asset root, and approval rule.

For each asset an agent makes or imports with `manage-asset`:

- Its kind has a kind spec whose coverage rule, specification, recipe, and checks hold no TBD.
- The recipe's tool role is realized by an Accepted ADR.

An asset a person supplies with `register-asset` for the demo needs only the catalog and a kind spec name in the hub's Asset kinds table (the spec may be planned). Every asset gets its permanent asset ID (a UUID) and its handle per the catalog's rules, so promotion never changes either. A missing piece is a blocking gap, resolved in `specs/` before the build, never as a demo assumption.

## Style

- Aesthetics element IDs (pillars, palette sets, form, surface, motion, interface style, sound) are in the demo's scope like design IDs, as included or excluded with a reason.
- Every included style element is visible or audible in the demo.

## Assets

- Every asset is cataloged and cited in the demo by asset ID: agent-made or imported with [`manage-asset`](../.agents/skills/manage-asset/SKILL.md), or supplied by a person with [`register-asset`](../.agents/skills/register-asset/SKILL.md).
- No uncataloged placeholder art or sound. Debug overlays are tooling, not assets.
- Every asset has a [`review-asset`](../.agents/skills/review-asset/SKILL.md) Pass for its current version, or a review exemption that a person granted per the asset hub, whatever its source type. Assets may stay draft.
- Assets live under the catalog's asset root, not in `demos/<slug>/`.

## Pipeline findings

The README lists every problem met while producing or registering its assets: a recipe that needed retries, a check that could not be run, a tool limit, a style element too vague to judge. Each finding is filed as a spec change (with `author-spec`) or a defect (with `create-project-defect`), and the README links it. "None" is a valid list.

## Verification

`verify-project-issue` runs `review-asset` on every non-exempt asset the demo uses, checks each exemption is valid, and checks the README's style and asset tables against the demo. A review Fail, an invalid exemption, an included style element not shown, or an asset not in the catalog fails verification.
