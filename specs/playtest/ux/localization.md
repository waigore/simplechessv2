# Protocol: Localization copy

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-localization`
- **Environment**: Headless and Graphical
- **Cites**: `UI-mode-pick.US1.9`, `LOC.US1.2`, `LOC.US1.3`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Open mode-pick S1 with `GS.locale` `en`. Activate `C4` once, then twice more, recording R3 and every visible string after each activation; read the log for `FAIL.T13`. |
| S2 | For each of `mode-pick`, `shared-setup`, `shared-play`, `shared-result`, and `puzzle-play`, in `en`, `zh-Hant`, and `ja`, list every visible string, including an exception-state `exceptions` string, except the `locale` row S1 owns. |
| S3 | Graphical only: on `shared-play` in `ja`, read the piece-type rows `queen`, `rook`, `bishop`, and `knight`. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | `UI-mode-pick.US1.9`: after the first activation R3 reads `繁體中文`, every mode-pick copy string shows its `zh-Hant` form, and the screen stays S1. |
| P2 | `LOC.US1.3`: R3 reads `English`, then `繁體中文`, then `日本語`; `title`, `shared`, and `puzzle` differ across those readings; the third activation returns to `en`. |
| P3 | `LOC.US1.3`, Graphical only: all four `shared-play` piece rows read `Queen`, `Rook`, `Bishop`, `Knight` in `ja`, else `not-judged`; no row beyond `L3`'s two same-in-every-locale groups is same in every locale. |
| P4 | `LOC.US1.2`: R3 never reads `English` while `zh-Hant` or `ja` are live ([L3](../../ux/localization.md)); no visible string lacks a Copy-table row. |
| P5 | `LOC.US1.2`: every listed string is its Copy-table row value, in all three locales, at native length — no raw key, empty, clipped, or truncated label. |
| P6 | Headless and Graphical both pass, and the Graphical run of the same build adds the screenshots. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A `FAIL.T13` miss is logged after the switches (S1). | yes |
| F2 | The `locale` own name lacks a Copy-table row or is not `L3`'s value for the live locale (S1). | yes |
| F3 | `locale` sequences off, `title` / `shared` / `puzzle` do not differ, or the third activation misses `en` (S1). | yes |
| F4 | A piece row varies by locale when all four are read, or another row claims same-in-every-locale beyond `L3`'s groups (S1, S3). | yes |
| F5 | R3 reads `English` while the live locale is `zh-Hant` or `ja` (S1). | yes |
| F6 | S2 finds a visible string with no Copy-table row, a raw key, an empty label, or a clipped label. | yes |
| F7 | Either environment is missing for this UX protocol ([`playtest.md`](../playtest.md) §Gate). | yes |

## Evidence

Default evidence rules. Not judged: `UI-mode-pick.US1.13` (state edge, `PTU-mode-pick`), `LOC.US1.1` (Copy-table review), `LOC.US2.1` / `LOC.US2.2` (string-table test and review). Record the `FAIL.T13` read and three `C4` readings in `notes.md`; a logged miss is filed as a `type:defect`. Graphical: screenshot mode-pick after the first activation and the `ja` piece rows.
