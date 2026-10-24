# Build checks — issue #616, graphical acceptance run (re-recorded for #742)

The `#616` AC5 / AC6 legs, run on the judged build `origin/main` `cbce7cd`. Logs are in `logs/`.
Index: [`manifest.md`](manifest.md).

| Check | Result | Log |
|---|---|---|
| `gdscript_tests.py test` | 28 headless unit test(s) passed, exit 0 | `logs/unit-tests.log` |
| `gdscript_tests.py coverage` | 86.5% (4652/5375), threshold 80, exit 0 | `logs/coverage.log` |
| `gdlint game` | Success: no problems found | `logs/lint.log` |
| `gdformat --check game` | 62 files would be left unchanged | `logs/format-check.log` |
| `spec_lint.py` | 0 errors, 1 pre-existing glossary warning | `logs/spec-lint.log` |
| Guard non-vacuity | This run does not re-establish it; [`../headless-20261024T011913Z/`](../headless-20261024T011913Z/manifest.md) and the `#700` verification do, by reintroducing regressions and requiring a red run | — |

The coverage run needs `gdtoolkit`; on this host it lives in `~/.local` and is reached with
`PYTHONPATH`/`PATH` set, because the repo's default `python3` is `agent-orc/.venv`, which does not carry
it.
