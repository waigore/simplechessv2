"""Export the Godot Web build to build/web/ (ADR-0007).

Used by the Web playtest workflow and the Pages release workflow so both
presets export the same way. The `Web Release` preset exports the project with
`application/run/main_scene` set to `res://main_release.tscn`, which carries no
playtest seams (ADR-0004 / CTR-playtest-drive.G2); the checkout is restored
afterwards. The release preset is `runnable=false`, so a developer's editor run
still opens the playtest scene.

A Web build serves the cataloged asset root (`game_assets/`, ADR-0005) and the
playback audio copies as loose files under `res://`, at the routes
`game/asset_resolver.gd` builds on Web. `prepare_asset_root` stages the repo-root
directories under `game/` for the engine and copies them loose into the shipped
tree; `ensure_staged_assets` fails a build that carries no cataloged asset file
(#647) and `ensure_boot_assets_resolve` fails one whose `boot` assets sit at no
route the resolver reads (#630, #715).

`ensure_no_client_engine` is the engine-boundary check of ADR-0002 §Validation
("No client Stockfish endpoint"; CTR-advice-stream G3): the `Web playtest` and
`Web release` jobs run it over a real export, and
`--synthetic-engine-verdicts` proves the same check refuses the contra-positive
trees a job writes itself (#696).
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import struct
import sys
import tempfile
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
# The byte a PCK file table puts after each entry path, so a match is that exact
# route rather than a prefix of a longer one (`.svg` must not match `.svg.import`).
PACK_ENTRY_END = chr(0)
# The file kinds the resolver loads (`game/asset_resolver.gd` `_load_media`).
LOADABLE_SUFFIXES = {".svg", ".png", ".woff2", ".ttf", ".otf", ".ogg"}

# The weight of the text the tree's scene code declares (#696, ADR-0002
# §Validation "No client Stockfish endpoint", CTR-advice-stream G3). Client code
# arrives in the PCK, so those bytes are what the engine-boundary check reads
# there; the loose scene artifacts are read the same way. Each marker is
# anchored so app vocabulary is not read as an engine: the engine's own name
# ("stockfishing"), the move format (`best_move_uci`), a GDScript identifier or
# comment word (`uci`), and the backend's HTTP route (`advice_endpoint`) all
# pass, while a UCI engine peer (`uci://…`, `option name`, `engine_name`) and a
# `.wasm` / `.nnue` sibling are refused.
# Godot's build entry points (`index.*`) are the app itself, never an engine.
ENGINE_BUNDLE_NAMES = re.compile(r"(?<![a-z0-9])(?:stockfish|sf_1[0-9])(?![a-z0-9])", re.IGNORECASE)
ENGINE_ENDPOINT_MARKERS = re.compile(
    r'(?i)(?:uci://|(?<![(\w-])uci:(?![\w-])|"uci:[^"\s]*|option name|engine_name)'
)
ENGINE_BUNDLE_SUFFIXES = {".wasm", ".nnue"}
APP_ENTRY_POINTS = {"index.wasm", "index.pck", "index.html"}
ENGINE_TEXT_ARTIFACTS = ("index.pck", "index.html")
INJECTED_ENGINE_NAME = "stockfish"
INJECTED_ENGINE_ENDPOINT = "uci://stockfish.local:7700"


class ExportError(RuntimeError):
    """A Web export could not be prepared or run."""


class BundleError(ExportError):
    """A shipped Web tree carries a client engine: a name, a file kind, or an endpoint.

    Distinct from `ExportError` so the verdict names what failed: a bundle check
    that reddens because the export did not run is not an engine finding.
    """


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
    depending on how the engine lays a pack out. `shipped` may be the pack itself.
    """
    if shipped.is_file():
        return shipped.read_bytes()
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


def asset_root_present(shipped: Path, repo_root: Path) -> bool:
    """Whether a shipped Web tree carries the cataloged asset root at all (#647's object)."""
    document = _manifest(repo_root)
    cataloged = {
        path for asset_id in document.get("assets", {}) for path in asset_files(document, asset_id)
    }
    blob = shipped_blob(shipped)
    loose = {_relative(path, shipped / ASSET_ROOT) for path in staged_asset_files(shipped)}
    return any(path in loose or f"{ASSET_ROOT}/{path}".encode() in blob for path in cataloged)


def missing_boot_files(shipped: Path, repo_root: Path) -> list[tuple[str, str]]:
    """The `boot` files the shipped tree serves at no route resolution reads (`(ID, file)`).

    Carrying a file is not resolving it (#630, #715): a `boot` file resolves when
    it is served **loose** at `<asset_root>/<file>` beside `index.html`, or when
    that exact route is a packed entry of `index.pck` — the two places the Web
    resolver's `res://<asset_root>/…` read reaches.
    """
    blob = shipped_blob(shipped / PACK)
    loose = {_relative(path, shipped / ASSET_ROOT) for path in staged_asset_files(shipped)}
    unresolved: list[tuple[str, str]] = []
    for asset_id, path in boot_asset_ids(_manifest(repo_root)):
        if path in {seen for _, seen in unresolved}:
            continue
        served = path in loose and (shipped / ASSET_ROOT / path).is_file()
        packed = f"res://{ASSET_ROOT}/{path}{PACK_ENTRY_END}".encode() in blob
        if not served and not packed:
            unresolved.append((asset_id, path))
    return unresolved


def ensure_boot_assets_resolve(shipped: Path, repo_root: Path) -> None:
    """A shipped Web tree must serve each `boot` asset at a route the resolver reads (#715).

    The reading is the resolver's own: how many boot files resolve, and the IDs
    of those that do not. A tree that ships no asset root is reported as such,
    never as a crash or a skip — that is the export dropping the root, which
    #630 measured as the player-visible stall.
    """
    boot_files = boot_asset_ids(_manifest(repo_root))
    if not boot_files:
        raise ExportError(f"the manifest names no loadable {ASSET_ROOT}/ file for boot")
    missing = missing_boot_files(shipped, repo_root)
    if not missing:
        return
    ids = ", ".join(f"{asset_id} ({path})" for asset_id, path in missing)
    total = len({path for _, path in boot_files})
    resolved = total - len(missing)
    if not asset_root_present(shipped, repo_root):
        raise ExportError(
            f"0 of {total} boot asset file(s) resolved — {ASSET_ROOT}/ absent from the "
            f"exported tree {shipped}: {ids}"
        )
    raise ExportError(
        f"{resolved} of {total} boot asset file(s) resolved — no route serves: {ids}"
    )


def prepare_asset_root(repo_root: Path, shipped: Path) -> None:
    """Stage the repo-root asset root and audio copies for export and for serving.

    Godot only exports files inside the project tree (`game/`), so the copies go
    to `game/<root>/`. Both presets are `export_filter="exclude"`, so what the
    engine packs for those files is import metadata and remapped derivatives,
    never the source file, while the resolver opens the source path. The shipped
    tree therefore also serves the sources **loose** under `<root>/` beside
    `index.html`, at the `res://<root>/…` route `game/asset_resolver.gd` builds
    on Web. Copied, never moved: `game_assets/` stays the source of truth at the
    repo root (ADR-0005); both copies are untracked build output.
    """
    shipped.mkdir(parents=True, exist_ok=True)
    for name in (ASSET_ROOT, AUDIO_RUNTIME):
        source = repo_root / name
        if not source.is_dir():
            raise ExportError(f"missing asset directory: {name}/")
        destination = repo_root / "game" / name
        if destination.exists():
            shutil.rmtree(destination)
        shutil.copytree(source, destination)
        served = shipped / name
        if served.exists():
            shutil.rmtree(served)
        shutil.copytree(source, served)


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


def asset_files(document: dict, asset_id: str) -> list[str]:
    """`asset_id`'s files that are loadable content rather than a license text."""
    entry: dict = document.get("assets", {}).get(asset_id, {})
    return [
        str(name)
        for name in entry.get("files", [])
        if Path(str(name)).suffix in LOADABLE_SUFFIXES
    ]


def boot_asset_ids(document: dict) -> list[tuple[str, str]]:
    """`(asset ID, asset-root-relative file)` for each file the `boot` group preloads.

    Read from the committed manifest, so the check follows the catalog. One
    approved entry can name several files; each is a separate route to serve.
    """
    return [
        (str(asset_id), path)
        for asset_id in document.get("groups", {}).get("boot", [])
        for path in asset_files(document, asset_id)
    ]


def _manifest(repo_root: Path) -> dict:
    """The committed manifest `game/asset_manifest.json` the catalog generates."""
    manifest_path = repo_root / "game" / MANIFEST
    if not manifest_path.is_file():
        raise ExportError(f"missing manifest: game/{MANIFEST}")
    return json.loads(manifest_path.read_text(encoding="utf-8"))


def ensure_no_client_engine(shipped: Path) -> None:
    """A shipped Web tree must carry no Stockfish binary, engine WASM, or engine endpoint.

    ADR-0002 §Validation "No client Stockfish endpoint" and CTR-advice-stream G3:
    the client talks only to the advice backend, so an export that names the
    engine, ships an engine file kind, or carries a `uci` endpoint must not
    publish. The PCK is where the tree's client code lives, so it is read as text
    beside `index.html`; every other file is read by its kind. One function
    produces every verdict: the passing one on a real export and the
    contra-positive ones on a synthetic directory the check writes itself.
    """
    for path in _data_files(shipped):
        relative = _relative(path, shipped)
        if relative in APP_ENTRY_POINTS:
            continue
        if path.suffix.lower() in ENGINE_BUNDLE_SUFFIXES or ENGINE_BUNDLE_NAMES.search(path.name):
            raise BundleError(f"the shipped tree carries an engine file: {relative}")
    for name in ENGINE_TEXT_ARTIFACTS:
        artifact = shipped / name
        if not artifact.is_file():
            raise BundleError(f"the check reads {name}, but the shipped tree has none")
        text = artifact.read_bytes()
        found = ENGINE_BUNDLE_NAMES.search(text.decode("utf-8", "replace"))
        if found is not None:
            raise BundleError(f"{name} names the engine ({found.group(0)})")
        marker = ENGINE_ENDPOINT_MARKERS.search(text.decode("utf-8", "replace"))
        if marker is not None:
            raise BundleError(f"{name} carries a UCI engine marker ({marker.group(0).strip()})")


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


def synthetic_engine_verdicts(script: Path | None = None) -> int:
    """Require the bundle check to refuse every contra-positive tree it writes.

    The job needs no Godot export for the red direction (#696): each case is a
    synthetic export directory written here — scene artifacts, a PCK, an engine
    `.wasm`, an engine-named HTML, a UCI endpoint — and `ensure_no_client_engine`
    must refuse it. `script` writes the same trees through this module's own CLI
    (`--check-engine`), so the command line the workflows run is the one proven
    red; without it the function calls the check in process.
    """
    cases: list[tuple[str, dict[str, bytes]]] = [
        (f"a PCK that names {INJECTED_ENGINE_NAME}", {PACK: f"res://bin/{INJECTED_ENGINE_NAME}\x00".encode()}),
        (f"a loose engine named {INJECTED_ENGINE_NAME}", {INJECTED_ENGINE_NAME: b"\x7fELF\x02\x01"}),
        (f"an endpoint string ({INJECTED_ENGINE_ENDPOINT})", {"index.html": INJECTED_ENGINE_ENDPOINT.encode()}),
        ("an engine .wasm", {f"{INJECTED_ENGINE_NAME}.wasm": b"\x00asm\x01\x00\x00\x00"}),
        ("an engine .nnue", {"nn-5af11540bbfe.nnue": b"\x00\x00"}),
    ]
    for label, files in cases:
        with tempfile.TemporaryDirectory() as temporary:
            tree = Path(temporary)
            (tree / "index.html").write_bytes(b"<html></html>")
            (tree / PACK).write_bytes(b"GDPC")
            for name, body in files.items():
                (tree / name).write_bytes(body)
            if _synthetic_case_passes(tree, script):
                print(f"the bundle check passed {label}: {tree}")
                return 1
            print(f"refused {label}")
    return 0


def _synthetic_case_passes(tree: Path, script: Path | None) -> bool:
    """Whether one synthetic tree escapes the check (through the CLI when `script` is given)."""
    if script is None:
        try:
            ensure_no_client_engine(tree)
        except BundleError:
            return False
        return True
    completed = subprocess.run(
        [sys.executable, str(script), "--check-engine", str(tree)],
        check=False,
        capture_output=True,
    )
    return completed.returncode == 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--preset", choices=[PLAYTEST_PRESET, RELEASE_PRESET])
    parser.add_argument(
        "--check-boot",
        action="store_true",
        help="fail unless the shipped tree serves each boot asset at a route the resolver reads",
    )
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
    parser.add_argument(
        "--check-engine",
        nargs="+",
        metavar="TREE",
        help="fail on a shipped tree carrying a Stockfish binary, engine WASM, or engine endpoint",
    )
    parser.add_argument(
        "--synthetic-engine-verdicts",
        action="store_true",
        help="write the contra-positive trees and require --check-engine to refuse every one",
    )
    parser.add_argument("--repo", default=".")
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"))
    args = parser.parse_args(argv)
    modes = [
        chosen
        for chosen in (
            args.pages_status is not None,
            args.check_assets,
            args.check_boot,
            args.check_engine is not None,
            args.synthetic_engine_verdicts,
            args.preset is not None,
        )
        if chosen
    ]
    if args.pages_status is not None and (args.check_assets or args.check_boot):
        parser.error("--pages-status does not combine with an export-tree check")
    # `--check-assets`/`--check-boot` read the export's output directory, so each
    # needs `--preset`; every other pair of modes is exclusive.
    tree_check = args.check_assets or args.check_boot
    engine_mode = args.check_engine is not None or args.synthetic_engine_verdicts
    if tree_check and args.preset is None:
        parser.error("--check-assets/--check-boot need --preset to find the export's output directory")
    if engine_mode and (tree_check or args.preset is not None or args.pages_status is not None):
        parser.error(
            "--check-engine and --synthetic-engine-verdicts are mutually exclusive with "
            "every other mode"
        )
    if not modes:
        parser.error(
            "one of --preset, --check-assets, --check-boot, --check-engine, "
            "--synthetic-engine-verdicts or --pages-status is required"
        )
    if args.pages_status is not None:
        try:
            present = release_gate(pages_present_from_status(args.pages_status))
        except ExportError as error:
            print(error)
            return 1
        print("true" if present else "false")
        return 0
    if args.synthetic_engine_verdicts:
        return synthetic_engine_verdicts(Path(args.check_engine[0]) if args.check_engine else None)
    if args.check_engine:
        try:
            for tree in args.check_engine:
                ensure_no_client_engine(Path(tree).resolve())
        except BundleError as error:
            print(error)
            return 1
        print(" ".join(args.check_engine))
        return 0
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
        if args.check_boot:
            ensure_boot_assets_resolve(output.parent, repo_root)
            total = len({path for _, path in boot_asset_ids(_manifest(repo_root))})
            missing = missing_boot_files(output.parent, repo_root)
            print(f"{total - len(missing)} of {total} boot asset file(s) resolved from {output.parent}")
            return 0
        export(repo_root, args.preset, Path(args.godot), output)
    except ExportError as error:
        print(error)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
