# Quality Expectations

Authoring rules: [`.agents/specs/rules/quality.md`](../../.agents/specs/rules/quality.md).

## Categories

| Category | Applicability | Target | Platforms | How checked |
|----------|---------------|--------|-----------|-------------|
| Performance | Applies | 60 frames per second in the browser, with no hitch longer than one frame during a move | Web | Frame-time capture in the browser during piece movement ([`SIT.4`](../playtest/tools-situational.md), `PTU-shared-play` S5, `PTU-puzzle-play` S4) |
| Load time / latency | Applies | Board playable within 3 seconds of opening the game; advice ready within 2000 ms when On and online, and never delays a local move | Web | Timed cold open to `EX.loading` clearing (open time: `SIT.4`, `PTU-mode-pick` S1); advice readiness within `CFG.ADVICE_TIME_MS` and never delaying a local move, measured headless over the simulated advice peer, verified outside playtest (evidence under [`docs/playtest/evidence/issue-559/`](../../docs/playtest/evidence/issue-559/)) |
| Reliability | Applies | Crash-free for one sitting (about 15–40 minutes); after a failure, next open is mode pick with the last committed Player Elo and Last mode | Web | Full sitting soak without crash; kill or fault mid-session, then reopen and confirm mode pick and committed values |
| Observability | Applies | Errors, timing signals, and play outcomes are visible locally at a fidelity that correlates observations to design and UX story IDs for AI-agent playtests | Web | Run a playtest protocol and confirm story IDs, outcomes, and errors appear in the captured logs (`SIT.5`, `PTU-shared-play` S6) |
| Save durability | Applies | Committed Player Elo and Last mode survive quit, crash, and reload; a failed write leaves the previous commit intact | Web | Quit and reload after a puzzle result; force a failed write and confirm the prior Elo and Last mode remain |
| Accessibility | Applies | Every piece type is readable from shape alone; no game information by color alone; body text and labels remain readable at the smallest shipped text size on Web touch | Web | Casual reader names each piece from shape ([PER.R1](../view/perception.md), verified outside playtest); color-blind simulation still distinguishes required info ([PAL.K1](../aesthetics/palette.md) [PAL.K2](../aesthetics/palette.md), verified outside playtest); text legible at smallest size on a phone-width viewport (`SIT.6`, `PTU-mode-pick` S6) |
| Localization | Applies | Ship English (`en`, default), Traditional Chinese (`zh-Hant`), and Japanese (`ja`). All player-facing UI copy and in-game labels in those locales; layouts tolerate up to about 40% length growth versus English | Web | Switch locale and spot-check mode pick, Shared game, Puzzle stream, and end screens for full strings and no clipped labels ([copy contract](../ux/localization.md) L1–L6; [`CTR-localization`](../technical/contracts/localization.md) G4 G5; [`PTU-localization`](../playtest/ux/localization.md)) |

## Regression owners

A row that fails on the shipped build is filed as a `type:defect` against the wave epic that owns the behavior, never fixed inside the release gate that found it. Owner per row: [`quality-regression-owners.md`](quality-regression-owners.md).
