# Quality Expectations

Authoring rules: [`.agents/specs/rules/quality.md`](../../.agents/specs/rules/quality.md).

Characteristics in this table are the source of truth. Each row cites one axis reached from [`quality/rubrics.md`](quality/rubrics.md). That axis states the outcome and the evaluator. The target on an Applies row is the bar for its axis.

## Categories

| Category | Applicability | Target | Platforms | Axis |
|----------|---------------|--------|-----------|------|
| Performance | Applies | 60 frames per second in the browser during piece movement | Web | `frame-time` |
| Performance | Applies | No hitch longer than one frame during a move | Web | `hitch-bound` |
| Load time / latency | Applies | Board playable within 3 seconds of opening the game | Web | `time-to-playable` |
| Load time / latency | N/A — no separate mode or screen transition budget beyond cold open to playable | — | — | `transition-latency` |
| Load time / latency | Applies | Advice ready within 2000 ms when On and online, and never delays a local move | Web | `response-delay` |
| Reliability | Applies | Crash-free for one sitting (about 15–40 minutes) | Web | `crash-free` |
| Reliability | Applies | After a failure, next open is mode pick with the last committed Player Elo and Last mode | Web | `resume-after-failure` |
| Observability | Applies | Errors, timing signals, and play outcomes are visible locally at a fidelity that correlates observations to design and UX story IDs for AI-agent playtests | Web | `runtime-signals` |
| Save durability | Applies | Committed Player Elo and Last mode survive quit, crash, and reload | Web | `save-survives` |
| Save durability | Applies | A failed write leaves the previous commit intact | Web | `failed-write` |
| Accessibility | Applies | Every piece type is readable from shape alone; no game information by color alone | Web | `distinguishable-channels` |
| Accessibility | N/A — no adjustable timing or assist controls in scope | — | — | `adjustable-timing` |
| Accessibility | Applies | Body text and labels remain readable at the smallest shipped text size on Web touch | Web | `text-audio-scale` |
| Localization | Applies | Ship English (`en`, default), Traditional Chinese (`zh-Hant`), and Japanese (`ja`) | Web | `shipped-locales` |
| Localization | Applies | All player-facing copy and in-game labels are translated for each shipped locale | Web | `translated-content` |
| Localization | Applies | Layouts tolerate about 40% length growth | Web | `text-growth` |

## Regression owners

A row that fails on the shipped build is filed as a `type:defect` against the wave epic that owns the behavior, never fixed inside the release gate that found it. Owner per row: [`quality-regression-owners.md`](quality-regression-owners.md).

## Rubrics

[`quality/rubrics.md`](quality/rubrics.md).
