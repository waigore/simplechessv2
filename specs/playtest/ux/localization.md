# Protocol: Localization copy

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-localization`
- **Environment**: Headless and Graphical
- **Cites**: `UI-mode-pick.US1`, `LOC.US1`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Open mode-pick S1 in `en` with `GS.locale` `en`; activate `UI-mode-pick.C4` twice, reading R3 and the copy after each activation. Read the run log for `FAIL.T13`. |
| S2 | Enter Shared play and read the `shared-play` `queen` row (Graphical only; S1 left the run on `ja`, so activate C4 once more, unjudged, to return to `en` first). |
| S3 | For each of `mode-pick`, `shared-setup`, `shared-play`, `shared-result`, and `puzzle-play`, in `en`, `zh-Hant`, and `ja`, list every visible string, including an `exceptions`-owner string a screen shows in an exception state, except the `locale` row S1 owns. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | `UI-mode-pick.US1.9`: after the first activation R3 reads `繁體中文`, every `mode-pick` copy string shows its `zh-Hant` form, and the screen is still S1. |
| P2 | `LOC.US1.3`: over the three readings `English`, `繁體中文`, `日本語`, `title`, `shared`, and `puzzle` differ in value in each locale. |
| P3 | `LOC.US1.3`, graphical only: `shared-play` `queen` reads `Queen`. In a headless run this row is `not-judged` and `LOC.US1` takes its outcome from the graphical run. |
| P4 | `LOC.US1.2`: the `locale` row reads the own name of the live locale, never `English` while `zh-Hant` or `ja` are live ([L3](../../ux/localization.md)). |
| P5 | `LOC.US1.2`: every listed string is the value of a Copy-table row for the screen showing it, in all three locales, at native length with no clipped or truncated label. |
| P6 | Headless and Graphical both pass, and the Graphical run of the same build adds the screenshots. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A `FAIL.T13` miss is logged after either activation (S1); see Evidence. | yes |
| F2 | P2's three values do not differ across locales, or the `locale` row does not read the own name of the live locale. | yes |
| F3 | `queen` varies by locale in the Graphical run. | yes |
| F4 | S3 finds a visible string with no Copy-table row, a raw key, an empty label, or a clipped label. | yes |
| F5 | Either environment is missing for this UX protocol (`playtest.md` §Gate). | yes |

## Evidence

Default evidence rules. A `FAIL.T13` log read and the string listings are recorded in `notes.md`; a miss is recorded there, then filed by a separate `type:defect` issue.
