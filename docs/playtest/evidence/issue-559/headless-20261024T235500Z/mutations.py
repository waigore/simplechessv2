#!/usr/bin/env python3
"""Mutation checks for #559's readiness test (`game/advice_readiness_test.gd`).

Each mutation is applied to a scratch copy of a main script, the readiness test
is run headless against it, the file is restored, and the FAIL line is kept. A
mutation that still passes means the test is not measuring what it claims.

The bound is not shaved to the observed worst: a 300 ms stall in the move path
must fail too, so the ceiling rejects a slow move, not only a hung one.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
GODOT = "godot"
CLIENT = ROOT / "game" / "advice_client.gd"
SESSION = ROOT / "game" / "shared_game_session.gd"

START_WAITS = (
    "\t_transport.start(endpoint, message, request_time_ms())\n\treturn true",
    "\t_transport.start(endpoint, message, request_time_ms())\n"
    "\tOS.delay_msec(20)\n\tpoll({})\n\treturn true",
)
T6_IGNORED = (
    "\tif advice_time_ms < ADVICE_TIME_MIN_MS or advice_time_ms > ADVICE_TIME_MAX_MS:\n"
    "\t\treturn ADVICE_TIME_DEFAULT_MS\n\treturn advice_time_ms",
    "\treturn 3500",
)
MOVE = "\tvar applied := try_move(from_square, to_square, promotion)"
MOVE_WAITS = (
    MOVE,
    "\tif advice_client != null and advice_client._transport != null:\n"
    "\t\tOS.delay_msec(120)\n" + MOVE,
)
MOVE_STALLS = (
    MOVE,
    "\tif advice_client != null and advice_client._transport != null:\n"
    "\t\tOS.delay_msec(300)\n" + MOVE,
)
MUTATIONS = [
    ("start waits for the answer", CLIENT, START_WAITS),
    ("T6 ignored, always 3500", CLIENT, T6_IGNORED),
    ("move path waits on the stream", SESSION, MOVE_WAITS),
    ("move path stalls 300 ms", SESSION, MOVE_STALLS),
]


def main() -> int:
    problems = 0
    for name, path, (old, new) in MUTATIONS:
        original = path.read_text(encoding="utf-8")
        if old not in original:
            print(f"SKIP {name}: anchor not found in {path.name}")
            problems += 1
            continue
        try:
            path.write_text(original.replace(old, new, 1), encoding="utf-8")
            proc = subprocess.run(
                [GODOT, "--headless", "--path", "game", "-s", "res://advice_readiness_test.gd"],
                cwd=ROOT,
                capture_output=True,
                text=True,
                timeout=300,
                check=False,
            )
        finally:
            path.write_text(original, encoding="utf-8")
        fails = [
            line
            for line in f"{proc.stdout}{proc.stderr}".splitlines()
            if line.startswith("FAIL")
        ]
        verdict = f"FAIL as expected: {fails[0]}" if proc.returncode != 0 else "STILL PASSES"
        print(f"{name}: exit {proc.returncode} — {verdict}")
        problems += 0 if proc.returncode != 0 else 1
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
