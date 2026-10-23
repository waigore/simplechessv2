## Acceptance: waiting on screenshots — no protocol failed

Acceptance testing of the acceptance branch over `origin/main` `43ea9ec`, after the 2026-10-23 verification that passed `ba6a59a` (PR #663). The defect's three filed failures are re-checked against the tree, not against the verify comment.

### The filed defect

All three failures are fixed:

1. **`Cites` includes `P3`** — `specs/playtest/design/progression.md` reads `- **Cites**: PRG (A1, P1, P2, P3, M1, F1, Z1–Z3)`; `PRG.P3` exists in `specs/design/progression.md`.
2. **`Z1–Z3` carry their own meaning** — `S4`/`P2` now attribute "Shared game has no progression axis" to `A1`/`F1`, and cite `PRG.Z1–Z3` only as "no completion gate stops leaving the stream".
3. **No blanket Headless screenshot waiver** — the Evidence paragraph states no extras and waives no screenshot; the screenshot rule lives once in [`evidence.md`](../blob/main/specs/playtest/evidence.md).

### Two follow-on gaps closed on the same branch

The expected behavior's third bullet also asks the protocol's evidence to follow the evidence rules, which two lines still did not:

- **The `ENV` citation.** The expected behavior is phrased against `ENV` IDs, and [`ids.md`](../blob/main/.agents/specs/rules/playtest/ids.md) says an environment "is a tool row like any other Must tool, so protocols … cite it the same way". No protocol on `main` cited one. Each environment line now names it — `ENV.1` for every Design protocol, `ENV.1` and `ENV.2` for `PTU-shared-session` — and keeps the plain-language wording beside it.
- **A dangling link.** The Evidence paragraph linked `../evidence.md#cite-from-acceptance`, a GitHub-style path that does not resolve from `specs/playtest/design/`; it now links `../evidence.md` relatively.

### Playtesting

The deliverables are **spec-only**, so by the hub gate in [`playtest.md`](../blob/main/specs/playtest/playtest.md) playtesting is not required. I ran the in-scope protocol anyway, because acceptance is the only place the fixed protocol is executed:

[`docs/playtest/evidence/issue-224/headless-20261024T010000Z/manifest.md`](../blob/main/docs/playtest/evidence/issue-224/headless-20261024T010000Z/manifest.md) — `ENV.1` of `PTD-progression` on `4.7.2.stable` (`sess-1792797116424-23630-playtest`): `pass=11 fail=0 not-judged=2`. S1 persistence (`PRG.A1`/`P1`/`P2`/`P3`/`M1`), the S2 recent-window cap, order and drop, and S4's Shared-carries-nothing checks all pass. Two S1 rows (`A1` commit-after-result, `P3` append-on-`END.W1`) are `not-judged` only because this build deals no puzzle (catalog `T9`/`T10` unset, `configuration.md` B3 — tracked by #655/#648): a deployment value, not a protocol failure.

No cited story in `PTD-progression` failed, so no defect is filed.

### Why acceptance waits

`PTD-progression` states no screenshot exemption and this was a headless run, so the graphical-run screenshots it requires are not in the repo yet. Per [`evidence.md`](../blob/main/specs/playtest/evidence.md) §Headless run and the accept contract, that omission is no fail and files no defect.

**Status:** stays `status:pending-acceptance`, waiting on a graphical re-run of the same build writing `docs/playtest/evidence/issue-224/graphical-*/screenshots/`. A graphical run of a persistence protocol may leave those rows `not-judged` again; whether that satisfies the playtest obligation for a spec-only deliverable is the product owner's call, and I have not assumed it.
