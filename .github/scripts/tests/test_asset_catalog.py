"""Tests for asset_catalog.py."""
from __future__ import annotations

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from asset_catalog import check, read_hub  # noqa: E402
from new_asset_id import uuid7  # noqa: E402

HUB = """# Asset Pipeline

## Asset kinds

| Kind | Applicability | Grounds | Kind specs |
|------|---------------|---------|------------|
| Sprites | Applies | 2D | [`kinds/character-sprites.md`](kinds/character-sprites.md), `tile-sprites` (planned) |
| Music | N/A — silent | none | <!-- fill in --> |

## Catalog

- **Catalog root**: {catalog} (ADR-0004)
- **Asset root**: {assets} (ADR-0004)

## Lifecycle
"""


CHARACTER_KIND = """# Asset Kind: Character sprites

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Idle | One pose | 8 |

## Recipes

### R1 — Idle

- **Outputs**: one file per coverage row

## Naming

- **Handle name**: `character-sprites/<name>`
"""

SHEET_ANCHORS = (
    ("01a14f87-eeee-7f30-aa10-4516f0191610", "piece-sprites/style-anchor-sheet", "AK-piece-sprites"),
    ("01a15199-87f5-7df8-a987-eecaaca9f919", "icons/style-anchor-sheet", "AK-icons"),
    ("01a151ef-6a32-77ec-ace1-9190aa56b7dc", "interface-art/style-anchor-sheet", "AK-interface-art"),
)


def entry(**overrides: object) -> dict[str, object]:
    base: dict[str, object] = {
        "id": str(uuid7()),
        "handle": "character-sprites/player-idle",
        "kind_spec": "AK-character-sprites",
        "serves": ["CH-player"],
        "state": "draft",
        "version": 1,
        "files": ["character-sprites/player-idle.png"],
        "source_type": "human-made",
        "license": {"grant": "assigned"},
        "supplier": "A. Artist",
    }
    base.update(overrides)
    return {k: v for k, v in base.items() if v is not ...}


class CatalogTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        (self.root / "specs/assets").mkdir(parents=True)
        self.hub("`game/catalog/`", "`game/assets`")
        (self.root / "game/catalog").mkdir(parents=True)
        (self.root / "game/assets/character-sprites").mkdir(parents=True)
        kinds = self.root / "specs/assets/kinds"
        kinds.mkdir(parents=True)
        (kinds / "character-sprites.md").write_text(CHARACTER_KIND, encoding="utf-8")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def hub(self, catalog: str, assets: str) -> None:
        (self.root / "specs/assets/assets.md").write_text(HUB.format(catalog=catalog, assets=assets), encoding="utf-8")

    def add(self, data: dict[str, object], *, files: bool = True) -> str:
        name = f"{data.get('id', 'x')}.json"
        (self.root / "game/catalog" / name).write_text(json.dumps(data), encoding="utf-8")
        for f in data.get("files", []) if files else []:  # type: ignore[union-attr]
            path = self.root / "game/assets" / str(f)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"png")
        return name

    def checks(self) -> list[str]:
        findings, _ = check(self.root)
        return [f"{f.check}: {f.message}" for f in findings]

    def test_reads_hub(self) -> None:
        hub = read_hub(self.root)
        self.assertEqual((hub.catalog_root, hub.asset_root), ("game/catalog", "game/assets"))
        self.assertEqual(hub.kind_specs, {"character-sprites", "tile-sprites"})

    def test_skips_until_catalog_root_is_set(self) -> None:
        self.hub("TBD — which folder? `game/catalog/`", "<!-- fill in -->")
        findings, notes = check(self.root)
        self.assertEqual(findings, [])
        self.assertIn("skipped", notes[0])

    def test_valid_entry_passes(self) -> None:
        self.add(entry())
        self.add(entry(handle="tile-sprites/grass", kind_spec="AK-tile-sprites", files=["tile-sprites/grass.png"]))
        self.assertEqual(self.checks(), [])

    def test_asset_id_must_be_uuid7_and_match_file_name(self) -> None:
        self.add(entry(id="123e4567-e89b-12d3-a456-426614174000"))
        good = entry(files=["character-sprites/b.png"], handle="character-sprites/b")
        (self.root / "game/catalog/wrong-name.json").write_text(json.dumps(good), encoding="utf-8")
        (self.root / "game/assets/character-sprites/b.png").write_bytes(b"png")
        found = self.checks()
        self.assertIn("I2: 'id' is not a lowercase UUID version 7", found)
        self.assertIn("I2: file name must be '<id>.json'", found)

    def test_handles_unique_and_prefixed_by_hub_kind_spec(self) -> None:
        self.add(entry())
        self.add(entry(files=["character-sprites/other.png"]))
        self.add(entry(handle="sprites/hero", files=["character-sprites/hero.png"]))
        found = self.checks()
        self.assertTrue(any(f.startswith("I7: handle 'character-sprites/player-idle' is also used") for f in found))
        self.assertTrue(any("prefix 'sprites' is not a kind spec" in f for f in found))

    def test_approved_needs_pass_or_exemption(self) -> None:
        self.add(entry(state="approved"))
        self.add(entry(state="approved", handle="character-sprites/b", files=["character-sprites/b.png"],
                       exemption={"granted_by": "A. Artist", "date": "2026-10-15", "reason": "hand-drawn"}))
        found = self.checks()
        self.assertEqual([f for f in found if f.startswith("I3")], ["I3: approved entry needs a review with verdict 'Pass', or an exemption"])

    def test_exemption_needs_person_date_reason(self) -> None:
        self.add(entry(exemption={"granted_by": "", "date": "15/10/2026", "reason": "ok"}))
        found = self.checks()
        self.assertIn("I6: 'exemption' is missing granted_by", found)
        self.assertIn("I6: 'exemption.date' must be YYYY-MM-DD", found)

    def test_agent_generated_needs_tool_recipe_generation(self) -> None:
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"]))
        found = self.checks()
        for key in ("generation", "tool_role", "recipe"):
            with self.subTest(key=key):
                self.assertTrue(any(f"'{key}'" in f for f in found))

    def test_agent_generation_needs_structured_parts(self) -> None:
        gen = {"tool": "Recraft"}
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        found = self.checks()
        self.assertTrue(any("'generation' is missing" in f for f in found))

    def test_agent_generation_with_style_needs_series(self) -> None:
        gen = {
            "prompt": "player idle", "tool": "Recraft", "operation": "generate_image",
            "settings": {"model": "recraftv4_1_raster", "input_style_id": "style-1"},
            "inputs": {"style_anchors": [], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        found = self.checks()
        self.assertTrue(any("'series'" in f for f in found))

    def test_agent_generation_structured_passes(self) -> None:
        gen = {
            "prompt": "player idle", "tool": "Recraft", "operation": "generate_image",
            "settings": {"model": "recraftv4_1_raster", "image_size": "1:1", "input_style_id": "style-1"},
            "inputs": {"style_anchors": ["0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e"], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
            "series": {"id": "AK-character-sprites.SS1", "recraft_style_id": "style-1"},
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        self.assertEqual(self.checks(), [])

    def test_agent_generation_music_series_passes(self) -> None:
        gen = {
            "prompt": "battle theme", "tool": "ElevenLabs", "operation": "compose",
            "settings": {"model": "music_v2_5", "finetune_id": "ft-1"},
            "inputs": {"style_anchors": ["0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e"], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
            "series": {"id": "AK-music.SS1", "elevenlabs_finetune_id": "ft-1"},
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        self.assertEqual(self.checks(), [])

    def test_agent_generation_sfx_soft_series_passes(self) -> None:
        gen = {
            "prompt": "ui click", "tool": "ElevenLabs", "operation": "text_to_sound_effects",
            "settings": {"model": "eleven_text_to_sound_v2"},
            "inputs": {"style_anchors": ["0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e"], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
            "series": {"id": "AK-sound-effects.SS1", "soft_enforce": True},
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        self.assertEqual(self.checks(), [])

    def test_agent_generation_series_rejects_multiple_bindings(self) -> None:
        gen = {
            "prompt": "x", "tool": "ElevenLabs", "operation": "compose",
            "settings": {"model": "music_v2_5", "finetune_id": "ft-1"},
            "inputs": {"style_anchors": [], "refs": [], "base_assets": []},
            "seed": "n/a — tool has no seed",
            "series": {
                "id": "AK-music.SS1",
                "elevenlabs_finetune_id": "ft-1",
                "recraft_style_id": "style-1",
            },
        }
        self.add(entry(source_type="ai-generation", supplier=..., coverage=["AK-character-sprites.V1"],
                       tool_role={"role": "TL.1", "adr": "adr-free"}, recipe="AK-character-sprites.R1",
                       generation=gen))
        found = self.checks()
        self.assertTrue(any("exactly one" in f for f in found))

    def test_files_exist_and_every_file_is_owned(self) -> None:
        self.add(entry(), files=False)
        (self.root / "game/assets/character-sprites/stray.png").write_bytes(b"png")
        (self.root / "game/assets/character-sprites/stray.png.import").write_bytes(b"x")
        found = self.checks()
        self.assertIn("I1: file 'character-sprites/player-idle.png' does not exist under game/assets", found)
        self.assertIn("I1: file belongs to no catalog entry", found)
        self.assertEqual(len([f for f in found if f.startswith("I1")]), 2)

    def test_successor_must_be_another_entry(self) -> None:
        self.add(entry(state="deprecated", deprecation_reason="replaced", successor=str(uuid7())))
        self.assertTrue(any(f.startswith("I4: successor") for f in self.checks()))

    def test_touchups_need_full_record_and_agreement_when_person_supplied(self) -> None:
        full = {"operation": "remove background", "tool": "Recraft", "terms": "Pro plan", "date": "2026-10-15",
                "reason": "transparent background per S4", "run_by": "agent",
                "prompt": "remove background", "inputs": {}}
        self.add(entry(touchups=[full]))
        self.add(entry(handle="character-sprites/b", files=["character-sprites/b.png"], touchups=[{"tool": "Recraft"}]))
        self.add(entry(handle="character-sprites/c", files=["character-sprites/c.png"], touchups=[]))
        found = self.checks()
        self.assertIn("fields: 'touchups[0]' is missing agreed_by", found)
        self.assertTrue(any("'touchups[0]' is missing operation, terms, date, reason, run_by, agreed_by" in f for f in found))
        self.assertIn("fields: 'touchups' must be a non-empty list", found)

    def test_agent_touchups_need_prompt_and_inputs(self) -> None:
        touchup = {"operation": "remove background", "tool": "Recraft", "terms": "Pro plan",
                   "date": "2026-10-15", "reason": "transparent background", "run_by": "agent"}
        self.add(entry(supplier=..., coverage=["AK-character-sprites.V1"], touchups=[touchup]))
        found = self.checks()
        self.assertTrue(any("prompt" in f and "inputs" in f for f in found))

    def test_banned_tools_rejected(self) -> None:
        (self.root / "docs").mkdir()
        (self.root / "docs/asset-tools.md").write_text(
            "# Asset tools\n\n## Banned tools\n\n| Tool | Scope |\n|------|-------|\n| Pixellab | Never |\n\n## Touch-up\n",
            encoding="utf-8")
        touchup = {"operation": "inpaint", "tool": "PixelLab MCP", "terms": "t", "date": "2026-10-15",
                   "reason": "r", "run_by": "agent", "agreed_by": "A. Artist"}
        self.add(entry(source_type="ai-generation", generation={"tool": "pixellab"}, touchups=[touchup]))
        found = self.checks()
        self.assertEqual(len([f for f in found if f.startswith("I8")]), 2)

    def test_rejects_null_and_non_entry_files(self) -> None:
        self.add(entry(successor=None))
        (self.root / "game/catalog/notes.txt").write_text("hi", encoding="utf-8")
        found = self.checks()
        self.assertIn("fields: 'successor' is null", found)
        self.assertTrue(any(f.startswith("catalog: only entry files") for f in found))

    def test_empty_coverage_requires_style_anchor(self) -> None:
        self.add(entry(supplier=..., coverage=[], source_type="ai-generation",
                       tool_role={"role": "TL.1", "adr": "adr-free"},
                       recipe="AK-character-sprites.R1",
                       generation={
                           "prompt": "x", "tool": "Recraft", "operation": "generate_image",
                           "settings": {"model": "m"}, "inputs": {"style_anchors": [], "refs": [], "base_assets": []},
                           "seed": "n/a — tool has no seed",
                       }))
        found = self.checks()
        self.assertIn("I9: empty 'coverage' is only allowed for SS1 style anchors", found)

    def test_style_anchor_may_have_empty_coverage(self) -> None:
        asset_id = str(uuid7())
        kinds = self.root / "specs/assets/kinds"
        kinds.mkdir(parents=True, exist_ok=True)
        (kinds / "character-sprites.md").write_text(
            f"# Sprites\n\n- **Style anchors**: `{asset_id}` (`character-sprites/player-idle`)\n",
            encoding="utf-8",
        )
        self.add(entry(
            id=asset_id,
            supplier=...,
            coverage=[],
            source_type="ai-generation",
            tool_role={"role": "TL.1", "adr": "adr-free"},
            recipe="AK-character-sprites.R1",
            generation={
                "prompt": "sheet", "tool": "Recraft", "operation": "generate_image",
                "settings": {"model": "m"}, "inputs": {"style_anchors": [], "refs": [], "base_assets": []},
                "seed": "n/a — tool has no seed",
            },
            review={"verdict": "Pass", "date": "2026-10-20", "reviewer": "agent", "report": "ok"},
            state="approved",
        ))
        self.assertEqual(self.checks(), [])
        self.assertIn(asset_id, read_hub(self.root).style_anchors)


class CoverageIntegrityTest(unittest.TestCase):
    """CAT.I10 fixtures. They do not write the live catalog."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        real = Path(__file__).resolve().parents[3]
        assets = self.root / "specs/assets"
        assets.mkdir(parents=True)
        os.symlink(real / "specs/assets/kinds", assets / "kinds")
        os.symlink(real / "specs/assets/catalog.md", assets / "catalog.md")
        os.symlink(real / "specs/assets/catalog", assets / "catalog")
        (assets / "assets.md").write_text((real / "specs/assets/assets.md").read_text(encoding="utf-8"), encoding="utf-8")
        (self.root / "asset_catalog").mkdir()
        (self.root / "game_assets").mkdir()

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def add(self, **overrides: object) -> None:
        data = entry(**overrides)
        (self.root / "asset_catalog" / f"{data['id']}.json").write_text(json.dumps(data), encoding="utf-8")
        for rel in data.get("files", []):  # type: ignore[union-attr]
            path = self.root / "game_assets" / str(rel)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"asset")

    def i10(self) -> list[str]:
        findings, _ = check(self.root)
        return [f"{f.check}: {f.message}" for f in findings if f.check == "I10"]

    def checks(self) -> list[str]:
        findings, _ = check(self.root)
        return [str(f) for f in findings]

    def _sheet_anchors(self) -> None:
        for asset_id, handle, kind_spec in SHEET_ANCHORS:
            self.add(id=asset_id, handle=handle, kind_spec=kind_spec, supplier=..., coverage=[], files=[f"{handle}.png"])

    def test_live_catalog_passes(self) -> None:
        findings, _ = check(Path(__file__).resolve().parents[3])
        self.assertEqual([str(f) for f in findings], [])

    def test_incomplete_catalog_passes(self) -> None:
        self._sheet_anchors()
        self.add(handle="board-backgrounds/play-table", kind_spec="AK-board-backgrounds", supplier=...,
                 coverage=["AK-board-backgrounds.V1"], files=["board-backgrounds/play-table.png"])
        for handle, vid in (
            ("sound-effects/touch-select", "V1"),
            ("sound-effects/move-settle", "V2"),
            ("sound-effects/check", "V3"),
            ("sound-effects/end-resolve", "V4"),
            ("sound-effects/puzzle-fail", "V5"),
        ):
            self.add(handle=handle, kind_spec="AK-sound-effects", supplier=...,
                     coverage=[f"AK-sound-effects.{vid}"], files=[f"{handle}.ogg"])
        for handle, vid in (("music/cafe-ambient-a", "V1"), ("music/cafe-ambient-b", "V2")):
            self.add(handle=handle, kind_spec="AK-music", supplier=...,
                     coverage=[f"AK-music.{vid}"], files=[f"{handle}.ogg"])
        for handle in ("fonts/noto-sans", "fonts/noto-sans-cjk"):
            self.add(handle=handle, kind_spec="AK-fonts", supplier="Noto", source_type="third-party",
                     coverage=["AK-fonts.V1"], files=[f"{handle}-400.woff2", f"{handle}-700.woff2", f"{handle}/OFL.txt"])
        self.add(handle="fonts/demo-only", kind_spec="AK-fonts", files=["fonts/demo-only.ttf"])
        self.assertEqual(self.checks(), [])

    def test_one_piece_file_passes_and_thirteenth_claim_fails(self) -> None:
        for side in ("white", "black"):
            for piece in ("k", "q", "r", "b", "n", "p"):
                name = f"{piece}-{side}"
                self.add(handle=f"piece-sprites/{name}", kind_spec="AK-piece-sprites", supplier=...,
                         coverage=["AK-piece-sprites.V1"], files=[f"piece-sprites/{name}.svg"])
        self.assertEqual(self.i10(), [])
        self.add(handle="piece-sprites/extra-white", kind_spec="AK-piece-sprites", supplier=...,
                 coverage=["AK-piece-sprites.V1"], files=["piece-sprites/extra-white.svg"])
        self.assertTrue(any("AK-piece-sprites.V1" in f and "maximum is 12" in f for f in self.i10()))

    def test_one_handle_listing_every_piece_type_fails(self) -> None:
        self.add(handle="piece-sprites/all-types", kind_spec="AK-piece-sprites", supplier=...,
                 coverage=["AK-piece-sprites.V1"], files=["piece-sprites/all-types.svg"])
        self.assertTrue(any("does not match Naming" in f for f in self.i10()))

    def test_icons_per_subject_pass_and_one_entry_listing_every_row_fails(self) -> None:
        for handle, vid in (
            ("icons/mode-shared", "V1"),
            ("icons/mode-puzzle", "V2"),
            ("icons/quit", "V3"),
            ("icons/back", "V4"),
            ("icons/advice", "V5"),
        ):
            self.add(handle=handle, kind_spec="AK-icons", supplier=...,
                     coverage=[f"AK-icons.{vid}"], files=[f"{handle}.svg"])
        self.add(handle="icons/advice-on", kind_spec="AK-icons", supplier=...,
                 coverage=["AK-icons.V5"], files=["icons/advice-on.svg"])
        self.assertEqual(self.i10(), [])
        self.add(handle="icons/advice-off", kind_spec="AK-icons", supplier=...,
                 coverage=["AK-icons.V5"], files=["icons/advice-off.svg"])
        self.assertTrue(any("AK-icons.V5" in f and "maximum is 2" in f for f in self.i10()))

    def test_one_icons_entry_listing_v1_through_v5_fails(self) -> None:
        self.add(handle="icons/all", kind_spec="AK-icons", supplier=..., files=["icons/all.svg"],
                 coverage=["AK-icons.V1", "AK-icons.V2", "AK-icons.V3", "AK-icons.V4", "AK-icons.V5"])
        self.assertTrue(any("one file carries one Coverage row" in f for f in self.i10()))

    def test_interface_art_one_row_per_handle(self) -> None:
        self.assertEqual(self.i10(), [])
        self.add(handle="interface-art/panel-surface", kind_spec="AK-interface-art", supplier=...,
                 coverage=["AK-interface-art.V1"], files=["interface-art/panel-surface.svg"])
        self.add(handle="interface-art/chip-surface", kind_spec="AK-interface-art", supplier=...,
                 coverage=["AK-interface-art.V2"], files=["interface-art/chip-surface.svg"])
        self.assertEqual(self.i10(), [])
        self.add(handle="interface-art/both-surface", kind_spec="AK-interface-art", supplier=...,
                 coverage=["AK-interface-art.V1", "AK-interface-art.V2"], files=["interface-art/both-surface.svg"])
        self.assertTrue(any("one entry lists one of them" in f for f in self.i10()))

    def test_font_anchors_pass_and_third_claim_fails(self) -> None:
        for handle in ("fonts/noto-sans", "fonts/noto-sans-cjk"):
            self.add(handle=handle, kind_spec="AK-fonts", supplier="Noto", source_type="third-party",
                     coverage=["AK-fonts.V1"], files=[f"{handle}-400.woff2", f"{handle}-700.woff2"])
        self.assertEqual(self.i10(), [])
        self.add(handle="fonts/other-regular", kind_spec="AK-fonts", supplier=...,
                 coverage=["AK-fonts.V1"], files=["fonts/other-regular.woff2"])
        self.assertTrue(any("AK-fonts.V1" in f and "maximum is 2" in f for f in self.i10()))

    def test_second_count_one_claim_fails(self) -> None:
        self.add(handle="music/cafe-ambient-a", kind_spec="AK-music", supplier=...,
                 coverage=["AK-music.V1"], files=["music/cafe-ambient-a.ogg"])
        self.add(handle="board-backgrounds/play-table", kind_spec="AK-board-backgrounds", supplier=...,
                 coverage=["AK-board-backgrounds.V1"], files=["board-backgrounds/play-table.png"])
        self.assertEqual(self.i10(), [])
        self.add(handle="music/extra-bed", kind_spec="AK-music", supplier=...,
                 coverage=["AK-music.V1"], files=["music/extra-bed.ogg"])
        self.add(handle="board-backgrounds/other", kind_spec="AK-board-backgrounds", supplier=...,
                 coverage=["AK-board-backgrounds.V1"], files=["board-backgrounds/other.png"])
        found = self.i10()
        self.assertTrue(any("AK-music.V1" in f and "maximum is 1" in f for f in found))
        self.assertTrue(any("AK-board-backgrounds.V1" in f and "maximum is 1" in f for f in found))

    def test_sheet_anchors_with_empty_coverage_stay_under_i9(self) -> None:
        self._sheet_anchors()
        self.assertEqual(self.checks(), [])

    def test_draft_is_checked_like_approved_and_deprecated_adds_no_claim(self) -> None:
        review = {"verdict": "Pass", "date": "2026-10-20", "reviewer": "agent", "report": "ok"}
        self.add(handle="icons/all", kind_spec="AK-icons", supplier=..., state="approved", review=review,
                 coverage=["AK-icons.V1", "AK-icons.V2"], files=["icons/all.svg"])
        self.assertTrue(any("one file carries one Coverage row" in f for f in self.i10()))
        self.add(handle="music/cafe-ambient-a", kind_spec="AK-music", supplier=...,
                 coverage=["AK-music.V1"], files=["music/cafe-ambient-a.ogg"])
        self.add(handle="music/retired", kind_spec="AK-music", supplier=..., state="deprecated",
                 deprecation_reason="replaced", coverage=["AK-music.V1"], files=["music/retired.ogg"])
        music = [f for f in self.i10() if "AK-music.V1" in f and "maximum" in f]
        self.assertEqual(music, [])

    def test_bad_coverage_ids_fail(self) -> None:
        self.add(handle="icons/mode-shared", kind_spec="AK-icons", supplier=...,
                 coverage=["V1"], files=["icons/mode-shared.svg"])
        self.add(handle="icons/mode-puzzle", kind_spec="AK-icons", supplier=...,
                 coverage=["AK-fonts.V1"], files=["icons/mode-puzzle.svg"])
        self.add(handle="icons/quit", kind_spec="AK-icons", supplier=...,
                 coverage=["AK-icons.V9"], files=["icons/quit.svg"])
        found = self.i10()
        self.assertTrue(any("not a qualified coverage ID" in f for f in found))
        self.assertTrue(any("AK-fonts.V1" in f and "not a Coverage row of icons" in f for f in found))
        self.assertTrue(any("AK-icons.V9" in f and "not a Coverage row of icons" in f for f in found))

    def test_omitted_coverage_on_person_supplied_entry_is_outside_i10(self) -> None:
        self.add(handle="fonts/demo-only", kind_spec="AK-fonts", files=["fonts/demo-only.ttf"])
        self.assertEqual(self.checks(), [])


if __name__ == "__main__":
    unittest.main()
