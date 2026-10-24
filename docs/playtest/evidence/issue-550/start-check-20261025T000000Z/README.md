# Evidence folder — #550 wave-2 playtest sweep, 2026-10-25 start-condition check (parallel id 2)

**This folder is not a sweep run.** It contains no story-row manifest and no protocol verdict,
because the run's hard start condition — a build where the first catalog read resolves — is still
unmet. #550's Description forbids re-recording the known `dealt=false` result as a new evidence set:

> Until #655 lands, this run does not start; it does not re-record the same `dealt=false` result
> as a new evidence set.

What it does contain is the measurement that decided that, taken on `origin/main` **`1890c29`**, so a
later reader does not have to trust a comment. #550's AC forbids this pass changing anything outside
`docs/playtest/evidence/issue-550/`; the measurement therefore lives here and nowhere else. It
carries no `manifest.md`, so it is not a candidate evidence set for the epic's gate, and it does not
supersede the `20261024T000000Z` pair the body already names.

| File | What it records |
|---|---|
| [`notes.md`](notes.md) | The start condition, what was measured, and why no sweep ran |
| [`logs/x655-probe.log`](logs/x655-probe.log) | The unchanged #655 probe's output on `1890c29`: the `B5` refusal warning and the `TEL.1`–`TEL.5` lines |
