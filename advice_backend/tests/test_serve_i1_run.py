"""Tests for the operator transcript script behind the served-snapshot I1 run (#671)."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from advice_backend import serve_i1_run

EXPORT = (
    "PuzzleId,FEN,Moves,Rating,RatingDeviation,Popularity,NbPlays,Themes,GameUrl,OpeningTags\n"
    "s1,6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1,a1a8 g8h8,1480,80,90,1000,mateIn1,,,\n"
    "s2,6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1,a1a8 g8h8,1560,80,90,1000,fork,,,\n"
)


def _write_export(folder: Path) -> Path:
    export = folder / "export.csv"
    export.write_text(EXPORT, encoding="utf-8")
    return export


class IdentifyTests(unittest.TestCase):
    def test_identity_describes_the_file_on_disk(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            served = Path(folder) / "snap.json"
            served.write_text(json.dumps([{"PuzzleId": "s1"}]), encoding="utf-8")

            identity = serve_i1_run.identify(served)

            self.assertEqual(identity["path"], str(served.resolve()))
            self.assertEqual(identity["bytes"], served.stat().st_size)
            self.assertEqual(len(identity["sha256"]), 64)


class GuardTests(unittest.TestCase):
    def test_existing_served_snapshot_is_never_rebuilt_in_place(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            served = Path(folder) / "snap.json"
            served.write_text("[]", encoding="utf-8")

            with self.assertRaises(SystemExit) as raised:
                serve_i1_run.demand_fresh(served)

            self.assertIn("never", str(raised.exception.code))
            self.assertEqual(served.read_text(encoding="utf-8"), "[]")

    def test_absent_path_is_accepted(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            serve_i1_run.demand_fresh(Path(folder) / "snap.json")

    def test_a_missing_export_stops_before_any_state_changes(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "absent.csv"

            with self.assertRaises(SystemExit) as raised:
                serve_i1_run.require_export(path)

            self.assertIn("export not found", str(raised.exception.code))


class RowsTests(unittest.TestCase):
    def test_transcript_carries_the_evidence_the_issue_names(self) -> None:
        rows = serve_i1_run.rows(
            "abc123", "clean", Path("export.csv"), Path("served/snap.json"),
            ["snapshot served/snap.json: 2 records"], 0, [],
            {"path": "/served/snap.json", "bytes": 7, "mtime": "t", "sha256": "f" * 64},
            "1.0 s", "0.5 s",
        )
        fields = dict(rows)

        self.assertEqual(fields["Check exit"], "0")
        self.assertIn("2 records", fields["Build stdout"])
        self.assertEqual(fields["Served bytes"], "7")
        self.assertIn("no `--expected-count`", fields["Check"])
        self.assertIn("pending", fields["Deal `snapshot_id`"])

    def test_a_refused_rebuild_writes_no_transcript(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            export = _write_export(Path(folder))
            transcript = Path(folder) / "served.json"
            transcript.write_text("[]", encoding="utf-8")

            with self.assertRaises(SystemExit) as raised:
                serve_i1_run.main([str(export), str(transcript)])

            self.assertIn("refusing to rebuild", str(raised.exception.code))
            self.assertEqual(transcript.read_text(encoding="utf-8"), "[]")


class ModuleTests(unittest.TestCase):
    def test_module_runs_as_a_script(self) -> None:
        result = subprocess.run(
            [sys.executable, "-m", "advice_backend.serve_i1_run", "--help"],
            capture_output=True, text=True, check=False,
        )

        self.assertEqual(result.returncode, 0)
        self.assertIn("catalog route serves", result.stdout)


class RepoTests(unittest.TestCase):
    def test_a_tree_without_git_is_named_not_hashed(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            commit, clean = serve_i1_run.repo_state(Path(folder))

            self.assertEqual(commit, "unknown")
            self.assertIn("not a git checkout", clean)


@unittest.skipUnless(
    (Path(__file__).resolve().parents[2] / ".git").exists(),
    "needs a git checkout",
)
class RunTests(unittest.TestCase):
    def test_a_slice_is_built_then_refused_by_the_served_count_gate(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            export = _write_export(root)
            served = root / "snap.json"
            transcript = root / "run.md"

            with mock.patch.object(serve_i1_run, "repo_state", return_value=("abc123", "clean")):
                code = serve_i1_run.main(
                    [str(export), str(served), "--transcript", str(transcript), "--expected", "2"]
                )

            self.assertEqual(code, 1)
            self.assertEqual(len(json.loads(served.read_text(encoding="utf-8"))), 2)
            text = transcript.read_text(encoding="utf-8")
            self.assertIn("snap.json: 2 records", text)
            self.assertIn("| Check exit | 1 |", text)
            self.assertIn("I1: expected 6157341 records, found 2", text)
            self.assertIn("Served SHA-256", text)

    def test_the_served_count_gate_rejects_a_slice(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            export = _write_export(root)
            served = root / "snap.json"
            transcript = root / "run.md"

            with mock.patch.object(serve_i1_run, "repo_state", return_value=("abc123", "clean")):
                code = serve_i1_run.main([str(export), str(served), "--transcript", str(transcript)])

            self.assertEqual(code, 1)
            self.assertIn("I1: expected 6157341 records, found 2", transcript.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
