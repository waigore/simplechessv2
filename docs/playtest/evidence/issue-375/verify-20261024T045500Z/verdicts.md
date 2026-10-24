# Verdicts against #375's acceptance criteria

Back to [`notes.md`](notes.md). Verifier run on `ea37581`; AC-by-AC table lives in the issue's verify comment and is summarised here.

| AC | Verdict | Basis |
|----|---------|-------|
| 1–3, 7–9 | pass | 2026-10-23 headless shipped-path run; unchanged by #752 |
| 4 `PER.R5` / `PER.R1` | pass | 58.6% → 1.73% worst (`graphical-20261024T033000Z/logs/ink-run.log`); `_marks_fit_the_body_bound` green here |
| 5 `CTR-presentation.E4` | pass | `render_advice()` only |
| 6 `EX.error` / S3 | pass | `logs/s3-move-run.log`, `logs/gesture-run.log` |
| 10 headless + graphical | pass | 28 suites; S3 panel, playability and pointer leg |
| 11 shipped graph, reachable backend | pass | `headless-20261023T190212Z/` |
| 12 lint / tests / coverage | pass | PR #752 green; verifier re-ran tests |

## What running found

1. **#753 does not reach the S3 leg it was used for.** Its reproduction is a press and release with no frame between them; a tap pair one frame apart moves a piece in S3 here. The refusal is not reproducible, so AC6's playability leg passes and #753 stays a sub-frame defect on its own terms.
2. **Nothing else moved.** The ink bound and the panel fix hold on the shipped graph.

## Residual risk

- `PER.R1` judged from the ink measurement; not re-photographed.
- This run's probes are new code; they ship next to their logs.
