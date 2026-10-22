#!/usr/bin/env python3
"""Reject an issue body or comment that would destroy the durable contract.

Guard against the 2026-10-22 batch in issue #470, where a writer passed a
literal `@-` to `gh issue edit --body` (and `gh issue comment --body`), which
`gh` stores verbatim instead of reading stdin. The body is rejected when it is
empty (or comments only), is exactly `@-`, or still holds an authoring
placeholder. Safe invocation and the mandatory read-back are documented in
docs/issues/body-writes.md.

Usage:
  issue_body_guard.py <file>              # guard the file, e.g. stdin captured with --body-file -
  issue_body_guard.py --readback <file>   # read-back after a write: also reject bodies that no longer hold a `#` heading
Exit 1 when the text is rejected; 0 when it is safe to write or a read-back looks intact.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

STDIN_SENTINEL = "@-"
HEADING_RE = re.compile(r"^#{1,6}\s+\S")
COMMENT_RE = re.compile(r"<!--.*?-->", re.S)
# Authoring placeholders: the template comment and the spec/docs `<!-- fill in -->` marker.
PLACEHOLDER_RE = re.compile(r"^\s*<!--\s*(?:Template:|fill in)\s*", re.I | re.M)


def findings(text: str, *, readback: bool = False) -> list[str]:
    """Reasons the text is unsafe to write, or (readback) signs the stored text is lost."""
    if not re.sub(COMMENT_RE, "", text).strip():
        return ["body is empty or holds only HTML comments"]
    stripped = text.strip()
    if stripped == STDIN_SENTINEL:
        return ["body is exactly '@-': gh stores it verbatim; use --body-file - for stdin (docs/issues/body-writes.md)"]
    problems = []
    if PLACEHOLDER_RE.search(text):
        problems.append("body still holds an authoring placeholder (<!-- Template: … --> or <!-- fill in -->)")
    if readback and not HEADING_RE.search(text):
        problems.append("read-back has no '#' heading; the stored body does not look like the one that was written")
    return problems


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("file", type=Path, help="file holding the body, or '-' for stdin")
    parser.add_argument("--readback", action="store_true", help="validate text read back from GitHub after a write")
    args = parser.parse_args(argv)

    text = sys.stdin.read() if str(args.file) == "-" else args.file.read_text(encoding="utf-8")
    problems = findings(text, readback=args.readback)
    for problem in problems:
        print(f"::error title=Issue body guard::rejected: {problem}")
    if problems:
        return 1
    print(f"Issue body guard: {'read-back' if args.readback else 'body'} OK.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
