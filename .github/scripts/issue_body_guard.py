#!/usr/bin/env python3
"""Reject an issue body or comment that would destroy the durable contract.

Guard against the 2026-10-22 batch in issue #470, where a writer passed a
literal `@-` to `gh issue edit --body` (and `gh issue comment --body`), which
`gh` stores verbatim instead of reading stdin. One rule, both modes: a body is
rejected when, with HTML comments and headings set aside, nothing is left but
the `@-` sentinel, an authoring placeholder, or nothing at all. A `@-` inside
prose ("never pass `@-` to --body") is text and passes. Safe invocation and the
mandatory read-back are documented in docs/issues/body-writes.md.

Usage:
  issue_body_guard.py <file>              # guard the file, e.g. stdin captured with --body-file -
  issue_body_guard.py --readback <file>   # read-back after a write: same rule; a body with no '#' heading only warns
Exit 1 when the text is rejected; 0 when it is safe to write or a read-back holds content.
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
# Headings carry structure, not content: a heading alone is the usual shape of a lost body.
HEADING_LINE_RE = re.compile(r"^[ \t]*#{1,6}\s.*$", re.M)
SENTINEL_LINE_RE = re.compile(r"^[ \t]*" + re.escape(STDIN_SENTINEL) + r"[ \t]*$")
FENCE_RE = re.compile(r"[ \t]*(?:`{3,}|~{3,}).*")
RULE_RE = re.compile(r"[ \t]*(?:[-*_][ \t]*){3,}")
WORD_RE = re.compile(r"[^\W_]+")


def without_lines(pattern: re.Pattern[str], text: str) -> str:
    """Text with lines the pattern matches in full removed; line-wise, so `^…$` never swallows a block."""
    return "\n".join(line for line in text.splitlines() if not pattern.fullmatch(line))


def findings(text: str, *, readback: bool = False) -> list[str]:
    """Reasons the text is unsafe to write, or (readback) signs the stored text is lost."""
    if not re.sub(COMMENT_RE, "", text).strip():
        return ["body is empty or holds only HTML comments"]
    problems = []
    if PLACEHOLDER_RE.search(text):
        problems.append("body still holds an authoring placeholder (<!-- Template: … --> or <!-- fill in -->)")
    # With comments, headings, fences, and rules set aside: a sentinel line is damage, a word is
    # content, and a sentinel inside a sentence is prose that describes the hazard.
    lines = [line for line in without_lines(HEADING_LINE_RE, COMMENT_RE.sub("", text)).splitlines() if line.strip()]
    lines = [line for line in lines if not FENCE_RE.fullmatch(line) and not RULE_RE.fullmatch(line)]
    if not lines:
        problems.append("body holds a heading but no content under it")
    elif all(SENTINEL_LINE_RE.fullmatch(line) for line in lines):
        problems.append("body holds no content beyond '@-': gh stores the sentinel verbatim; use --body-file - for stdin")
    elif not WORD_RE.search("\n".join(lines)):
        problems.append("body holds a heading but no content under it")
    if readback and not problems and not HEADING_RE.search(text):
        print("::warning title=Issue body guard::read-back has no '#' heading; check the stored body by hand")
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
