"""Unit tests for web_export.py (the Web export step both workflows share).

Runs under both `python3 -m unittest discover` (Spec lint) and pytest, so it
imports only the standard library.
"""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import web_export  # noqa: E402

PROJECT = """config_version=5

[application]

config/name="Simple Chess"
run/main_scene="res://main.tscn"
config/features=PackedStringArray("4.7", "GL Compatibility")
"""


PRESETS = '''[preset.0]

name="Web Playtest"
runnable=true
custom_features="playtest"
export_path="../build/web/index.html"

[preset.0.options]

variant/thread_support=false

[preset.1]

name="Web Release"
runnable=false
custom_features="release"
export_path="../build/web/index.html"

[preset.1.options]

variant/thread_support=false
'''


def _fake_godot(tmp_path: Path, *, artifacts: bool, fail: bool = False) -> Path:
    """A stand-in `godot` that writes export artifacts from its last argument."""
    script = tmp_path / "fake_godot.py"
    lines = ["import pathlib, sys"]
    if fail:
        lines.append("sys.exit(1)")
    lines.append("out = pathlib.Path(sys.argv[-1])")
    lines.append("out.parent.mkdir(parents=True, exist_ok=True)")
    if artifacts:
        lines.append("for name in ('index.html', 'index.wasm', 'index.pck'):")
        lines.append("    (out.parent / name).write_text('x')")
    script.write_text("\n".join(lines), encoding="utf-8")
    runner = tmp_path / "godot"
    runner.write_text(f'#!/bin/sh\nexec {sys.executable} "{script}" "$@"\n', encoding="utf-8")
    runner.chmod(0o755)
    return runner


class WebExportTest(unittest.TestCase):
    """Each test gets a throwaway repo with project.godot and export_presets.cfg."""

    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.tmp_path = Path(self._tmp.name)
        self._write_repo()

    def _write_repo(self, presets: str = PRESETS) -> Path:
        game = self.tmp_path / "game"
        game.mkdir(exist_ok=True)
        (game / "project.godot").write_text(PROJECT, encoding="utf-8")
        (game / "export_presets.cfg").write_text(presets, encoding="utf-8")
        self.repo = self.tmp_path
        return self.repo

    def _export_fails(self, repo: Path, godot: Path, preset: str) -> None:
        with self.assertRaises(web_export.ExportError):
            web_export.export(repo, preset, godot, repo / "build/web/index.html")

    def test_preset_export_path_is_read_per_preset(self) -> None:
        assert web_export.preset_export_path(self.repo, web_export.RELEASE_PRESET) == (self.repo / "build/web/index.html").resolve()

    def test_release_preset_must_carry_the_release_feature(self) -> None:
        repo = self._write_repo(PRESETS.replace('custom_features="release"', 'custom_features=""'))
        godot = _fake_godot(self.tmp_path, artifacts=True)
        self._export_fails(repo, godot, web_export.RELEASE_PRESET)

    def test_release_preset_must_not_embed_the_pack(self) -> None:
        for key in ("binary_format/embed_pck", "html/export_main_pack"):
            with self.subTest(key=key):
                repo = self._write_repo(PRESETS.replace("[preset.1.options]\n", f"[preset.1.options]\n{key}=true\n"))
                godot = _fake_godot(self.tmp_path, artifacts=True)
                self._export_fails(repo, godot, web_export.RELEASE_PRESET)

    def test_playtest_preset_skips_the_release_settings(self) -> None:
        repo = self._write_repo(PRESETS.replace('custom_features="release"', 'custom_features=""'))
        godot = _fake_godot(self.tmp_path, artifacts=True)
        web_export.export(repo, web_export.PLAYTEST_PRESET, godot, repo / "build/web/index.html")

    def test_set_main_scene_replaces_only_the_scene_line(self) -> None:
        text = web_export.set_main_scene(PROJECT, web_export.RELEASE_MAIN_SCENE)
        assert 'run/main_scene="res://main_release.tscn"' in text
        assert text.replace('"res://main_release.tscn"', '"res://main.tscn"') == PROJECT

    def test_set_main_scene_requires_the_key(self) -> None:
        with self.assertRaises(web_export.ExportError):
            web_export.set_main_scene("[application]\n", web_export.RELEASE_MAIN_SCENE)

    def test_main_scene_for_preset(self) -> None:
        cases = [
            (web_export.RELEASE_PRESET, web_export.RELEASE_MAIN_SCENE),
            (web_export.PLAYTEST_PRESET, web_export.PLAYTEST_MAIN_SCENE),
        ]
        for preset, scene in cases:
            with self.subTest(preset=preset):
                assert web_export.main_scene_for(preset) == scene

    def test_unknown_preset_is_rejected(self) -> None:
        with self.assertRaises(web_export.ExportError):
            web_export.main_scene_for("Web Debug")

    def test_pages_present_only_from_the_two_answers(self) -> None:
        assert web_export.pages_present_from_status("200") is True
        assert web_export.pages_present_from_status("404") is False
        assert web_export.pages_present_from_status(" 200\n") is True

    def test_probe_failure_is_never_read_as_absent(self) -> None:
        for status in ("403", "401", "500", "000", "", "  "):
            with self.subTest(status=status):
                with self.assertRaises(web_export.ExportError):
                    web_export.pages_present_from_status(status)

    def test_release_gate_derives_from_the_probe(self) -> None:
        assert web_export.release_gate(web_export.pages_present_from_status("200")) is True
        assert web_export.release_gate(web_export.pages_present_from_status("404")) is False
        assert web_export.release_gate(False) is False

    def test_pages_status_cli_prints_the_gate(self) -> None:
        assert web_export.main(["--pages-status", "200"]) == 0
        assert web_export.main(["--pages-status", "404"]) == 0
        assert web_export.main(["--pages-status", "500"]) == 1

    def test_export_switches_the_release_scene_and_restores_it(self) -> None:
        repo = self._write_repo()
        godot = _fake_godot(self.tmp_path, artifacts=True)
        seen: dict[str, str] = {}

        original_run = web_export.subprocess.run

        def spy(run, check=False):
            seen["scene"] = (repo / "game" / "project.godot").read_text(encoding="utf-8")
            return original_run(run, check=check)

        web_export.subprocess.run = spy
        try:
            web_export.export(repo, web_export.RELEASE_PRESET, godot, repo / "build" / "web" / "index.html")
        finally:
            web_export.subprocess.run = original_run
        assert web_export.RELEASE_MAIN_SCENE in seen["scene"]
        assert (repo / "game" / "project.godot").read_text(encoding="utf-8") == PROJECT

    def test_export_restores_the_scene_when_the_export_fails(self) -> None:
        repo = self._write_repo()
        godot = _fake_godot(self.tmp_path, artifacts=False, fail=True)
        self._export_fails(repo, godot, web_export.RELEASE_PRESET)
        assert (repo / "game" / "project.godot").read_text(encoding="utf-8") == PROJECT

    def test_export_requires_the_pack_outputs(self) -> None:
        repo = self._write_repo()
        godot = _fake_godot(self.tmp_path, artifacts=False)
        self._export_fails(repo, godot, web_export.PLAYTEST_PRESET)
