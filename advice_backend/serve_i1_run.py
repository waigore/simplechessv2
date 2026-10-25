#!/usr/bin/env python3
"""Operator run for issue #671: the served-snapshot I1 check on the catalog host.

The transcript the issue asks for, produced by the two commands it names, in
the only order SCH-puzzle-catalog L2-L3 allow: a served snapshot is built once
and never rewritten in place.

  1. Refuse a served path that already holds a file, so a second run can never
     overwrite what the route serves (ADR-0008: a new snapshot is a new decision).
  2. `python3 -m advice_backend.catalog build <export.csv> <served path>`,
     keeping the `snapshot <path>: <n> records` stdout line.
  3. `python3 -m advice_backend.catalog check <served path>` with no
     `--expected-count`, keeping stdout and the exit code.
  4. Hash and stat the served file after the check, so its identity describes
     exactly what was checked.

Both commands keep stdout and exit code and echo them; the check re-parses
every row, so give it time. Then start the deployment and paste the server's
`catalog_records=` start line and one deal's `snapshot_id` into the transcript,
which ends with placeholders for both.

Usage, from a clean checkout of the repo:
  python3 advice_backend/serve_i1_run.py <export.csv> <served path> [--transcript OUT.md]
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import subprocess
import sys
import time
from pathlib import Path


DEFAULT_EXPECTED = 6_157_341


def repo_state(tree: Path) -> tuple[str, str]:
    """The commit the run is attributed to, and whether the tree is clean."""
    def run(*args: str) -> str:
        return subprocess.run(
            ["git", *args], cwd=tree, capture_output=True, text=True, check=True
        ).stdout.strip()

    try:
        commit = run("rev-parse", "HEAD")
        status = run("status", "--porcelain")
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "unknown", "(not a git checkout)"
    return commit, "clean" if not status else status.replace("\n", " ")


def elapsed_line(started: float) -> str:
    return f"{time.monotonic() - started:.1f} s"


def demand_fresh(served: Path) -> None:
    """Refuse a served path that already holds a snapshot (L2-L3: never rewritten in place)."""
    if served.exists():
        sys.exit(
            f"refusing to rebuild: {served} already exists. The served snapshot is never "
            "rewritten in place (SCH-puzzle-catalog L2-L3). To check it as it stands, run "
            f"`python3 -m advice_backend.catalog check {served}`; to build a new snapshot, "
            "move the old one aside deliberately first."
        )


def require_export(export: Path) -> None:
    """Stop before any write when the export is not where the operator said it is."""
    if not export.is_file():
        sys.exit(f"export not found: {export}")


def run_catalog(*arguments: str) -> tuple[int, list[str]]:
    """One `python3 -m advice_backend.catalog` call, echoed with its output and exit code."""
    command = [sys.executable, "-m", "advice_backend.catalog", *arguments]
    print(f"$ {' '.join(command)}", flush=True)
    result = subprocess.run(command, capture_output=True, text=True)
    lines = [line for line in result.stdout.splitlines() if line.strip()]
    for line in lines:
        print(line, flush=True)
    print(f"exit {result.returncode}", flush=True)
    return result.returncode, lines


def build(export: Path, served: Path) -> tuple[int, list[str]]:
    """Run the build and keep its stdout lines, including the `snapshot <path>: <n> records` line."""
    return run_catalog("build", str(export), str(served))


def run_check(served: Path) -> tuple[int, list[str]]:
    """Run the default-count check; return its exit code and stdout lines."""
    return run_catalog("check", str(served))


def identify(served: Path) -> dict[str, object]:
    """The served file's identity, read after the check so it describes what was checked."""
    digest = hashlib.sha256()
    with open(served, "rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    stat = served.stat()
    return {
        "path": str(served.resolve()),
        "bytes": stat.st_size,
        "mtime": dt.datetime.fromtimestamp(stat.st_mtime, dt.timezone.utc).isoformat(),
        "sha256": digest.hexdigest(),
    }


def rows(
    commit: str, clean: str, export: Path, served: Path, build_lines: list[str],
    code: int, findings: list[str], identity: dict[str, object], build_seconds: str,
    check_seconds: str,
) -> list[tuple[str, str]]:
    """The transcript rows the issue body asks for, in its order, pending the server lines."""
    return [
        ("Date", dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds")),
        ("Repo commit", f"`{commit}` (`git status --porcelain`: {clean})"),
        ("Export", f"`{export.resolve()}`"),
        ("Build stdout", "`" + "; ".join(build_lines) + "`"),
        ("Build elapsed", build_seconds),
        ("Check", f"`python3 -m advice_backend.catalog check {served.resolve()}` (no `--expected-count`)"),
        ("Check output", "`" + ("; ".join(findings) if findings else "(no findings)") + "`"),
        ("Check exit", str(code)),
        ("Check elapsed", check_seconds),
        ("Served path", f"`{identity['path']}`"),
        ("Served bytes", f"{identity['bytes']}"),
        ("Served mtime (UTC)", f"{identity['mtime']}"),
        ("Served SHA-256", f"`{identity['sha256']}`"),
        ("Server start line", "pending — paste the `listening on <host>:<port> catalog_records=` line"),
        ("Deal `snapshot_id`", "pending — paste F1 `snapshot_id` from one live deal on that server"),
    ]


def write_transcript(out: Path, issue: int, rows_: list[tuple[str, str]], expected: int) -> None:
    """One table the operator can paste into the issue body's evidence file."""
    lines = [
        f"# Issue #{issue} — served-snapshot I1 run (operator transcript)",
        "",
        f"Generated by `advice_backend/serve_i1_run.py`. The gate requires {expected:,} records;",
        "the `check` pass means I1-I3 hold over the served file at that count.",
        "",
        "| Field | Value |",
        "|---|---|",
        *(f"| {name} | {value} |" for name, value in rows_),
        "",
        "## What this does not prove",
        "",
        "`snapshot_id` is the `SNAPSHOT_ID` constant, stamped into records, not read from",
        "the built file; a `check` pass over any file at the expected count exits 0. The",
        "served path, byte count, mtime and SHA-256 above are what tie the checked file to",
        "the one the route reads; the server start line and the deal's F1 `snapshot_id`",
        "above are what tie that file to the running route. Fill both in before pasting.",
        "",
    ]
    out.write_text("\n".join(lines), encoding="utf-8")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Record the served-snapshot I1 run (issue #671).")
    parser.add_argument("export", type=Path, help="the downloaded Lichess export CSV")
    parser.add_argument("served", type=Path, help="the path the catalog route serves")
    parser.add_argument("--transcript", type=Path, default=Path("i1-host-run.md"))
    parser.add_argument("--issue", type=int, default=671)
    parser.add_argument(
        "--expected",
        type=int,
        default=DEFAULT_EXPECTED,
        help=f"served record count the transcript reports (default {DEFAULT_EXPECTED:,})",
    )
    arguments = parser.parse_args(argv)

    tree = Path.cwd()
    require_export(arguments.export)
    demand_fresh(arguments.served)
    commit, clean = repo_state(tree)

    started = time.monotonic()
    build_code, build_lines = build(arguments.export, arguments.served)
    build_seconds = elapsed_line(started)
    if build_code != 0:
        sys.exit(f"build failed with exit {build_code}; nothing was checked")

    started = time.monotonic()
    code, findings = run_check(arguments.served)
    check_seconds = elapsed_line(started)

    identity = identify(arguments.served)
    transcript = rows(
        commit, clean, arguments.export, arguments.served, build_lines, code, findings,
        identity, build_seconds, check_seconds,
    )
    write_transcript(arguments.transcript, arguments.issue, transcript, arguments.expected)
    print(f"transcript written to {arguments.transcript}", flush=True)
    return code


if __name__ == "__main__":
    raise SystemExit(main())
