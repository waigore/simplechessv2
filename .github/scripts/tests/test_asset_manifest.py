"""Tests for the approved-only asset manifest generator."""
from __future__ import annotations

import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from asset_manifest import check, generate, manifest_document, render, write_runtime  # noqa: E402

REPO = Path(__file__).resolve().parents[3]


def _entry(asset_id: str, kind: str, state: str, files: list[str]) -> dict:
    return {
        "id": asset_id,
        "handle": f"{kind}/sample",
        "kind_spec": f"AK-{kind}",
        "state": state,
        "files": files,
    }


class ManifestDocumentTests(unittest.TestCase):
    def test_approved_entries_only_and_groups_match_access_kinds(self) -> None:
        approved = "0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e"
        draft = "0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0f"
        retired = "0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d10"
        music = "0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d11"
        document = manifest_document(
            [
                _entry(draft, "icons", "draft", ["icons/a.svg"]),
                _entry(approved, "icons", "approved", ["icons/a.svg"]),
                _entry(retired, "fonts", "deprecated", ["fonts/a.woff2"]),
                _entry(music, "music", "approved", ["music/a.ogg"]),
            ],
            "game_assets",
        )
        self.assertEqual(document["groups"]["boot"], [approved])
        self.assertEqual(document["groups"]["play"], [])
        self.assertEqual(document["groups"]["ambient"], [music])
        self.assertNotIn(draft, document["assets"])
        self.assertNotIn(retired, document["assets"])
        self.assertEqual(document["assets"][approved]["files"], ["icons/a.svg"])

    def test_unknown_kind_is_an_error(self) -> None:
        with self.assertRaises(ValueError):
            manifest_document(
                [_entry("0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e", "voice", "approved", ["voice/a.ogg"])],
                "game_assets",
            )

    def test_render_is_stable(self) -> None:
        document = manifest_document([], "game_assets")
        self.assertTrue(render(document).endswith("\n"))
        self.assertEqual(json.loads(render(document))["asset_root"], "game_assets")


class CommittedManifestTests(unittest.TestCase):
    def test_committed_manifest_matches_catalog(self) -> None:
        self.assertEqual(check(REPO), [])
        self.assertEqual((REPO / "game" / "asset_manifest.json").read_text(encoding="utf-8"), generate(REPO))

    def test_check_fails_when_manifest_is_stale(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "specs" / "assets").mkdir(parents=True)
            (root / "specs" / "assets" / "assets.md").write_text(
                (REPO / "specs" / "assets" / "assets.md").read_text(encoding="utf-8"),
                encoding="utf-8",
            )
            (root / "specs" / "assets" / "kinds").mkdir()
            catalog = root / "asset_catalog"
            catalog.mkdir()
            (catalog / "0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e.json").write_text(
                json.dumps(_entry("0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d0e", "icons", "approved", ["icons/a.svg"])),
                encoding="utf-8",
            )
            manifest = root / "game" / "asset_manifest.json"
            manifest.parent.mkdir()
            manifest.write_text("{}\n", encoding="utf-8")
            problems = check(root)
            self.assertTrue(any("disagrees" in problem for problem in problems))

    def test_check_fails_when_runtime_audio_is_stale(self) -> None:
        asset_id = "0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d11"
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self._hub(root)
            source = root / "game_assets" / "music" / "a.ogg"
            source.parent.mkdir(parents=True)
            source.write_bytes(b"OggS" + b"\x00" * 16 + b"OpusHead")
            runtime = root / "audio_runtime" / f"{asset_id}.ogg"
            runtime.parent.mkdir()
            runtime.write_bytes(b"OggS" + b"\x00" * 16 + b"\x01vorbis")
            catalog = root / "asset_catalog"
            catalog.mkdir()
            (catalog / f"{asset_id}.json").write_text(
                json.dumps(_entry(asset_id, "music", "approved", ["music/a.ogg"])),
                encoding="utf-8",
            )
            self._write_manifest(root)
            self._write_checksums(root, asset_id, source, runtime)
            self.assertEqual(check(root), [])
            source.write_bytes(source.read_bytes() + b"x")
            problems = check(root)
            self.assertTrue(any("stale" in problem for problem in problems))

    def test_transcode_writes_vorbis(self) -> None:
        if shutil.which("ffmpeg") is None:
            self.skipTest("ffmpeg not installed")
        sample = next((REPO / "game_assets").rglob("*.ogg"))
        asset_id = "0192f3a4-7c1e-7b2a-9d4e-5f6a7b8c9d11"
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self._hub(root)
            source = root / "game_assets" / "music" / "a.ogg"
            source.parent.mkdir(parents=True)
            source.write_bytes(sample.read_bytes())
            catalog = root / "asset_catalog"
            catalog.mkdir()
            (catalog / f"{asset_id}.json").write_text(
                json.dumps(_entry(asset_id, "music", "approved", ["music/a.ogg"])),
                encoding="utf-8",
            )
            self._write_manifest(root)
            write_runtime(root, json.loads(generate(root)))
            copy = root / "audio_runtime" / f"{asset_id}.ogg"
            self.assertIn(b"vorbis", copy.read_bytes()[:64])
            self.assertNotIn(b"OpusHead", copy.read_bytes()[:64])
            self.assertEqual(check(root), [])

    def _hub(self, root: Path) -> None:
        (root / "specs" / "assets").mkdir(parents=True)
        (root / "specs" / "assets" / "assets.md").write_text(
            (REPO / "specs" / "assets" / "assets.md").read_text(encoding="utf-8"),
            encoding="utf-8",
        )

    def _write_manifest(self, root: Path) -> None:
        manifest = root / "game" / "asset_manifest.json"
        manifest.parent.mkdir(parents=True, exist_ok=True)
        manifest.write_text(generate(root), encoding="utf-8")

    def _write_checksums(self, root: Path, asset_id: str, source: Path, runtime: Path) -> None:
        import hashlib

        def digest(path: Path) -> str:
            return hashlib.sha256(path.read_bytes()).hexdigest()

        payload = {asset_id: {"source_sha256": digest(source), "runtime_sha256": digest(runtime)}}
        (root / "audio_runtime" / "checksums.json").write_text(
            json.dumps(payload, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )

    def test_main_code_does_not_name_the_asset_root_path(self) -> None:
        offenders: list[str] = []
        for path in (REPO / "game").rglob("*"):
            if not path.is_file():
                continue
            if path.suffix == ".uid" or ".godot" in path.parts:
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            if "game_assets/" in text:
                offenders.append(path.relative_to(REPO).as_posix())
        self.assertEqual(offenders, [])


if __name__ == "__main__":
    unittest.main()
