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
| S1 | On mode-pick S1 in `en`, activate `UI-mode-pick.C4` twice, recording R3 and the copy after each activation, then read the log for `FAIL.T13`. Judge `LOC.US1.2`'s `locale` row here: R3 reads the live locale's own name, never `English` while `zh-Hant` or `ja` are live ([L3](../../ux/localization.md)), and that value has its Copy-table row. |
| S2 | In `en`, `zh-Hant`, `ja`, list every visible string on `mode-pick`, `shared-setup`, `shared-play`, `shared-result`, `puzzle-play` — including an `exceptions` string a screen shows in an exception state — except the `locale` row S1 owns. |
| S3 | Graphical only: activate C4 once more, closing the cycle at `en`, then enter Shared play and read `shared-play` `queen`, which mode-pick never shows. That activation is unjudged; Headless records `not-judged`. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | `UI-mode-pick.US1.9`: after the first activation R3 reads `繁體中文`, mode-pick copy shows `zh-Hant`, and the screen stays S1. |
| P2 | `LOC.US1.3`: `locale` reads `English`, then `繁體中文`, then `日本語`; `title`, `shared`, `puzzle` differ in value across those readings. |
| P3 | `LOC.US1.2`, `locale` row: R3 is `L3`'s own-name value for the live locale in all three readings, so no visible string is absent from the Copy tables. |
| P4 | `LOC.US1.2`: every S2 string is a Copy-table row value for its screen, in all three locales, at native length — no raw key, empty, clipped, or truncated label. |
| P5 | `LOC.US1.3`, Graphical: `shared-play` `queen` reads `Queen`; no other row is marked same in every locale. `LOC.US1` takes its outcome from the Graphical run. |
| P6 | Headless and Graphical both pass; the Graphical run adds the screenshots. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A `FAIL.T13` miss is logged after the switches (S1); see Evidence. | yes |
| F2 | The `locale` own name has no Copy-table row, or is not `L3`'s value for the live locale (S1). | yes |
| F3 | `title` / `shared` / `puzzle` do not differ across the three readings (S1). | yes |
| F4 | R3 reads `English` under `zh-Hant` or `ja` (S1). | yes |
| F5 | S2 finds a visible string with no Copy-table row, a raw key, an empty label, or a clipped label. | yes |
| F6 | `queen` varies by locale, or another row claims same-in-every-locale beyond `L3`'s groups (S3). | yes |
| F7 | An environment is missing for this UX protocol ([`playtest.md`](../playtest.md) §Gate). | yes |

## Evidence

Default evidence rules. Not judged: `UI-mode-pick.US1.13` (state edge, `PTU-mode-pick`), `LOC.US1.1` (review), `LOC.US2.1` / `LOC.US2.2` (string-table test and review). Record the `FAIL.T13` log read and string listings in `notes.md`; a logged miss is filed as a `type:defect`.
