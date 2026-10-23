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
| S1 | Open mode-pick S1 with `GS.locale` `en`. Activate `UI-mode-pick.C4` twice, recording R3 and the copy after each activation; read the log for `FAIL.T13`. Graphical then closes the cycle at `en` with a third, unjudged activation and enters Shared play to read the `shared-play` `queen` row, which mode-pick never shows (Headless: `not-judged`). |
| S2 | For each of `mode-pick`, `shared-setup`, `shared-play`, `shared-result`, and `puzzle-play`, in `en`, `zh-Hant`, and `ja`, list every visible string — including an `exceptions` string a screen shows in an exception state — except the `locale` row S1 owns. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | `UI-mode-pick.US1.9`: after the first activation R3 reads `繁體中文`, every mode-pick copy string shows its `zh-Hant` form, and the screen stays S1. |
| P2 | `LOC.US1.3`: `locale` reads `English`, then `繁體中文`, then `日本語`; `title`, `shared`, and `puzzle` differ in value across those readings. |
| P3 | `LOC.US1.3`, Graphical only: `shared-play` `queen` reads `Queen`; no other row is marked same in every locale. `LOC.US1` takes its outcome from the Graphical run. |
| P4 | `LOC.US1.2`, `locale` row: R3 reads the live locale's own name, never `English` while `zh-Hant` or `ja` are live ([L3](../../ux/localization.md)), so no visible string is absent from the Copy tables. |
| P5 | `LOC.US1.2`: every listed string is a Copy-table row value for the screen showing it, in all three locales, at native length — no raw key, empty, clipped, or truncated label. |
| P6 | Headless and Graphical both pass, and the Graphical run of the same build adds the screenshots. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A `FAIL.T13` miss is logged after the switches (S1); see Evidence. | yes |
| F2 | The `locale` row's own name has no Copy-table row, or is not `L3`'s own-name value for the live locale (S1). | yes |
| F3 | `locale` sequences off, or `title` / `shared` / `puzzle` do not differ across the three readings (S1). | yes |
| F4 | `queen` varies by locale, or another row claims same-in-every-locale beyond `L3`'s two groups (S1, Graphical). | yes |
| F5 | R3 reads `English` while the live locale is `zh-Hant` or `ja` (S1). | yes |
| F6 | S2 finds a visible string with no Copy-table row, a raw key, an empty label, or a clipped label. | yes |
| F7 | Either environment is missing for this UX protocol ([`playtest.md`](../playtest.md) §Gate). | yes |

## Evidence

Default evidence rules. Not judged: `UI-mode-pick.US1.13` (state edge, `PTU-mode-pick`), `LOC.US1.1` (Copy-table review), `LOC.US2.1` / `LOC.US2.2` (string-table test and review). Record the `FAIL.T13` log read and string listings in `notes.md`; a logged miss is filed as a separate `type:defect`.
