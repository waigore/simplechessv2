# #486 acceptance — headless run (2026-10-24)

Acceptance evidence for defect [#486](https://github.com/waigore/simplechessv2/issues/486) ("Carry the verified PR #480 lost-body guard onto main").

The deliverables are scripts and docs (`issue_body_guard.py`, `gh_issue.py`, `spec_lint.py`, `docs/issues/body-writes.md`). They do not change playable behavior, so no gameplay playtest protocol applies and no graphical screenshots are required.

## Build under test

- `origin/main` at `3a7d538` ("Record #592 graphical acceptance evidence (#669)").
- No drift since the fix landed except one line of `docs/issues/body-writes.md` (line 26, adding fences and rules to the "set aside" list): `git diff --stat 0cb0a01 origin/main -- .github/scripts/issue_body_guard.py .github/scripts/gh_issue.py .github/scripts/spec_lint.py docs/issues/body-writes.md` → 1 file changed, 1 insertion(+), 1 deletion(-).

## Files

| File | What it is |
|---|---|
| `guard-matrix.txt` | The three lost-body shapes from the issue, plus three widened shapes and two must-pass controls, run through `findings()` in both modes and through the CLI. |
| `pytest.txt` | `pytest .github/scripts/tests/test_issue_body_guard.py .github/scripts/tests/test_gh_issue.py .github/scripts/tests/test_spec_lint.py -q` |
| `spec-lint.txt` | `python3 .github/scripts/spec_lint.py` (the `unsafe-body` check lives here). |

## Results by acceptance criterion

1. **Guard rejects heading-only and sentinel-line bodies in both modes, with tests.** Confirmed by `guard-matrix.txt` (write and readback both reject; CLI exits 1) and `pytest.txt`. Controls show a `@-` inside a sentence and a normal body both pass, so the guard does not overreach.
2. **`gh_issue.py` read-back exits 1 on those stored shapes.** [`.github/scripts/gh_issue.py`](../../../../.github/scripts/gh_issue.py) imports `findings` (line 29), guards before writing (line 101), and re-runs `findings(stored, readback=True)` returning 1 on any finding (lines 113–119). Covered by `test_lost_body_shapes_fail_the_read_back` in `pytest.txt`.
3. **Docs state the widened rule and `Spec lint` fails prose that restates the narrow rule.** `guard-matrix.txt` and `spec-lint.txt`; `NARROW_RULE_RE` is at [`.github/scripts/spec_lint.py`](../../../../.github/scripts/spec_lint.py) line 455 and the `unsafe-body` finding at line 485. `test_narrow_body_rule_in_docs_fails` and `test_widened_body_rule_passes` cover both directions.
4. **CI green on the commit that landed the fix.** Check runs on `0cb0a01`: Code lint, Coverage, Spec lint, Unit tests, Web playtest — all `success`. The PR (#669) that produced `3a7d538` also ran Advice backend, Code lint, Coverage, Deploy to Pages, Release export, Spec lint, Unit tests, and Web playtest on its head commit `a68640a` — all `success`.
