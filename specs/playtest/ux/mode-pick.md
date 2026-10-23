# Protocol: Mode pick screen

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-mode-pick`
- **Environment**: Headless and Graphical
- **Cites**: `UI-mode-pick.US1`
- **Situational tools**: `SIT.4` (Loading time), `SIT.6` (Legibility)

## Steps

| ID | Action |
|----|--------|
| S1 | Open mode-pick; activate Shared game control. |
| S2 | Return; activate Puzzle stream control. |
| S3 | Confirm Last mode affordance when persisted. |
| S4 | Activate Switch locale; confirm the copy switches locale immediately. |
| S5 | Cold open on an empty `localStorage`; time `EX.loading` start to mode-pick S1 ready, then repeat on a warm open. |
| S6 | Graphical only: set a phone-width viewport (390×844) and confirm every label and body string at ≥ `UIS.T2`. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Both mode entries work; Last mode indication matches `UI-mode-pick.US1.1`. |
| P2 | Headless and Graphical both pass. |
| P3 | Switch locale updates mode-pick copy without leaving the screen. |
| P4 | `EX.loading` shows with C1–C4 unavailable until mode-pick S1 is ready (`UI-mode-pick.US1.6`), then clears within 3 s on both the cold and warm open. |
| P5 | Every label and body string is legible at S6 without clipping (Accessibility, `UIS.T2`). |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Mode control missing, routes wrong, or the S1 default omits Last mode, Shared game, or Puzzle stream (`UI-mode-pick.US1.1`, `US1.3`, `US1.4`) | yes |
| F2 | Loading state skipped, controls reachable during it, or ready time over 3 s | yes |
| F3 | Clipped or sub-`UIS.T2` text at phone width | yes |

## Evidence

Default evidence rules. Graphical: screenshot mode-pick and the S6 phone-width viewport; `SIT.4` report carries device, browser, build id, and repeat count ([`evidence-manifest.md`](../evidence-manifest.md)); one sample per open is not evidence.
