"""Unit tests for web_export.py (the Web export step both workflows share)."""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

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


def _repo(tmp_path: Path, presets: str = PRESETS) -> Path:
    game = tmp_path / "game"
    game.mkdir()
    (game / "project.godot").write_text(PROJECT, encoding="utf-8")
    (game / "export_presets.cfg").write_text(presets, encoding="utf-8")
    return tmp_path


def test_preset_export_path_is_read_per_preset(tmp_path: Path) -> None:
    repo = _repo(tmp_path)
    assert web_export.preset_export_path(repo, web_export.RELEASE_PRESET) == (repo / "build/web/index.html").resolve()


def test_release_preset_must_carry_the_release_feature(tmp_path: Path) -> None:
    repo = _repo(tmp_path, PRESETS.replace('custom_features="release"', 'custom_features=""'))
    godot = _fake_godot(tmp_path, artifacts=True)
    with pytest.raises(web_export.ExportError):
        web_export.export(repo, web_export.RELEASE_PRESET, godot, repo / "build/web/index.html")


@pytest.mark.parametrize("key", ["binary_format/embed_pck", "html/export_main_pack"])
def test_release_preset_must_not_embed_the_pack(tmp_path: Path, key: str) -> None:
    repo = _repo(tmp_path, PRESETS.replace("[preset.1.options]\n", f"[preset.1.options]\n{key}=true\n"))
    godot = _fake_godot(tmp_path, artifacts=True)
    with pytest.raises(web_export.ExportError):
        web_export.export(repo, web_export.RELEASE_PRESET, godot, repo / "build/web/index.html")


def test_playtest_preset_skips_the_release_settings(tmp_path: Path) -> None:
    repo = _repo(tmp_path, PRESETS.replace('custom_features="release"', 'custom_features=""'))
    godot = _fake_godot(tmp_path, artifacts=True)
    web_export.export(repo, web_export.PLAYTEST_PRESET, godot, repo / "build/web/index.html")


def test_set_main_scene_replaces_only_the_scene_line() -> None:
    text = web_export.set_main_scene(PROJECT, web_export.RELEASE_MAIN_SCENE)
    assert 'run/main_scene="res://main_release.tscn"' in text
    assert text.replace('"res://main_release.tscn"', '"res://main.tscn"') == PROJECT


def test_set_main_scene_requires_the_key() -> None:
    with pytest.raises(web_export.ExportError):
        web_export.set_main_scene("[application]\n", web_export.RELEASE_MAIN_SCENE)


@pytest.mark.parametrize(
    ("preset", "scene"),
    [
        (web_export.RELEASE_PRESET, web_export.RELEASE_MAIN_SCENE),
        (web_export.PLAYTEST_PRESET, web_export.PLAYTEST_MAIN_SCENE),
    ],
)
def test_main_scene_for_preset(preset: str, scene: str) -> None:
    assert web_export.main_scene_for(preset) == scene


def test_unknown_preset_is_rejected() -> None:
    with pytest.raises(web_export.ExportError):
        web_export.main_scene_for("Web Debug")


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


def test_export_switches_the_release_scene_and_restores_it(tmp_path: Path) -> None:
    repo = _repo(tmp_path)
    godot = _fake_godot(tmp_path, artifacts=True)
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


def test_export_restores_the_scene_when_the_export_fails(tmp_path: Path) -> None:
    repo = _repo(tmp_path)
    godot = _fake_godot(tmp_path, artifacts=False, fail=True)
    with pytest.raises(web_export.ExportError):
        web_export.export(repo, web_export.RELEASE_PRESET, godot, repo / "build" / "web" / "index.html")
    assert (repo / "game" / "project.godot").read_text(encoding="utf-8") == PROJECT


def test_export_requires_the_pack_outputs(tmp_path: Path) -> None:
    repo = _repo(tmp_path)
    godot = _fake_godot(tmp_path, artifacts=False)
    with pytest.raises(web_export.ExportError):
        web_export.export(repo, web_export.PLAYTEST_PRESET, godot, repo / "build" / "web" / "index.html")
