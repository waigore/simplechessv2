# Playtest tools: Situational

Authoring rules: [`.agents/specs/rules/playtest/tools.md`](../../.agents/specs/rules/playtest/tools.md).

Summary and the Must rows: [`tools.md`](tools.md). A protocol cites a row here only when it needs that capability; the matching seams are in [`verification.md`](../technical/verification.md).

| ID | Capability | When it applies | Seam |
|----|------------|-----------------|------|
| `SIT.1` | Deterministic seed | Protocol needs a repeatable start state | `S8` |
| `SIT.2` | Input replay | Protocol needs recorded input playback | `S9` |
| `SIT.3` | State dump | Protocol needs a full state snapshot beyond `DBG.2` | `S10` |
| `SIT.4` | Frame-time / latency capture | Protocol times a move for frame time, or times `EX.loading` clearing ([quality.md](../definition/quality.md) Performance, Load time) | `S11` |
| `SIT.5` | Telemetry read assertion | Protocol asserts its own steps emitted `TEL.1`–`TEL.5` with the cited story IDs (Observability) | `S12` |
| `SIT.6` | Phone-width viewport at smallest text size | Protocol judges text legibility on a phone-width layout ([UIS.T2](../aesthetics/ui-style.md), Accessibility) | `S13` |

`SIT.4` and `SIT.5` evidence records device, browser, build id, and repeat count in the [manifest](evidence-manifest.md); one sample is not evidence.

**One legibility citer.** `SIT.6` is cited only by `PTU-mode-pick` S6, where the Accessibility legibility claim is judged once at phone width. `PTU-localization` checks its copy for clipping at native length only, so it cites no `SIT.*` and runs no phone-width viewport.

**Not measured by a seam.** The Accessibility piece-shape claim lives in [PER.R1](../view/perception.md) and the color claim in [PAL.K1](../aesthetics/palette.md) [PAL.K2](../aesthetics/palette.md). View stories are out of playtest scope, so both are verified outside playtest by perception and palette review against those files, never by a playtest run.
