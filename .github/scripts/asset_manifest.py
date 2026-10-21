#!/usr/bin/env python3
"""Generate game/asset_manifest.json from approved catalog entries.

The manifest lists only approved assets (ACC.A2, AST.R1, ADR-0005) and groups
them the way specs/assets/access.md G1–G3 name kinds. It is committed. CI
regenerates it and fails when the file disagrees.

Usage: asset_manifest.py [--root DIR] [--check | --write]
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))

from asset_catalog import read_hub  # noqa: E402

MANIFEST = Path("game") / "asset_manifest.json"
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


def check(root: Path) -> list[str]:
    path = root / MANIFEST
    try:
        expected = generate(root)
    except ValueError as exc:
        return [str(exc)]
    if not path.is_file():
        return [f"missing {MANIFEST.as_posix()}"]
    actual = path.read_text(encoding="utf-8")
    if actual != expected:
        return [f"{MANIFEST.as_posix()} disagrees with approved catalog entries"]
    return []


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
    print(f"Wrote {MANIFEST.as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
