#!/usr/bin/env python3
"""Run #374's `PTD-move-advice` evidence three times on the released scene graph.

Each phase starts its own reachable CTR-advice-stream peer (`peer.py`), runs
`drive.gd` against `res://main_release.tscn`, and stops the peer. Usage:

    python3 run_checks.py <run-dir> <repeat-count>
"""

from __future__ import annotations

import json
import os
import socket
import subprocess
import sys
import time
from pathlib import Path

GODOT = os.environ.get("GODOT_BIN", "godot")
PHASES = [
    ("advice", "normal", 0),
    ("lifecycle", "normal", 0),
    ("failure", "fail", 1),
]


def free_port() -> int:
    with socket.socket() as probe:
        probe.bind(("127.0.0.1", 0))
        return int(probe.getsockname()[1])


def wait_for_port(port: int, timeout_s: float = 5.0) -> bool:
    deadline = time.monotonic() + timeout_s
    while time.monotonic() < deadline:
        with socket.socket() as probe:
            probe.settimeout(0.2)
            if probe.connect_ex(("127.0.0.1", port)) == 0:
                return True
        time.sleep(0.05)
    return False


def run_once(run_dir: Path, phase: str, mode: str, fail_count: int, index: int) -> dict:
    logs = run_dir / "logs"
    port = free_port()
    peer_log = logs / f"peer-{phase}-{index}.jsonl"
    peer_log.unlink(missing_ok=True)
    peer = [
        sys.executable,
        str(logs / "peer.py"),
        "--port",
        str(port),
        "--mode",
        mode,
        "--key",
        "accept-key",
        "--fail-count",
        str(fail_count),
        "--log",
        str(peer_log),
    ]
    peer_out = open(logs / f"peer-{phase}-{index}.log", "w", encoding="utf-8")  # noqa: SIM115
    server = subprocess.Popen(peer, stdout=peer_out, stderr=subprocess.STDOUT)
    try:
        if not wait_for_port(port):
            return {"phase": phase, "index": index, "exit": -1, "checks": 0, "failed": -1}
        env = dict(os.environ)
        env.update(
            {
                "R374_ENDPOINT": f"http://127.0.0.1:{port}/advice",
                "R374_KEY": "accept-key",
                "R374_PHASE": phase,
                "R374_PEER_LOG": str(peer_log),
            }
        )
        log = logs / f"drive-{phase}-{index}.log"
        with open(log, "w", encoding="utf-8") as handle:
            code = subprocess.run(
                [GODOT, "--headless", "--path", "game", "--script", str(logs / "drive.gd")],
                env=env,
                stdout=handle,
                stderr=subprocess.STDOUT,
                check=False,
            ).returncode
        summary = {"checks": 0, "failed": -1}
        for line in log.read_text(encoding="utf-8").splitlines():
            if line.startswith("R374 {") and '"summary"' in line:
                summary = json.loads(line[len("R374 ") :])["summary"]
        peers = []
        if peer_log.is_file():
            peers = [json.loads(row) for row in peer_log.read_text(encoding="utf-8").splitlines() if row]
        return {
            "phase": phase,
            "index": index,
            "exit": code,
            "checks": summary.get("checks", 0),
            "failed": summary.get("failed", -1),
            "peer_requests": len(peers),
            "peer_failed": sum(1 for row in peers if row.get("failed")),
            "time_ms": [row.get("request", {}).get("time_ms") for row in peers],
            "api_keys": sorted({str(row.get("request", {}).get("api_key")) for row in peers}),
            "phen": sorted({str(row.get("request", {}).get("fen", "")) for row in peers}),
            "authorized": all(row.get("authorized") for row in peers),
        }
    finally:
        server.terminate()
        server.wait(timeout=10)
        peer_out.close()


def main() -> int:
    run_dir = Path(sys.argv[1]).resolve()
    repeats = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    rows = []
    for index in range(1, repeats + 1):
        for phase, mode, fail_count in PHASES:
            rows.append(run_once(run_dir, phase, mode, fail_count, index))
    (run_dir / "logs" / "repeats.json").write_text(json.dumps(rows, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(rows, indent=2))
    return 0 if all(row["exit"] == 0 and row["failed"] == 0 for row in rows) else 1


if __name__ == "__main__":
    raise SystemExit(main())
