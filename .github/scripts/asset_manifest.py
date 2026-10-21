#!/usr/bin/env python3
"""Generate game/asset_manifest.json from approved catalog entries.

The manifest lists only approved assets (ACC.A2, AST.R1, ADR-0005) and groups
them the way specs/assets/access.md G1–G3 name kinds. It is committed. CI
regenerates it and fails when the file disagrees.

`--write` also transcodes each approved Ogg Opus file to a Vorbis copy under
audio_runtime/ (AST.O3) using ffmpeg. `--check` hashes those copies and does
not need ffmpeg.

Usage: asset_manifest.py [--root DIR] [--check | --write]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))

from asset_catalog import read_hub  # noqa: E402

MANIFEST = Path("game") / "asset_manifest.json"
AUDIO_RUNTIME = Path("audio_runtime")
CHECKSUMS = AUDIO_RUNTIME / "checksums.json"
AUDIO_KINDS = frozenset({"sound-effects", "music"})
# ACC.G1–G3 member kinds. A kind outside this map is an error, not a guess.
KIND_GROUP = {
    "fonts": "boot",
    "interface-art": "boot",
    "icons": "boot",
    "piece-sprites": "play",
    "board-backgrounds": "play",
    "sound-effects": "play",
    "music": "ambient",
}
GROUPS = ("boot", "play", "ambient")


def kind_name(entry: dict[str, Any]) -> str:
    handle = str(entry.get("handle", ""))
    if "/" in handle:
        return handle.split("/", 1)[0]
    kind_spec = str(entry.get("kind_spec", ""))
    if kind_spec.startswith("AK-"):
        return kind_spec[3:]
    return ""


def manifest_document(entries: list[dict[str, Any]], asset_root: str) -> dict[str, Any]:
    groups: dict[str, list[str]] = {name: [] for name in GROUPS}
    assets: dict[str, dict[str, Any]] = {}
    for entry in entries:
        if entry.get("state") != "approved":
            continue
        asset_id = str(entry["id"])
        kind = kind_name(entry)
        group = KIND_GROUP.get(kind)
        if group is None:
            raise ValueError(f"{asset_id} kind '{kind}' is not in a load group")
        files = entry.get("files")
        if not isinstance(files, list) or not all(isinstance(item, str) for item in files):
            raise ValueError(f"{asset_id} files must be a list of paths")
        groups[group].append(asset_id)
        assets[asset_id] = {"state": "approved", "kind": kind, "files": list(files)}
    for name in GROUPS:
        groups[name].sort()
    return {"asset_root": asset_root, "groups": groups, "assets": assets}


def render(document: dict[str, Any]) -> str:
    return json.dumps(document, indent=2, sort_keys=True) + "\n"


def load_entries(root: Path, catalog_root: str) -> list[dict[str, Any]]:
    catalog = root / catalog_root
    entries: list[dict[str, Any]] = []
    for path in sorted(catalog.glob("*.json")):
        entry = json.loads(path.read_text(encoding="utf-8"))
        if isinstance(entry, dict):
            entries.append(entry)
    return entries


def generate(root: Path) -> str:
    hub = read_hub(root)
    if hub.catalog_root is None or hub.asset_root is None:
        raise ValueError("catalog root and asset root must be set in specs/assets/assets.md")
    document = manifest_document(load_entries(root, hub.catalog_root), hub.asset_root)
    return render(document)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def opus_sources(root: Path, document: dict[str, Any]) -> list[tuple[str, Path]]:
    asset_root = root / str(document["asset_root"])
    found: list[tuple[str, Path]] = []
    assets = document.get("assets", {})
    if not isinstance(assets, dict):
        raise ValueError("manifest assets must be an object")
    for asset_id in sorted(assets):
        entry = assets[asset_id]
        if not isinstance(entry, dict) or entry.get("kind") not in AUDIO_KINDS:
            continue
        files = entry.get("files", [])
        oggs = [item for item in files if str(item).lower().endswith(".ogg")]
        if len(oggs) != 1:
            raise ValueError(f"{asset_id} needs exactly one ogg file")
        found.append((str(asset_id), asset_root / str(oggs[0])))
    return found


def _sniff(path: Path, needle: bytes) -> bool:
    try:
        header = path.read_bytes()[:64]
    except OSError:
        return False
    return needle in header


def check_runtime(root: Path, document: dict[str, Any]) -> list[str]:
    try:
        sources = opus_sources(root, document)
    except ValueError as exc:
        return [str(exc)]
    if not sources:
        return []
    runtime = root / AUDIO_RUNTIME
    checksum_path = root / CHECKSUMS
    if not checksum_path.is_file():
        return [f"missing {CHECKSUMS.as_posix()}"]
    try:
        recorded = json.loads(checksum_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return [f"{CHECKSUMS.as_posix()} is not JSON"]
    if not isinstance(recorded, dict):
        return [f"{CHECKSUMS.as_posix()} must be an object"]
    problems: list[str] = []
    expected: set[str] = set()
    for asset_id, source in sources:
        expected.add(asset_id)
        dest = runtime / f"{asset_id}.ogg"
        if not source.is_file() or not _sniff(source, b"OpusHead"):
            problems.append(f"{asset_id} source is not Ogg Opus")
            continue
        if not dest.is_file() or not _sniff(dest, b"vorbis") or _sniff(dest, b"OpusHead"):
            problems.append(f"missing Vorbis copy for {asset_id}")
            continue
        row = recorded.get(asset_id)
        if not isinstance(row, dict):
            problems.append(f"checksum missing for {asset_id}")
            continue
        if sha256_file(source) != row.get("source_sha256"):
            problems.append(f"runtime audio is stale for {asset_id}")
        if sha256_file(dest) != row.get("runtime_sha256"):
            problems.append(f"runtime audio hash mismatch for {asset_id}")
    for asset_id in sorted(set(recorded) - expected):
        problems.append(f"unexpected runtime checksum {asset_id}")
    if runtime.is_dir():
        for path in sorted(runtime.glob("*.ogg")):
            if path.stem not in expected:
                problems.append(f"unexpected runtime file {path.name}")
    return problems


def write_runtime(root: Path, document: dict[str, Any]) -> None:
    ffmpeg = shutil.which("ffmpeg")
    if ffmpeg is None:
        raise ValueError("ffmpeg is required to transcode Ogg Opus into Vorbis")
    runtime = root / AUDIO_RUNTIME
    runtime.mkdir(parents=True, exist_ok=True)
    checksums: dict[str, dict[str, str]] = {}
    expected: set[str] = set()
    for asset_id, source in opus_sources(root, document):
        if not source.is_file() or not _sniff(source, b"OpusHead"):
            raise ValueError(f"{asset_id} source is not Ogg Opus")
        dest = runtime / f"{asset_id}.ogg"
        result = subprocess.run(
            [ffmpeg, "-y", "-i", str(source), "-c:a", "libvorbis", "-q:a", "5", str(dest)],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0 or not _sniff(dest, b"vorbis") or _sniff(dest, b"OpusHead"):
            detail = (result.stderr or "").strip().splitlines()
            tail = detail[-1] if detail else "no ffmpeg output"
            raise ValueError(f"ffmpeg failed for {asset_id}: {tail}")
        checksums[asset_id] = {
            "source_sha256": sha256_file(source),
            "runtime_sha256": sha256_file(dest),
        }
        expected.add(dest.name)
    for path in runtime.glob("*.ogg"):
        if path.name not in expected:
            path.unlink()
    (root / CHECKSUMS).write_text(json.dumps(checksums, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def check(root: Path) -> list[str]:
    path = root / MANIFEST
    try:
        expected = generate(root)
        document = json.loads(expected)
    except ValueError as exc:
        return [str(exc)]
    problems: list[str] = []
    if not path.is_file():
        problems.append(f"missing {MANIFEST.as_posix()}")
    elif path.read_text(encoding="utf-8") != expected:
        problems.append(f"{MANIFEST.as_posix()} disagrees with approved catalog entries")
    problems.extend(check_runtime(root, document))
    return problems


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="fail if the committed manifest is stale")
    mode.add_argument("--write", action="store_true", help="write the committed manifest")
    args = parser.parse_args(argv)
    root = args.root
    if args.check or not args.write:
        problems = check(root)
        for problem in problems:
            print(f"ERROR: {problem}", file=sys.stderr)
        print(f"Asset manifest: {len(problems)} error(s).")
        return 1 if problems else 0
    text = generate(root)
    path = root / MANIFEST
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    try:
        write_runtime(root, json.loads(text))
    except ValueError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"Wrote {MANIFEST.as_posix()} and {AUDIO_RUNTIME.as_posix()}/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
