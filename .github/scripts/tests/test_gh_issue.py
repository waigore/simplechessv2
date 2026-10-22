"""Tests for gh_issue.py: the guarded issue-body/comment writer for issue #474.

`gh` is replaced by an in-memory fake so the pre-flight rejection leaves the stored
body untouched, and the read-back runs against what the fake actually stored.
"""
from __future__ import annotations

import io
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

import gh_issue  # noqa: E402

BODY = "# Guarded write\n\nA body a reader can use.\n"


class StoredRepo:
    """The minimum `gh issue` surface the wrapper uses, keeping state between calls."""

    def __init__(self, bodies: dict[str, str] | None = None) -> None:
        self.bodies = dict(bodies or {"12": "## Description\n\nOriginal body.\n"})
        self.calls: list[list[str]] = []

    def __call__(self, args: list[str], *, input_text: str | None = None) -> subprocess.CompletedProcess[str]:
        self.calls.append(args)
        if args[1] == "view":
            number = args[2]
            return subprocess.CompletedProcess(args, 0, self.bodies.get(number, ""), "")
        if "--body-file" in args:
            path = Path(args[args.index("--body-file") + 1])
            written = path.read_text(encoding="utf-8")
            if args[1] == "create":
                number = str(len(self.bodies) + 1)
                self.bodies[number] = written
                return subprocess.CompletedProcess(args, 0, f"https://github.com/o/r/issues/{number}\n", "")
            number = args[2]
            if args[1] == "comment":
                self.bodies[number] = self.bodies.get(number, "") + "\n" + written
                return subprocess.CompletedProcess(args, 0, "", "")
            self.bodies[number] = written
            return subprocess.CompletedProcess(args, 0, "", "")
        return subprocess.CompletedProcess(args, 1, "", "error: body is required (usage: gh issue edit …)")


class GhIssueTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.body_file = Path(self.tmp.name, "body.md")

    def run_wrapper(self, repo: StoredRepo, source: str, *argv: str) -> tuple[int, str]:
        stdout = io.StringIO()
        tail = argv[argv.index("--") :] if "--" in argv else ()
        head = argv[: argv.index("--")] if "--" in argv else argv
        with mock.patch.object(gh_issue, "_run_gh", repo), mock.patch.object(sys, "stdin", io.StringIO(BODY)), \
                mock.patch.object(sys, "stdout", stdout):
            code = gh_issue.main([*head, "--file", source, *tail])
        return code, stdout.getvalue()

    def write_body(self, text: str) -> str:
        self.body_file.write_text(text, encoding="utf-8")
        return str(self.body_file)

    def test_literal_sentinel_never_reaches_gh(self) -> None:
        for text in ("@-\n", "@-", "  @-  \n"):
            with self.subTest(text=text):
                repo = StoredRepo()
                code, out = self.run_wrapper(repo, self.write_body(text), "edit", "12")
                self.assertEqual(code, 1)
                self.assertEqual(repo.calls, [])
                self.assertEqual(repo.bodies["12"], "## Description\n\nOriginal body.\n")
                self.assertIn("@-", out)

    def test_empty_and_comment_only_bodies_never_reach_gh(self) -> None:
        for text in ("", "   \n", "<!-- Template: copy to task.yml -->\n"):
            with self.subTest(text=text):
                repo = StoredRepo()
                code, _ = self.run_wrapper(repo, self.write_body(text), "comment", "12")
                self.assertEqual(code, 1)
                self.assertEqual(repo.calls, [])
                self.assertNotIn("\n@-", repo.bodies["12"])

    def test_piped_into_a_file_still_fails_before_writing(self) -> None:
        repo = StoredRepo()
        # The copyable slip: a shell pipeline captured into a body file asks for create.
        code, _ = self.run_wrapper(repo, self.write_body("@-\n"), "create", "--", "--title", "x")
        self.assertEqual(code, 1)
        self.assertEqual(repo.calls, [])

    def test_gnu_style_flag_after_the_number_is_rejected(self) -> None:
        with mock.patch.object(sys, "stderr", io.StringIO()), self.assertRaises(SystemExit):
            gh_issue.parse(["edit", "12", "--body", "@-"])

    def test_edit_writes_and_reads_back(self) -> None:
        repo = StoredRepo()
        code, out = self.run_wrapper(repo, self.write_body(BODY), "edit", "12", "--", "--title", "kept")
        self.assertEqual(code, 0, out)
        self.assertEqual(repo.bodies["12"], BODY)
        self.assertEqual([call[1] for call in repo.calls], ["edit", "view"])
        self.assertIn("--title", repo.calls[0])
        self.assertIn("read back intact", out)

    def test_body_from_stdin(self) -> None:
        repo = StoredRepo()
        code, out = self.run_wrapper(repo, "-", "comment", "12")
        self.assertEqual(code, 0, out)
        self.assertTrue(repo.bodies["12"].endswith(BODY))

    def test_create_follows_the_new_issue_number(self) -> None:
        repo = StoredRepo()
        code, out = self.run_wrapper(repo, self.write_body(BODY), "create", "--", "--title", "x")
        self.assertEqual(code, 0, out)
        created = [n for n in repo.bodies if n != "12"]
        self.assertEqual(repo.bodies[created[0]], BODY)

    def test_readback_without_heading_fails(self) -> None:
        repo = StoredRepo({"12": "## Description\n\nOriginal body.\n"})
        # The write succeeds, but the read-back returns a body with no heading.
        with mock.patch.object(gh_issue, "read_back", return_value="Truncated body with no heading."):
            code, out = self.run_wrapper(repo, self.write_body(BODY), "edit", "12")
        self.assertEqual(code, 1)
        self.assertIn("heading", out)

    def test_missing_number_and_copyable_gnu_form_are_usage_errors(self) -> None:
        for argv in (["edit", "--file", self.write_body(BODY)], ["edit", "12", "--body-file", "b.md"]):
            with self.subTest(argv=argv), mock.patch.object(sys, "stderr", io.StringIO()), self.assertRaises(SystemExit):
                gh_issue.parse(argv)


if __name__ == "__main__":
    unittest.main()
