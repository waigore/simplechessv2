#!/usr/bin/env python3
"""Run #559's checks and store their raw output under logs/.

Each command's combined stdout/stderr is written to ``logs/<step>.log`` and its
exit code recorded in ``logs/<step>.status``, so the evidence quotes real logs
rather than retyped numbers. ``CI_COV_OUT`` leaks into the environment of the
tests the coverage run inspects, so every run starts from a clean system shell.
"""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
LOGS = HERE / "logs"
GDTK = Path("/private/var/folders/nj/j957smtj3jz0fn193bb2g_2c0000gn/T/opencode/gdtk/bin")
STEPS: dict[str, str] = {
    "advice-readiness": "godot --headless --path game -s res://advice_readiness_test.gd",
    "unit-tests": "python3 .github/scripts/gdscript_tests.py test",
    "coverage": "python3 .github/scripts/gdscript_tests.py coverage",
    "gdformat-check": "gdformat --check game",
    "gdlint": "gdlint game",
    "spec-lint": "python3 .github/scripts/spec_lint.py",
    "mutations": "python3 docs/playtest/evidence/issue-559/headless-20261024T235500Z/mutations.py",
}


def main(argv: list[str]) -> int:
    steps = argv or list(STEPS)
    root = HERE.parents[4]
    LOGS.mkdir(parents=True, exist_ok=True)
    failed = 0
    for step in steps:
        command = STEPS[step]
        env = {
            "PATH": f"{GDTK}:{os.environ['PATH']}",
            "HOME": os.environ["HOME"],
            "GODOT_BIN": os.environ.get("GODOT_BIN", "/opt/homebrew/bin/godot"),
        }
        proc = subprocess.run(
            command,
            shell=True,
            executable="/bin/bash",
            cwd=root,
            env=env,
            capture_output=True,
            text=True,
            timeout=1800,
            check=False,
        )
        log = f"$ {command}\n\n{proc.stdout}{proc.stderr}"
        (LOGS / f"{step}.log").write_text(log, encoding="utf-8")
        (LOGS / f"{step}.status").write_text(f"{proc.returncode}\n", encoding="utf-8")
        print(f"{step}: exit {proc.returncode}")
        failed |= proc.returncode
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
