# Asset Procedures

Authoring rules: [`.agents/specs/rules/assets/procedures.md`](../../.agents/specs/rules/assets/procedures.md).

## When to run

Asset work is tracked by a task issue whose deliverables name asset IDs or coverage rules (`AK-<name>.V<n>`). Assets land through PRs. `manage-asset` runs generate/import/update/deprecate/touch-up; `establish-asset-style` runs `APR.establish-style`; `register-asset` runs `APR.register`; `review-asset` runs `APR.review`.

## Procedures

### `APR.generate`

[`procedures/generate.md`](procedures/generate.md).

### `APR.import`

- **Trigger**: a coverage rule is met by a third-party asset.
- **Inputs**: sourced files; license and purchase proof; kind spec.

1. Confirm the license allows the definition's market constraints before downloading.
2. Add a draft entry with source, license, attribution, and where proof of purchase is kept.
3. Post-process to the kind's specification. Run checks and `APR.review`.

- **Outputs**: draft entry; files per naming, post-processed to the kind specification; review verdict or exemption.

### `APR.register`

- **Trigger**: a person supplies an asset of any source type.
- **Inputs**: files; supplier; source type; rights; tool and terms when generated.

1. Add a draft entry with asset ID, supplier, source type, and rights or license; for generated, the tool and terms.
2. Ask whether to exempt from review; record `CAT.F17` if granted.
3. Save files per naming. Approve on merge if exempt; otherwise `APR.review`.

- **Outputs**: draft entry; files per naming; `CAT.F17` if exempt; otherwise a pending `APR.review`.

### `APR.review`

- **Trigger**: a draft is ready for a verdict, or review was requested on an exempt entry.
- **Inputs**: draft entry; files; kind spec checks and `SS1`.

1. Skip exempt entries unless review is requested; then the verdict is advisory. Otherwise run `review-asset` and record verdict, date, reviewer, report.
2. On Pass, approve per the hub's **Approval** rule. On Fail, fix through `APR.generate` or `APR.update`.

- **Outputs**: `CAT.F13` verdict, date, reviewer, and report; approved per hub **Approval**, or a fail returned to fix.

### `APR.update`

[`procedures/update.md`](procedures/update.md).

### `APR.deprecate`

- **Trigger**: an asset is superseded or retired.
- **Inputs**: asset ID; reason; successor ID when replaced.

1. Remove every use in main code.
2. Set state deprecated, with reason and successor ID if any.
3. Delete files once no branch under review uses them; the entry stays.

- **Outputs**: deprecated entry with reason and successor (`CAT.F14`/`CAT.F15`); uses removed; files deleted when no reviewed branch uses them; entry kept.

### `APR.touch-up`

Optional: [`procedures/touch-up.md`](procedures/touch-up.md). Respect series negatives; do not clear series binding.

### `APR.establish-style`

[`procedures/establish-style.md`](procedures/establish-style.md).

## Consistency

- **Style anchors / series**: each kind's Style series registry (`SS1`) is source of truth; see the kind spec.
- **Identity**: enforced styling (hard binding or soft exemplars) + master/negative prompting + review (look or listen).
- **Sets**: all variants of one subject in one batch with the same inputs and seed policy (`n/a` when the tool has no seed).
- **Re-review**: changed aesthetics, recipe, tool role, or style series reopens citing approved assets.

## Failure handling

- **Retry limit**: 3 attempts per asset before asking the user.
- **Ask the user** after repeated check fails, a second review Fail on the same asset, an unclear license, or a reached cost or quota limit.
