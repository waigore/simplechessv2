"""Export the Godot Web build to build/web/ (ADR-0007).

Used by the Web playtest workflow and the Pages release workflow so both
presets export the same way. The `Web Release` preset exports the project with
`application/run/main_scene` set to `res://main_release.tscn`, which carries no
playtest seams (ADR-0004 / CTR-playtest-drive.G2); the checkout is restored
afterwards. The release preset is `runnable=false`, so a developer's editor run
still opens the playtest scene.

A Web build resolves the cataloged asset root (`game_assets/`, ADR-0005) as
loose files under `res://`, so `prepare_asset_root` stages that directory into
the preset's output directory and `ensure_staged_assets` fails a release export
whose shipped tree carries no cataloged asset file (#647).
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import struct
from pathlib import Path

PROJECT_MAIN_SCENE = "res://main.tscn"
RELEASE_PRESET = "Web Release"
RELEASE_MAIN_SCENE = "res://main_release.tscn"
PLAYTEST_PRESET = "Web Playtest"
PLAYTEST_MAIN_SCENE = "res://main.tscn"

# The one table of which scene each preset starts at. `game/release_scene_test.gd`
# reads the same file, so the release entry point has a single owner.
SCENE_TABLE = Path(__file__).resolve().parent / "web_export_scenes.json"

# The asset root and the playback-audio copies the resolver reads on Web
# (`game/asset_resolver.gd`: `<asset_root>/…` and `audio_runtime/…`, both under
# `res://` there). Each is staged beside `index.html` or packed into the PCK.
ASSET_ROOT = "game_assets"
AUDIO_RUNTIME = "audio_runtime"
NOT_ASSET_FILES = {".import", ".uid"}
PACK = "index.pck"
MANIFEST = "asset_manifest.json"
# The file kinds the resolver loads (`game/asset_resolver.gd` `_load_media`).
LOADABLE_SUFFIXES = {".svg", ".png", ".woff2", ".ttf", ".otf", ".ogg"}


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
    table = json.loads(SCENE_TABLE.read_text(encoding="utf-8"))
    try:
        return table[preset]
    except KeyError:
        raise ExportError(f"unsupported preset: {preset}") from None


def pages_present_from_status(status: str) -> bool:
    """Whether the Pages probe's HTTP status means a site exists.

    Only `200` (present) and `404` (absent) are answers. Any other status — a
    `403`/`401` from a bad token, a `500`, or curl's `000` for no response — is
    a failed measurement, never a missing site, so the probe step fails.
    """
    code = status.strip()
    if code == "200":
        return True
    if code == "404":
        return False
    raise ExportError(f"Pages probe returned {code or '<empty>'}")


def release_gate(pages_present: bool) -> bool:
    """Whether the `deploy` job runs, derived from this run's probe only."""
    return pages_present is True


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


def _data_files(root: Path) -> list[Path]:
    """`root`'s files minus Godot's import sidecars (`.import`, `.uid`).

    The sidecars sit beside the assets but are engine metadata, never cataloged
    asset content, so they alone must not make a shipped tree look complete.
    """
    if not root.is_dir():
        return []
    return [
        path
        for path in sorted(root.rglob("*"))
        if path.is_file() and path.suffix not in NOT_ASSET_FILES
    ]


def staged_asset_files(shipped: Path) -> list[Path]:
    """The cataloged asset files a shipped Web tree serves loose under `<asset_root>/`."""
    return _data_files(shipped / ASSET_ROOT)


def staged_audio_files(shipped: Path) -> list[Path]:
    """The playable copies a shipped Web tree serves loose under `audio_runtime/`."""
    return [path for path in _data_files(shipped / AUDIO_RUNTIME) if path.suffix == ".ogg"]


def shipped_blob(shipped: Path) -> bytes:
    """Every byte a shipped Web tree carries: loose files plus the pack.

    A Godot export either serves a file loose or writes it into `index.pck`, and
    this check must see both, so it reads the tree as one byte stream rather than
    depending on how the engine lays a pack out.
    """
    if not shipped.is_dir():
        return b""
    return b"\x00".join(
        path.read_bytes() for path in sorted(shipped.rglob("*")) if path.is_file()
    )


def cataloged_paths(repo_root: Path) -> list[str]:
    """The approved asset file paths the shipped build must carry (entry paths).

    Read from the committed manifest, which is generated from the catalog, so the
    check follows the catalog instead of a hand-kept list. Entries whose only
    file is a license text are skipped: the engine's export filters drop `.txt`,
    and nothing on the play path loads one — the resolver loads art, fonts and
    audio only. A mixed entry still requires its loadable files.
    """
    manifest_path = repo_root / "game" / MANIFEST
    if not manifest_path.is_file():
        raise ExportError(f"missing manifest: game/{MANIFEST}")
    document = json.loads(manifest_path.read_text(encoding="utf-8"))
    assets: dict = document.get("assets", {})
    loadable = {
        str(name)
        for entry in assets.values()
        for name in entry.get("files", [])
        if Path(str(name)).suffix in LOADABLE_SUFFIXES
    }
    return sorted(loadable)


def shipped_asset_counts(shipped: Path, repo_root: Path) -> tuple[int, int, int]:
    """How many cataloged asset files and playable audio copies a shipped tree carries."""
    blob = shipped_blob(shipped)
    paths = cataloged_paths(repo_root)
    loose = {_relative(path, shipped / ASSET_ROOT) for path in staged_asset_files(shipped)}
    assets = sum(1 for path in paths if path in loose or f"{ASSET_ROOT}/{path}".encode() in blob)
    loose_audio = len(staged_audio_files(shipped))
    return (assets, len(paths), max(loose_audio, blob.count(f"{AUDIO_RUNTIME}/".encode())))


def _relative(path: Path, root: Path) -> str:
    """`path` relative to `root`, with `/` separators as the manifest writes them."""
    return path.relative_to(root).as_posix()


def ensure_staged_assets(shipped: Path, repo_root: Path) -> None:
    """A shipped Web tree must carry the cataloged asset root (ADR-0005, ADR-0014).

    A tree without these files loads, leaves `EX.loading`, and fails every boot
    asset in the console, so the export fails here instead of publishing.
    """
    assets, expected, audio = shipped_asset_counts(shipped, repo_root)
    if assets == 0:
        raise ExportError(f"the shipped tree carries no {ASSET_ROOT}/ asset file")
    if assets < expected:
        raise ExportError(
            f"the shipped tree carries {assets} of {expected} cataloged {ASSET_ROOT}/ files"
        )
    if audio == 0:
        raise ExportError(f"the shipped tree carries no {AUDIO_RUNTIME}/ copy")


def prepare_asset_root(repo_root: Path, shipped: Path) -> None:
    """Stage the repo-root asset root and audio copies under `game/` for export.

    Godot only exports files inside the project tree (`game/`), so the copies go
    to `game/<root>/` and land in the shipped tree at `<root>/` beside
    `index.html`, which is where the resolver reads them on Web
    (`game/asset_resolver.gd` `res://<root>/…`). Copied, never moved:
    `game_assets/` stays the source of truth at the repo root (ADR-0005).
    """
    for name in (ASSET_ROOT, AUDIO_RUNTIME):
        source = repo_root / name
        if not source.is_dir():
            raise ExportError(f"missing asset directory: {name}/")
        destination = repo_root / "game" / name
        if destination.exists():
            shutil.rmtree(destination)
        shutil.copytree(source, destination)
    shipped.mkdir(parents=True, exist_ok=True)


def discard_asset_root(repo_root: Path) -> None:
    """Remove the staged `game/<root>/` copies the export generated."""
    for name in (ASSET_ROOT, AUDIO_RUNTIME):
        staged = repo_root / "game" / name
        if staged.is_dir():
            shutil.rmtree(staged)


def export(repo_root: Path, preset: str, godot: Path, output: Path) -> None:
    """Write the `preset` Web build to `output`; restore project.godot after."""
    project = repo_root / "game" / "project.godot"
    original = project.read_text(encoding="utf-8")
    try:
        scene = main_scene_for(preset)
        if preset == RELEASE_PRESET:
            ensure_release_settings(preset_settings(repo_root, preset))
        prepare_asset_root(repo_root, output.parent)
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
        discard_asset_root(repo_root)
    for name in ("index.html", "index.wasm", "index.pck"):
        if not (output.parent / name).is_file():
            raise ExportError(f"missing {name} under {output.parent}")
    ensure_staged_assets(output.parent, repo_root)


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
    parser.add_argument("--preset", choices=[PLAYTEST_PRESET, RELEASE_PRESET])
    parser.add_argument(
        "--pages-status",
        metavar="HTTP_STATUS",
        help="map a Pages probe status to present/absent (the release deploy gate)",
    )
    parser.add_argument(
        "--check-assets",
        action="store_true",
        help="fail unless the preset export's shipped tree carries the cataloged asset root",
    )
    parser.add_argument("--repo", default=".")
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"))
    args = parser.parse_args(argv)
    modes = [
        chosen
        for chosen in (args.pages_status is not None, args.check_assets, args.preset is not None)
        if chosen
    ]
    if args.pages_status is not None and args.check_assets:
        parser.error("--pages-status and --check-assets are mutually exclusive")
    if not modes:
        parser.error("one of --preset, --check-assets or --pages-status is required")
    if args.pages_status is not None:
        try:
            present = release_gate(pages_present_from_status(args.pages_status))
        except ExportError as error:
            print(error)
            return 1
        print("true" if present else "false")
        return 0
    if args.check_assets and args.preset is None:
        parser.error("--check-assets needs --preset to find the export's output directory")
    repo_root = Path(args.repo).resolve()
    try:
        output = preset_export_path(repo_root, args.preset)
        output.parent.mkdir(parents=True, exist_ok=True)
        if args.check_assets:
            ensure_staged_assets(output.parent, repo_root)
            assets, expected, audio = shipped_asset_counts(output.parent, repo_root)
            print(
                f"{assets}/{expected} cataloged {ASSET_ROOT}/ file(s), "
                f"{audio} {AUDIO_RUNTIME}/ copy(ies) in {output.parent}"
            )
            return 0
        export(repo_root, args.preset, Path(args.godot), output)
    except ExportError as error:
        print(error)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
