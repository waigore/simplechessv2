"""
Strip the served asset files for the #882 reproduction, the way the issue's
Reproduction steps describe it: a served export tree whose `game_assets/` files
are absent. The build's own pack does not carry the SVG/font sources (both
presets are `export_filter="exclude"`, see `.github/scripts/web_export.py`
`prepare_asset_root`), so deleting the served copies is what makes the Boot
group unresolvable at `res://game_assets/...` on Web.

    python3 scripts/strip_served_assets.py build/web build/web-served
"""

import shutil
import sys
from pathlib import Path


def main() -> int:
    source = Path(sys.argv[1])
    shipped = Path(sys.argv[2])
    if shipped.exists():
        shutil.rmtree(shipped)
    shutil.copytree(source, shipped)
    removed = []
    for name in ("game_assets", "audio_runtime"):
        root = shipped / name
        if not root.is_dir():
            continue
        for path in sorted(root.rglob("*")):
            if path.is_file():
                removed.append(str(path.relative_to(shipped)))
                path.unlink()
    print(f"{len(removed)} served asset file(s) removed under {shipped}")
    for route in removed[:5]:
        print(f"  {route}")
    if len(removed) > 5:
        print(f"  … {len(removed) - 5} more")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
