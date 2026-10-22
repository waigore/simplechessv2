"""Tests for issue_body_guard.py: the literal `@-` writer (issue #470) and the accepted-body check."""
from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from issue_body_guard import findings  # noqa: E402

BODY = "## Description\n\nThe jump input is ignored on touch.\n"


class IssueBodyGuardTest(unittest.TestCase):
    def test_regular_body_passes(self) -> None:
        self.assertEqual(findings(BODY), [])

    def test_empty_body_is_rejected(self) -> None:
        for text in ("", "   \n", "<!-- Template: copy to task.yml -->"):
            with self.subTest(text=text):
                self.assertTrue(findings(text))

    def test_literal_stdin_sentinel_is_rejected(self) -> None:
        for text in ("@-", "@-\n", "  @-  \n"):
            with self.subTest(text=text):
                self.assertIn("@-", findings(text)[0])

    def test_placeholder_is_rejected(self) -> None:
        for text in (BODY + "\n<!-- fill in -->\n", BODY + "\n<!-- Template: copy -->\n"):
            with self.subTest(text=text):
                self.assertTrue(findings(text))

    def test_mention_of_sentinel_in_prose_passes(self) -> None:
        self.assertEqual(findings(BODY + "\nNever pass `@-` to --body.\n"), [])

    def test_readback_requires_a_heading(self) -> None:
        self.assertIn("heading", findings("Truncated body with no heading.", readback=True)[0])
        self.assertIn("@-", findings("@-", readback=True)[0])
        self.assertEqual(findings(BODY, readback=True), [])
        self.assertEqual(findings("Truncated body with no heading."), [])


class CliTest(unittest.TestCase):
    def run_guard(self, text: str | None, *args: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp, "body.md")
            path.write_text(text or "", encoding="utf-8")
            return subprocess.run(
                [sys.executable, str(SCRIPTS / "issue_body_guard.py"), str(path), *args],
                capture_output=True, text=True, check=False,
            )

    def test_exit_codes(self) -> None:
        self.assertEqual(self.run_guard(BODY).returncode, 0)
        self.assertEqual(self.run_guard("@-\n").returncode, 1)
        self.assertEqual(self.run_guard("@-\n", "--readback").returncode, 1)

    def test_stdin(self) -> None:
        completed = subprocess.run(
            [sys.executable, str(SCRIPTS / "issue_body_guard.py"), "-"],
            input="@-\n", capture_output=True, text=True, check=False,
        )
        self.assertEqual(completed.returncode, 1)


if __name__ == "__main__":
    unittest.main()
