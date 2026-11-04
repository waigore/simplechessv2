#!/usr/bin/env python3
"""Print the cold-open readings one row per run, from the probe JSON files."""
import json
import sys
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else "shots856")
rows = []
for path in sorted(root.glob("*.json")):
    if path.name == "drive.json":
        continue
    data = json.loads(path.read_text())
    probe = data.get("probe") or {}
    panel = probe.get("panel") or {}
    paint = probe.get("paint") or {}
    timing = probe.get("paintTiming") or {}
    nav = probe.get("nav") or {}
    ctx = (probe.get("ctx") or [{}])[0]
    rows.append({
        "label": data.get("label"),
        "renderer": ("swiftshader" if data.get("swiftshader") else "hardware"),
        "warm": bool(data.get("warm")),
        "responseStart": nav.get("responseStart"),
        "firstCtxMs": round(ctx.get("start", 0)),
        "firstEngineFrame": paint.get("t"),
        "modePickPanel": panel.get("t"),
        "firstContentfulPaint": timing.get("first-contentful-paint"),
    })

header = ("label", "renderer", "warm", "responseStart", "firstCtxMs",
          "firstEngineFrame", "modePickPanel", "firstContentfulPaint")
widths = {key: max(len(key), *(len(str(row[key])) for row in rows)) if rows else len(key) for key in header}
print("  ".join(key.ljust(widths[key]) for key in header))
for row in rows:
    print("  ".join(str(row[key]).ljust(widths[key]) for key in header))
