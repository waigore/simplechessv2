#!/usr/bin/env python3
"""Stand-in UCI engine for the #373 advice backend (no Stockfish shipped).

Same shape as the backend's own test stand-in: ticks until its own cap or
`stop`, then prints a bestmove. Used only so the acceptance run exercises the
real `advice_backend` over a real socket.
"""

import select
import sys
import time

searching = False
limit = 0.0
started = 0.0
depth = 0
while True:
    if searching:
        if depth == 0:
            started = time.monotonic()
        if time.monotonic() - started >= limit:
            print("bestmove e2e4", flush=True)
            searching = False
            continue
        depth += 1
        print(f"info depth {depth} score cp {12 * depth} pv e2e4 e7e5", flush=True)
        ready, _, _ = select.select([sys.stdin], [], [], 0.008)
        if not ready:
            continue
        line = sys.stdin.readline()
    else:
        line = sys.stdin.readline()
    if not line:
        break
    line = line.strip()
    if line.startswith("go movetime"):
        limit = float(line.split()[2]) / 1000
        depth = 0
        searching = True
    elif line == "stop":
        if searching:
            print("bestmove e2e4", flush=True)
        searching = False
    elif line == "quit":
        break
