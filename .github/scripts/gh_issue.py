#!/usr/bin/env python3
"""Write an issue body or comment through the guard, so a lost contract fails before the remote call.

Wraps `gh issue create|edit|comment` from issue #474: the body is read from a file (or
stdin) and validated by issue_body_guard.py before `gh` runs, so a body with nothing
but a `@-` sentinel, an empty or comment-only body, or a heading with no content never
reaches GitHub. The write is read back with `gh issue view` and validated by the same
rule, so a body that came back holding only a sentinel also exits 1 (the write itself
cannot be undone by the wrapper; recover per docs/issues/body-writes.md). Safe
invocation, the guard, and the read-back are documented in docs/issues/body-writes.md.

Usage:
  gh_issue.py comment 12 --file body.md [-- gh args]   # post a guarded comment
  gh_issue.py edit 12 --file body.md [-- gh args]      # replace a guarded body
  gh_issue.py create --file body.md -- --title … --label type:task
  gh_issue.py comment 12 -                             # body from stdin
Exit 0 when the write landed intact; 1 when it was rejected before writing or failed the read-back.
"""
from __future__ import annotations

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from issue_body_guard import findings  # noqa: E402

ACTIONS = ("create", "edit", "comment")


def read_body(source: str) -> str:
    """The composed body: the named file, or stdin for '-'."""
    return sys.stdin.read() if source == "-" else Path(source).read_text(encoding="utf-8")


def _run_gh(args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["gh", *args], capture_output=True, text=True, check=False)


def write_body(action: str, target: str | None, body: str, extra: list[str]) -> subprocess.CompletedProcess[str]:
    """Hand the validated body to `gh` through `--body-file`, which copies from a real file."""
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as handle:
        handle.write(body)
        path = handle.name
    command = ["issue", action, *([target] if target else []), "--body-file", path, *extra]
    try:
        return _run_gh(command)
    finally:
        Path(path).unlink(missing_ok=True)


def read_back(action: str, target: str | None, written: subprocess.CompletedProcess[str]) -> str | None:
    """The stored text after the write, or the number reported by `gh issue create`."""
    if action == "create":
        url = written.stdout.strip().splitlines()[-1] if written.stdout.strip() else ""
        number = url.rstrip("/").rsplit("/", 1)[-1]
        target = number if number.isdigit() else None
    if not target:
        return None
    viewed = _run_gh(["issue", "view", target, "--json", "body", "--jq", ".body"])
    return viewed.stdout if viewed.returncode == 0 else None


def parse(argv: list[str]) -> argparse.Namespace:
    """`--file` is accepted before or after the issue number; args after `--` go to `gh`."""
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("action", choices=ACTIONS)
    parser.add_argument("number", nargs="?", help="issue number; omitted for create")
    parser.add_argument("--file", dest="source", required=True, help="body file, or '-' for stdin")
    head, extra = (argv[: argv.index("--")], argv[argv.index("--") + 1 :]) if "--" in argv else (argv, [])
    positionals, source = [], None
    remaining = iter(head)
    for item in remaining:
        if item == "--file":
            source = next(remaining, None)
        elif item.startswith("--file="):
            source = item.split("=", 1)[1]
        elif item.startswith("-"):
            parser.error(f"unrecognized argument: {item} (pass gh args to `gh` after `--`)")
        else:
            positionals.append(item)
    if len(positionals) > 2:
        parser.error(f"unrecognized arguments: {' '.join(positionals[2:])} (pass gh args to `gh` after `--`)")
    if not positionals or positionals[0] not in ACTIONS:
        parser.error(f"action must be one of {', '.join(ACTIONS)}")
    if source is None:
        parser.error("the following arguments are required: --file")
    args = argparse.Namespace(action=positionals[0], number=positionals[1] if len(positionals) > 1 else None,
                              source=source, extra=extra)
    if args.action != "create" and not args.number:
        parser.error(f"{args.action} needs an issue number")
    return args


def main(argv: list[str] | None = None) -> int:
    args = parse(sys.argv[1:] if argv is None else argv)
    body = read_body(args.source)
    problems = findings(body)
    for problem in problems:
        print(f"::error title=Issue body guard::rejected before writing: {problem}")
    if problems:
        return 1

    written = write_body(args.action, args.number, body, args.extra)
    sys.stdout.write(written.stdout)
    sys.stderr.write(written.stderr)
    if written.returncode != 0:
        return written.returncode

    stored = read_back(args.action, args.number, written)
    if stored is not None:
        problems = findings(stored, readback=True)
        for problem in problems:
            print(f"::error title=Issue body guard::read-back failed: {problem}")
        if problems:
            return 1
    print("Issue body guard: write OK and read back intact.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
