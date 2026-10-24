"""Unit tests for web_export.py (the Web export step both workflows share).

Runs under both `python3 -m unittest discover` (Spec lint) and pytest, so it
imports only the standard library.
"""

from __future__ import annotations

import json
import struct
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


def _fake_godot(tmp_path: Path, *, artifacts: bool, fail: bool = False, assets: bool = False) -> Path:
    """A stand-in `godot` that writes export artifacts from its last argument.

    `assets` also writes a cataloged asset file and a playable audio copy, as a
    real export of a staged root does; without it the shipped tree is asset-less,
    which is the #630 regression `ensure_staged_assets` exists to catch.
    """
    script = tmp_path / "fake_godot.py"
    lines = ["import pathlib, sys"]
    if fail:
        lines.append("sys.exit(1)")
    lines.append("out = pathlib.Path(sys.argv[-1])")
    lines.append("out.parent.mkdir(parents=True, exist_ok=True)")
    if artifacts:
        lines.append("for name in ('index.html', 'index.wasm', 'index.pck'):")
        lines.append("    (out.parent / name).write_text('x')")
    if artifacts and assets:
        lines.append("(out.parent / 'game_assets' / 'icons').mkdir(parents=True, exist_ok=True)")
        lines.append("(out.parent / 'game_assets' / 'icons' / 'quit.svg').write_text('<svg/>')")
        lines.append("(out.parent / 'audio_runtime').mkdir(parents=True, exist_ok=True)")
        lines.append("(out.parent / 'audio_runtime' / 'theme.ogg').write_text('OggS')")
    script.write_text("\n".join(lines), encoding="utf-8")
    runner = tmp_path / "godot"
    runner.write_text(f'#!/bin/sh\nexec {sys.executable} "{script}" "$@"\n', encoding="utf-8")
    runner.chmod(0o755)
    return runner


def _fake_pack(pack: Path, paths: list[str]) -> None:
    """A stand-in Godot 4 PCK whose file table carries `paths`.

    The header is `GDPC`, four version words and a format word (24 bytes), then
    per entry a length-prefixed path, an 8-byte offset and an 8-byte size. This
    matches `web_export.packed_paths`, which reads the real layout the engine
    writes; the real export is exercised by the `Web release` workflow run.
    """
    table = bytearray(b"GDPC" + struct.pack("<IIIII", 4, 4, 7, 2, 2))
    for index, path in enumerate(paths):
        raw = path.encode("utf-8")
        table += struct.pack("<I", len(raw)) + raw + struct.pack("<QQ", index, 1)
    pack.parent.mkdir(parents=True, exist_ok=True)
    pack.write_bytes(bytes(table))


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
        for name in (web_export.ASSET_ROOT, web_export.AUDIO_RUNTIME):
            (self.tmp_path / name).mkdir(exist_ok=True)
        self.repo = self.tmp_path
        self._write_manifest(["icons/quit.svg"])
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
        godot = _fake_godot(self.tmp_path, artifacts=True, assets=True)
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
        godot = _fake_godot(self.tmp_path, artifacts=True, assets=True)
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

    def _write_manifest(self, files: list[str]) -> None:
        """A committed `game/asset_manifest.json` whose one entry lists `files`."""
        entry = {"state": "approved", "kind": "icons", "files": files}
        (self.repo / "game" / "asset_manifest.json").write_text(
            json.dumps({"asset_root": web_export.ASSET_ROOT, "assets": {"a": entry}, "groups": {}}),
            encoding="utf-8",
        )

    def _stage_assets(self, shipped: Path, *, assets: bool = True, audio: bool = True) -> None:
        (shipped / web_export.ASSET_ROOT / "icons").mkdir(parents=True, exist_ok=True)
        (shipped / web_export.AUDIO_RUNTIME).mkdir(parents=True, exist_ok=True)
        if assets:
            (shipped / web_export.ASSET_ROOT / "icons" / "quit.svg").write_text("<svg/>", encoding="utf-8")
            (shipped / web_export.ASSET_ROOT / "icons" / "quit.svg.import").write_text("[remap]", encoding="utf-8")
        if audio:
            (shipped / web_export.AUDIO_RUNTIME / "theme.ogg").write_bytes(b"OggS")

    def test_check_passes_when_the_shipped_tree_carries_the_cataloged_files(self) -> None:
        self._write_manifest(["icons/quit.svg", "fonts/a.woff2", "fonts/OFL.txt"])
        shipped = self.tmp_path / "build" / "web"
        shipped.mkdir(parents=True)
        (shipped / web_export.PACK).write_bytes(b"GDPC" + b"res://game_assets/icons/quit.svg")
        (shipped / web_export.PACK).write_bytes(
            (shipped / web_export.PACK).read_bytes() + b"res://game_assets/fonts/a.woff2"
        )
        (shipped / web_export.AUDIO_RUNTIME).mkdir()
        (shipped / web_export.AUDIO_RUNTIME / "theme.ogg").write_bytes(b"OggS")
        web_export.ensure_staged_assets(shipped, self.repo)
        assert web_export.shipped_asset_counts(shipped, self.repo) == (2, 2, 1)

    def test_license_text_is_not_required_in_the_shipped_tree(self) -> None:
        self._write_manifest(["icons/quit.svg", "fonts/OFL.txt"])
        assert web_export.cataloged_paths(self.repo) == ["icons/quit.svg"]

    def test_check_fails_when_only_some_cataloged_files_are_shipped(self) -> None:
        self._write_manifest(["icons/quit.svg", "icons/back.svg"])
        shipped = self.tmp_path / "build" / "web"
        (shipped / web_export.ASSET_ROOT / "icons").mkdir(parents=True)
        (shipped / web_export.ASSET_ROOT / "icons" / "quit.svg").write_text("<svg/>", encoding="utf-8")
        (shipped / web_export.AUDIO_RUNTIME).mkdir(parents=True, exist_ok=True)
        (shipped / web_export.AUDIO_RUNTIME / "theme.ogg").write_bytes(b"OggS")
        with self.assertRaises(web_export.ExportError):
            web_export.ensure_staged_assets(shipped, self.repo)

    def test_check_fails_when_the_audio_copies_are_missing(self) -> None:
        self._write_manifest(["icons/quit.svg"])
        shipped = self.tmp_path / "build" / "web"
        (shipped / web_export.ASSET_ROOT / "icons").mkdir(parents=True)
        (shipped / web_export.ASSET_ROOT / "icons" / "quit.svg").write_text("<svg/>", encoding="utf-8")
        with self.assertRaises(web_export.ExportError):
            web_export.ensure_staged_assets(shipped, self.repo)

    def test_check_fails_when_no_cataloged_asset_file_is_shipped(self) -> None:
        self._write_manifest(["icons/quit.svg"])
        shipped = self.tmp_path / "build" / "web"
        self._stage_assets(shipped, assets=False)
        with self.assertRaises(web_export.ExportError):
            web_export.ensure_staged_assets(shipped, self.repo)

    def test_missing_manifest_is_an_export_error(self) -> None:
        (self.repo / "game" / "asset_manifest.json").unlink()
        with self.assertRaises(web_export.ExportError):
            web_export.cataloged_paths(self.repo)

    def test_staged_files_are_listed_for_the_workflow(self) -> None:
        shipped = self.tmp_path / "build" / "web"
        self._stage_assets(shipped)
        assert [path.name for path in web_export.staged_asset_files(shipped)] == ["quit.svg"]
        assert [path.name for path in web_export.staged_audio_files(shipped)] == ["theme.ogg"]

    def test_check_assets_cli_is_red_then_green(self) -> None:
        self._write_manifest(["icons/quit.svg"])
        shipped = self.tmp_path / "build" / "web"
        self._stage_assets(shipped, assets=False)
        check = ["--check-assets", "--repo", str(self.repo), "--preset", web_export.RELEASE_PRESET]
        assert web_export.main(check) == 1
        self._stage_assets(shipped)
        assert web_export.main(check) == 0

    def _write_boot_manifest(self, files: list[str]) -> None:
        """A committed manifest with one approved `boot` entry listing `files`."""
        entry = {"state": "approved", "kind": "icons", "files": files}
        (self.repo / "game" / "asset_manifest.json").write_text(
            json.dumps(
                {
                    "asset_root": web_export.ASSET_ROOT,
                    "assets": {"a": entry},
                    "groups": {"boot": ["a"]},
                }
            ),
            encoding="utf-8",
        )

    def test_boot_check_passes_when_the_tree_serves_every_boot_asset(self) -> None:
        self._write_boot_manifest(["icons/quit.svg"])
        shipped = self.tmp_path / "build" / "web"
        self._stage_assets(shipped)
        web_export.ensure_boot_assets_resolve(shipped, self.repo)
        assert web_export.missing_boot_files(shipped, self.repo) == []

    def test_boot_check_fails_naming_the_absent_ids_and_the_missing_root(self) -> None:
        self._write_boot_manifest(["icons/quit.svg"])
        shipped = self.tmp_path / "build" / "web"
        self._stage_assets(shipped, assets=False, audio=False)
        with self.assertRaises(web_export.ExportError) as raised:
            web_export.ensure_boot_assets_resolve(shipped, self.repo)
        assert "0 of 1 boot asset file(s) resolved" in str(raised.exception)
        assert f"{web_export.ASSET_ROOT}/ absent" in str(raised.exception)
        assert "a (icons/quit.svg)" in str(raised.exception)

    def test_boot_check_fails_when_the_assets_are_packed_but_no_route_serves_them(self) -> None:
        """#715's failure mode: the pack carries sidecars, the source route resolves nothing."""
        self._write_boot_manifest(["icons/quit.svg"])
        shipped = self.tmp_path / "build" / "web"
        self._stage_assets(shipped, assets=False, audio=False)
        _fake_pack(shipped / web_export.PACK, [f"res://{web_export.ASSET_ROOT}/icons/quit.svg.import"])
        assert web_export.asset_root_present(shipped, self.repo)
        with self.assertRaises(web_export.ExportError) as raised:
            web_export.ensure_boot_assets_resolve(shipped, self.repo)
        assert "0 of 1 boot asset file(s) resolved — no route serves" in str(raised.exception)
        assert "a (icons/quit.svg)" in str(raised.exception)

    def test_boot_check_passes_when_the_pack_carries_the_boot_route_loose_absent(self) -> None:
        self._write_boot_manifest(["icons/quit.svg"])
        shipped = self.tmp_path / "build" / "web"
        self._stage_assets(shipped, assets=False, audio=False)
        _fake_pack(shipped / web_export.PACK, [f"res://{web_export.ASSET_ROOT}/icons/quit.svg"])
        assert web_export.missing_boot_files(shipped, self.repo) == []

    def test_boot_check_reports_the_partial_count(self) -> None:
        self._write_boot_manifest(["icons/quit.svg", "icons/back.svg"])
        shipped = self.tmp_path / "build" / "web"
        self._stage_assets(shipped, assets=False)
        (shipped / web_export.ASSET_ROOT / "icons" / "back.svg").write_text("<svg/>", encoding="utf-8")
        with self.assertRaises(web_export.ExportError) as raised:
            web_export.ensure_boot_assets_resolve(shipped, self.repo)
        assert "1 of 2 boot asset file(s) resolved — no route serves" in str(raised.exception)

    def test_boot_check_cli_is_red_then_green(self) -> None:
        self._write_boot_manifest(["icons/quit.svg"])
        shipped = self.tmp_path / "build" / "web"
        self._stage_assets(shipped, assets=False, audio=False)
        check = ["--check-boot", "--repo", str(self.repo), "--preset", web_export.RELEASE_PRESET]
        assert web_export.main(check) == 1
        self._stage_assets(shipped)
        assert web_export.main(check) == 0

    def test_export_stages_the_repo_asset_root_and_discards_it_after(self) -> None:
        repo = self._write_repo()
        for name in (web_export.ASSET_ROOT, web_export.AUDIO_RUNTIME):
            (repo / name / "sample").mkdir(parents=True)
            (repo / name / "sample" / "file.txt").write_text("x", encoding="utf-8")
        shipped = repo / "build" / "web"
        script = self.tmp_path / "staging_godot.py"
        script.write_text(
            "\n".join(
                [
                    "import pathlib, sys",
                    f"game = pathlib.Path({str(repo / 'game')!r})",
                    "assert (game / 'game_assets' / 'sample' / 'file.txt').is_file()",
                    f"out = pathlib.Path({str(shipped)!r})",
                    "out.mkdir(parents=True, exist_ok=True)",
                    "for name in ('index.html', 'index.wasm', 'index.pck'):",
                    "    (out / name).write_text('x')",
                    "(out / 'game_assets' / 'icons').mkdir(parents=True, exist_ok=True)",
                    "(out / 'game_assets' / 'icons' / 'quit.svg').write_text('<svg/>')",
                    "(out / 'audio_runtime').mkdir(parents=True, exist_ok=True)",
                    "(out / 'audio_runtime' / 'theme.ogg').write_text('OggS')",
                ]
            ),
            encoding="utf-8",
        )
        godot = self.tmp_path / "godot"
        godot.write_text(f'#!/bin/sh\nexec {sys.executable} "{script}" "$@"\n', encoding="utf-8")
        godot.chmod(0o755)
        web_export.export(repo, web_export.RELEASE_PRESET, godot, shipped / "index.html")
        assert not (repo / "game" / web_export.ASSET_ROOT).exists()
        assert not (repo / "game" / web_export.AUDIO_RUNTIME).exists()
        # Staged copies are served loose beside index.html, so the shipped tree
        # keeps the sample the resolver would read at `res://game_assets/…`.
        served = sorted(path.name for path in (shipped / web_export.ASSET_ROOT / "sample").iterdir())
        assert served == ["file.txt"]
        assert (shipped / web_export.AUDIO_RUNTIME / "sample" / "file.txt").is_file()

    def test_export_fails_when_the_shipped_tree_has_no_asset_file(self) -> None:
        repo = self._write_repo()
        godot = _fake_godot(self.tmp_path, artifacts=True)
        self._export_fails(repo, godot, web_export.PLAYTEST_PRESET)
