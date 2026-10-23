## Summary

The #224 defect was verified on `ba6a59a` (PR #663), but two lines in its own expected behavior still did not hold. This PR closes those two spec gaps and records a headless acceptance run of the fixed protocol.

1. **`ENV` citation.** #224's expected behavior is phrased against `ENV` IDs, and `ids.md` says an environment "is a tool row like any other Must tool, so protocols, procedures, the technical design, and evidence cite it the same way". No protocol cited one. Each environment line now names it — `ENV.1` for the Design protocols, `ENV.1` and `ENV.2` for `PTU-shared-session` — keeping the plain-language wording beside it.
2. **Dangling evidence link.** The Evidence paragraph in `design/progression.md` linked `../evidence.md#cite-from-acceptance`, which does not resolve from `specs/playtest/design/`. It now links `../evidence.md`, and every protocol's Evidence opens on "Default evidence rules ([`evidence.md`](../evidence.md))", the wording `shared-game.md` and `mode-and-config.md` already used.

## Issue

Refs #224

## Authority

- [`specs/playtest/design/progression.md`](specs/playtest/design/progression.md) — the fixed protocol.
- [`.agents/specs/rules/playtest/ids.md`](.agents/specs/rules/playtest/ids.md) — an environment is a Must tool row protocols cite.
- [`.agents/specs/rules/playtest/protocol.md`](.agents/specs/rules/playtest/protocol.md) §Evidence — "Default evidence rules" when the protocol states no extras.
- [`specs/playtest/evidence.md`](specs/playtest/evidence.md) — the screenshot and headless rules the protocols now point at.

## Changes

- `specs/playtest/design/*.md` (12 protocols) — environment line names its `ENV`; Evidence line links `evidence.md` and states no extras.
- `specs/playtest/ux/shared-session.md` — same, citing `ENV.1` and `ENV.2`.
- `docs/playtest/evidence/issue-224/` — the acceptance comment, its addendum, and the `ENV.1` run folder (`manifest.md`, `notes.md`, `probe/accept224_probe.gd`, `logs/`).

## Test plan

- `python3 .github/scripts/spec_lint.py` — 1 error, 1 warning, both pre-existing and outside this diff: an untracked working-tree file from another session, and the `specs/view/glossary.md` duplicate definition. `specs/playtest/` is clean.
- `godot --headless --path game --script docs/playtest/evidence/issue-224/headless-20261024T010000Z/probe/accept224_probe.gd` — `A224 SUMMARY pass=11 fail=0 not-judged=2`.
- Spec-only change: `review-code`, `Unit tests`, and `Coverage` see no code diff.

## Evidence

- `docs/playtest/evidence/issue-224/headless-20261024T010000Z/manifest.md` — `PTD-progression` on `ENV.1`; 11 pass, 0 fail, 2 not-judged (both need a dealt puzzle, which this build does not deal — #655/#648). Screenshot paths marked waiting on a graphical re-run.
