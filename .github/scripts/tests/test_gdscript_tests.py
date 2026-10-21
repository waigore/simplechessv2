"""Tests for the GDScript unit-test and coverage gate.

Skip-path tests must not invoke Godot. Parser tests run when gdtoolkit is installed.
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import gdscript_tests as gate  # noqa: E402

try:
    import gdtoolkit  # noqa: F401

    HAS_GDTOOLKIT = True
except ImportError:
    HAS_GDTOOLKIT = False


def _completed(cmd: list[str], code: int, out: str = "", err: str = "") -> subprocess.CompletedProcess[str]:
    return subprocess.CompletedProcess(cmd, code, out, err)


class SkipPathTest(unittest.TestCase):
    def test_no_scripts_does_not_invoke_godot(self) -> None:
        def boom(cmd: list[str], env: dict[str, str]) -> subprocess.CompletedProcess[str]:
            raise AssertionError(cmd)

        with tempfile.TemporaryDirectory() as tmp:
            game = Path(tmp)
            for command in ("test", "coverage"):
                self.assertEqual(
                    gate.run_command(command, game, godot_bin=Path("/no/godot"), runner=boom),
                    0,
                )

    def test_missing_project_fails_without_godot(self) -> None:
        def boom(cmd: list[str], env: dict[str, str]) -> subprocess.CompletedProcess[str]:
            raise AssertionError(cmd)

        with tempfile.TemporaryDirectory() as tmp:
            game = Path(tmp)
            (game / "add_test.gd").write_text("extends SceneTree\n", encoding="utf-8")
            self.assertEqual(
                gate.run_command("test", game, godot_bin=Path("/no/godot"), runner=boom),
                1,
            )


class SuiteTest(unittest.TestCase):
    def _game(self, root: Path) -> Path:
        game = root / "game"
        game.mkdir()
        (game / "project.godot").write_text("config_version=5\n", encoding="utf-8")
        (game / "add_test.gd").write_text("extends SceneTree\n", encoding="utf-8")
        return game

    def test_runs_each_script_headless(self) -> None:
        calls: list[list[str]] = []

        def runner(cmd: list[str], env: dict[str, str]) -> subprocess.CompletedProcess[str]:
            calls.append(cmd)
            return _completed(cmd, 0)

        with tempfile.TemporaryDirectory() as tmp:
            game = self._game(Path(tmp))
            code = gate.run_command(
                "test",
                game,
                godot_bin=Path("/opt/godot"),
                runner=runner,
                check_version=False,
            )
        self.assertEqual(code, 0)
        self.assertEqual(calls[0][1:4], ["--headless", "--path", str(game)])
        self.assertEqual(calls[0][5], "res://add_test.gd")

    def test_failing_test_and_script_error_fail(self) -> None:
        def fail(cmd: list[str], env: dict[str, str]) -> subprocess.CompletedProcess[str]:
            return _completed(cmd, 1, err="nope")

        def script_error(cmd: list[str], env: dict[str, str]) -> subprocess.CompletedProcess[str]:
            return _completed(cmd, 0, err="SCRIPT ERROR: boom")

        with tempfile.TemporaryDirectory() as tmp:
            game = self._game(Path(tmp))
            self.assertEqual(
                gate.run_command("test", game, godot_bin=Path("/opt/godot"), runner=fail, check_version=False),
                1,
            )
            self.assertEqual(
                gate.run_command(
                    "test",
                    game,
                    godot_bin=Path("/opt/godot"),
                    runner=script_error,
                    check_version=False,
                ),
                1,
            )

    def test_coverage_passes_when_there_are_no_main_lines(self) -> None:
        def runner(cmd: list[str], env: dict[str, str]) -> subprocess.CompletedProcess[str]:
            return _completed(cmd, 0)

        with tempfile.TemporaryDirectory() as tmp:
            game = self._game(Path(tmp))
            code = gate.run_command(
                "coverage",
                game,
                godot_bin=Path("/opt/godot"),
                runner=runner,
                check_version=False,
            )
        self.assertEqual(code, 0)


class PercentTest(unittest.TestCase):
    def test_empty_is_full_and_threshold_is_inclusive(self) -> None:
        self.assertEqual(gate.coverage_percent(set(), set()), 100.0)
        coverable = {("a.gd", n) for n in range(1, 6)}
        hits = {("a.gd", n) for n in range(1, 5)}
        self.assertEqual(gate.coverage_percent(coverable, hits), 80.0)
        self.assertLess(gate.coverage_percent(coverable, {("a.gd", 1)}), 80.0)


@unittest.skipUnless(HAS_GDTOOLKIT, "gdtoolkit not installed")
class InstrumentTest(unittest.TestCase):
    SAMPLE = "extends RefCounted\n\nfunc add(a: int, b: int) -> int:\n\tif a > 0:\n\t\treturn a + b\n\treturn b\n"

    def test_statement_lines_and_probe(self) -> None:
        lines = gate.statement_lines(self.SAMPLE)
        self.assertEqual(lines, {4, 5, 6})
        text = gate.instrument(self.SAMPLE, "add.gd", lines)
        self.assertIn('_CiLineCov.hit("add.gd", 4)', text)
        self.assertIn('preload("res://_ci_line_cov.gd")', text)
        self.assertLess(text.index('hit("add.gd", 4)'), text.index("if a > 0:"))

    def test_low_coverage_fails(self) -> None:
        def runner(cmd: list[str], env: dict[str, str]) -> subprocess.CompletedProcess[str]:
            return _completed(cmd, 0)

        with tempfile.TemporaryDirectory() as tmp:
            game = Path(tmp)
            (game / "project.godot").write_text("config_version=5\n", encoding="utf-8")
            (game / "add.gd").write_text(self.SAMPLE, encoding="utf-8")
            (game / "add_test.gd").write_text("extends SceneTree\n", encoding="utf-8")
            code = gate.run_command(
                "coverage",
                game,
                godot_bin=Path("/opt/godot"),
                runner=runner,
                check_version=False,
            )
        self.assertEqual(code, 1)
