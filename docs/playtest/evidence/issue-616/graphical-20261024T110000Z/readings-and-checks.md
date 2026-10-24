# Rendering reading and checks — issue #616 acceptance run (graphical)

Index: [`manifest.md`](manifest.md) · What was run: [`run.md`](run.md) · Logs: [`paths.md`](paths.md).

## Live loop

`render fps=118.0 process_ms=91.46 draw_calls=28` at 390×844 with `caps-frame-3239.png` captured on that
same frame. This is a liveness reading — the per-state captures came from a running loop, not a frozen
first frame — and not an `O10`/`SIT.4` timing claim.

## Checks

| Check | Result |
|---|---|
| `gdscript_tests.py test` | 26 headless unit test(s) passed, exit 0 |
| `gdscript_tests.py coverage` | 86.4% (4500/5211), threshold 80, exit 0 |
| `gdlint game` | Success: no problems found |
| `gdformat --check game` | 59 files would be left unchanged |
| `spec_lint.py` | 0 errors, 1 pre-existing glossary warning |

The coverage run needs `gdtoolkit`, which on this machine lives in `/Library/Frameworks/Python.framework/Versions/3.11`;
the script's default `python3` is the repo's `agent-orc/.venv`, which does not carry it.
