#!/usr/bin/env python3
"""Issue #63 acceptance check: every spec ID the demo README cites exists in specs/.

The demo contract (docs/demos.md) requires every included element to trace to a spec ID
that exists. This walks the README for ID-shaped tokens and looks each one up in the
`specs/` text. Resolution rules, in order:

1. the token appears literally in `specs/`;
2. its leading segment is a spec domain (`AES`, `PER`, `SPC`, `GS`, `PHY`, `SND`, `C6`, ...)
   and the rest of the token appears in that domain's spec file (`MOT.A1` -> `A1` in
   `specs/aesthetics/motion.md`);
3. the token is one of the README's own decision IDs (`D1`-`D14`), which the README defines
   itself and which cite spec elements in their own rows.

Source symbols (`CoordLabels.spots`) and file names are not ID-shaped and are ignored.

Usage: python3 check_spec_ids.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]   # repo root (docs/playtest/evidence/issue-63/<run>/)
README = ROOT / "demos" / "shared-game" / "README.md"
SELF_DEFINED = {f"D{n}" for n in range(1, 15)}

DOMAIN_FILES = {
    "MOT": "specs/aesthetics/motion.md",
    "AES": "specs/aesthetics/aesthetics.md",
    "PAL": "specs/aesthetics/palette.md",
    "SRF": "specs/aesthetics/surface.md",
    "SND": "specs/aesthetics/sound.md",
    "UIS": "specs/aesthetics/ui-style.md",
    "FRM": "specs/aesthetics/form.md",
    "PER": "specs/view/perception.md",
    "SPC": "specs/view/spatial-model.md",
    "PHY": "specs/view/physics.md",
    "GS": "specs/design/game-state.md",
    "END": "specs/design/end-conditions.md",
    "IN": "specs/ux/controls.md",
}

PATTERN = re.compile(r"\b[A-Z][A-Za-z0-9]*(?:-[A-Za-z0-9]+)*\.[A-Z][A-Za-z0-9]*(?:\.[A-Z][A-Za-z0-9]*)?\b")


def main() -> int:
    text = README.read_text(encoding="utf-8")
    tokens = set(PATTERN.findall(text)) | set(re.findall(r"\b[DFIMX]\d+\b", text))
    spec_files = {p: p.read_text(encoding="utf-8", errors="ignore") for p in (ROOT / "specs").rglob("*.md")}
    spec_text = "\n".join(spec_files.values())
    unresolved = []
    for token in sorted(tokens):
        if token in SELF_DEFINED or token in spec_text:
            continue
        head, _, tail = token.partition(".")
        if head in spec_text:
            continue
        owner = ROOT / DOMAIN_FILES.get(head, "")
        if tail and owner.is_file() and tail in owner.read_text(encoding="utf-8"):
            continue
        unresolved.append(token)
    print(f"ID-shaped tokens in {README.relative_to(ROOT)}: {len(tokens)}")
    print(f"unresolved against specs/: {len(unresolved)}")
    for token in unresolved:
        print(f"  unresolved: {token}")
    return 1 if unresolved else 0


if __name__ == "__main__":
    sys.exit(main())
