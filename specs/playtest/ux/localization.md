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
| S1 | Open mode-pick S1 at `GS.locale` `en`. Activate `C4` twice, recording `R3` and every visible string after each. Judge: the first activation keeps S1, reads `R3` `繁體中文`, and shows copy in `zh-Hant` (`UI-mode-pick.US1.9`); `title`, `shared`, and `puzzle` differ between `en`, `zh-Hant`, and `ja`, and `locale` reads `English`, `繁體中文`, `日本語` (`LOC.US1.3`); `locale` reads its own name, never `English`, while `zh-Hant` or `ja` is live (`LOC.US1.2`, that row only). Then read the run log for `FAIL.T13` misses (`CTR-localization` G4, `TEL.1`–`TEL.5`); no telemetry assertion, `SIT.5` not cited. |
| S2 | On each of `mode-pick`, `shared-setup`, `shared-play`, `shared-result`, and `puzzle-play`, in all three locales, list every visible string including an exception-state `exceptions` one, except the `locale` row. Judge `LOC.US1.2` for each. |
| S3 | Graphical only. Activate `C4` a third, unjudged time, closing at `en`; enter Shared play and read the `queen` row. Headless is `not-judged`. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | `UI-mode-pick.US1.9`: after the first activation `R3` reads `繁體中文`, copy is `zh-Hant`, and S1 holds. |
| P2 | `LOC.US1.3`: `title`, `shared`, and `puzzle` differ between the three locales; `locale` reads `English`, `繁體中文`, `日本語`. |
| P3 | `LOC.US1.2`, `locale` row only (S1): reads its own name, never `English`, while `zh-Hant` or `ja` is live ([L3](../../ux/localization.md)). |
| P4 | `LOC.US1.2`, other strings (S2): each is its screen's Copy-table value — no raw key, empty, or clipped label at native length. |
| P5 | `LOC.US1.3`, Graphical only (S3): `queen` reads `Queen` in all three locales; Headless is `not-judged`. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A `FAIL.T13` miss is logged after the switches (S1). | yes |
| F2 | P1's first-activation reading fails in any part (S1). | yes |
| F3 | A locale-dependent row does not differ between locales, or `locale` sequences off (S1). | yes |
| F4 | `locale` reads `English` while `zh-Hant` or `ja` is live, or lacks a Copy-table row (S1). | yes |
| F5 | P4's reading fails for any listed string (S2). | yes |
| F6 | The Graphical `queen` row is not `Queen` in all three locales (S3). | yes |
| F7 | Either environment is missing ([`playtest.md`](../playtest.md) §Gate). | yes |

## Evidence

Default evidence rules. Not judged: `UI-mode-pick.US1.13` (state edge, `PTU-mode-pick`); `LOC.US1.1` (key names are a spec review); `LOC.US2.1` / `LOC.US2.2` (growth test and change control; no `SIT.*` lengthens strings). `LOC.US1` is cited whole, so its outcome comes from the run judging all three scenarios — S1 and S2 here, plus the `US1.1` review. Record the `FAIL.T13` read and the `C4` readings in `notes.md`; a logged miss or S2 failure is a `type:defect`. Graphical: screenshot mode-pick after the first activation and the `queen` row.
