"""Export the Godot Web build to build/web/ (ADR-0007).

Used by the Web playtest workflow and the Pages release workflow so both
presets export the same way. The `Web Release` preset exports the project with
`application/run/main_scene` set to `res://main_release.tscn`, which carries no
playtest seams (ADR-0004 / CTR-playtest-drive.G2); the checkout is restored
afterwards. The release preset is `runnable=false`, so a developer's editor run
still opens the playtest scene.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
from pathlib import Path

PROJECT_MAIN_SCENE = "res://main.tscn"
RELEASE_PRESET = "Web Release"
RELEASE_MAIN_SCENE = "res://main_release.tscn"
PLAYTEST_PRESET = "Web Playtest"
PLAYTEST_MAIN_SCENE = "res://main.tscn"


class ExportError(RuntimeError):
    """A Web export could not be prepared or run."""


def set_main_scene(text: str, scene: str) -> str:
    """Return `project.godot` text with `run/main_scene` set to `scene`."""
    lines = text.splitlines(keepends=True)
    for index, line in enumerate(lines):
        if line.startswith("run/main_scene="):
            lines[index] = f'run/main_scene="{scene}"\n'
            return "".join(lines)
    raise ExportError("game/project.godot has no run/main_scene line")


def main_scene_for(preset: str) -> str:
    """The `run/main_scene` a preset exports with."""
    if preset == RELEASE_PRESET:
        return RELEASE_MAIN_SCENE
    if preset == PLAYTEST_PRESET:
        return PLAYTEST_MAIN_SCENE
    raise ExportError(f"unsupported preset: {preset}")


def ensure_release_settings(text: str) -> None:
    """A release build must carry the `release` feature explicit and unembedded.

    The feature gates the playtest seams in exported code (G2), so an export with
    `custom_features` cleared or an embedded PCK would ship seams in the HTML.
    """
    lines = [line.strip() for line in text.splitlines()]
    if 'custom_features="release"' not in lines:
        raise ExportError("the Web Release preset must set custom_features=release")
    for line in lines:
        if line.startswith(("binary_format/embed_pck=", "html/export_main_pack=")):
            key, _, value = line.partition("=")
            if value.strip() != "false":
                raise ExportError(f"the Web Release preset must not embed the PCK: {key}")


def export(repo_root: Path, preset: str, godot: Path, output: Path) -> None:
    """Write the `preset` Web build to `output`; restore project.godot after."""
    project = repo_root / "game" / "project.godot"
    original = project.read_text(encoding="utf-8")
    try:
        scene = main_scene_for(preset)
        if preset == RELEASE_PRESET:
            ensure_release_settings(preset_settings(repo_root, preset))
        if scene != PROJECT_MAIN_SCENE:
            project.write_text(set_main_scene(original, scene), encoding="utf-8")
        run = [
            str(godot),
            "--headless",
            "--path",
            str(repo_root / "game"),
            "--export-release",
            preset,
            str(output),
        ]
        if subprocess.run(run, check=False).returncode != 0:
            raise ExportError(f"{preset} export failed")
    finally:
        project.write_text(original, encoding="utf-8")
    for name in ("index.html", "index.wasm", "index.pck"):
        if not (output.parent / name).is_file():
            raise ExportError(f"missing {name} under {output.parent}")


def preset_settings(repo_root: Path, preset: str) -> str:
    """The `game/export_presets.cfg` sections of `preset`."""
    text = (repo_root / "game" / "export_presets.cfg").read_text(encoding="utf-8")
    for section in re.split(r"^\[preset\.\d+\]$", text, flags=re.MULTILINE):
        if re.search(rf'^name="{re.escape(preset)}"$', section, re.MULTILINE):
            return section
    raise ExportError(f"preset {preset} not found in export_presets.cfg")


def preset_export_path(repo_root: Path, preset: str) -> Path:
    """The preset's `export_path` (relative to game/, ADR-0007), made absolute."""
    found = re.search(r'^export_path="([^"]+)"$', preset_settings(repo_root, preset), re.MULTILINE)
    if found is None:
        raise ExportError(f"preset {preset} has no export_path")
    return (repo_root / "game" / found.group(1)).resolve()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--preset", required=True, choices=[PLAYTEST_PRESET, RELEASE_PRESET])
    parser.add_argument("--repo", default=".")
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"))
    args = parser.parse_args(argv)
    repo_root = Path(args.repo).resolve()
    try:
        output = preset_export_path(repo_root, args.preset)
        output.parent.mkdir(parents=True, exist_ok=True)
        export(repo_root, args.preset, Path(args.godot), output)
    except ExportError as error:
        print(error)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
