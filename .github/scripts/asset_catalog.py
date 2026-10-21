#!/usr/bin/env python3
"""Check the asset catalog's entry files against specs/assets/catalog.md.

Default format: one JSON object per asset in `<catalog-root>/<asset-id>.json`,
with the keys in specs/assets/catalog/fields.md. The catalog root, asset root,
and kind spec names come from specs/assets/assets.md. While the catalog root is
unset, every check is skipped; while the asset root is unset, the file checks
are skipped. A project whose Integration ADR sets another format replaces this
script.

Checks (catalog integrity IDs): I1 files, I2 asset IDs, I3 approval,
I4 kind specs and successors, I6 exemptions, I7 handles, I8 banned tools (the
Banned tools table in docs/asset-tools.md), I9 empty coverage only for SS1
style anchors, I10 in-scope coverage against kind Coverage, Naming, and recipe
Outputs (specs/assets/catalog/integrity.md), I11 approved sound-effects and music
duration (specs/assets/catalog/audio-duration.md); plus required fields and value shapes.

Usage: asset_catalog.py [--root DIR]
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))

from new_asset_id import is_asset_id  # noqa: E402

HUB = "specs/assets/assets.md"
KINDS_DIR = "specs/assets/kinds"
TOOLS_DOC = "docs/asset-tools.md"
TOUCHUP_PARTS = ("operation", "tool", "terms", "date", "reason", "run_by")
GENERATION_PARTS = ("prompt", "tool", "operation", "settings", "inputs", "seed")
SERIES_ID_PART = "id"
SERIES_HARD_BINDINGS = ("recraft_style_id", "elevenlabs_finetune_id", "elevenlabs_voice_id")
SERIES_BINDING_SETTINGS = ("input_style_id", "finetune_id", "voice_id")
STATES = {"draft", "approved", "deprecated"}
SOURCE_TYPES = {"ai-generation", "procedural-generation", "third-party", "human-made"}
GENERATED = {"ai-generation", "procedural-generation"}
ALWAYS = ("id", "handle", "kind_spec", "serves", "state", "version", "files", "source_type", "license")
ENGINE_SIDECARS = (".meta", ".import", ".uid")
# Keep empty catalog/asset roots trackable in git before the first entry or file.
ROOT_PLACEHOLDERS = (".gitkeep",)
KEBAB = r"[a-z0-9]+(?:-[a-z0-9]+)*"
HANDLE_RE = re.compile(rf"^({KEBAB})/{KEBAB}$")
QUALIFIED_COVERAGE_RE = re.compile(rf"^AK-({KEBAB})\.(V\d+)$")
HANDLE_TOKEN_RE = re.compile(rf"`({KEBAB}/{KEBAB})`")
NAMING_EXCEPTION_DOCS = ("specs/assets/catalog.md", "specs/assets/catalog/integrity.md")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
COMMENT_RE = re.compile(r"<!--.*?-->", re.S)
CODE_RE = re.compile(r"`([^`]+)`")
KIND_LINK_RE = re.compile(rf"kinds/({KEBAB})\.md")
STYLE_ANCHORS_RE = re.compile(r"^\s*-\s+\*\*Style anchors\*\*:\s*(.*)$", re.M)
UUID7_RE = re.compile(
    r"\b([0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12})\b"
)
OPUS_RATE = 48000
OPUS_HEAD = b"OpusHead"
OGG_CAPTURE = b"OggS"
GRANULE_NONE = -1
DURATION_KINDS = ("sound-effects", "music")
_NUMBER = r"\d+(?:\.\d+)?"
_DASH = r"[\u2013\u2014-]"
DURATION_RANGE_RE = re.compile(rf"({_NUMBER})\s*{_DASH}\s*({_NUMBER})\s*s\b")
SFX_RANGE_RE = re.compile(rf"X(\d+)\s+({_NUMBER})\s*{_DASH}\s*({_NUMBER})\s*s\b")
SFX_COVERAGE_RE = re.compile(r"^AK-sound-effects\.V(\d+)$")


@dataclass(frozen=True)
class Finding:
    path: str
    check: str
    message: str

    def __str__(self) -> str:
        return f"{self.path} [{self.check}] {self.message}"


@dataclass(frozen=True)
class Hub:
    catalog_root: str | None
    asset_root: str | None
    kind_specs: frozenset[str]
    banned_tools: frozenset[str] = frozenset()
    style_anchors: frozenset[str] = frozenset()


def _bullet_path(text: str, label: str) -> str | None:
    m = re.search(rf"^\s*-\s+\*\*{re.escape(label)}\*\*:\s*(.*)$", text, re.M)
    code = CODE_RE.search(m.group(1)) if m and not m.group(1).startswith("TBD") else None
    return code.group(1).strip().strip("/") or None if code else None


def _kind_specs(text: str) -> frozenset[str]:
    section = re.search(r"^## Asset kinds\s*$(.*?)(?=^## )", text, re.M | re.S)
    names: set[str] = set()
    for line in (section.group(1) if section else "").splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if not line.lstrip().startswith("|") or len(cells) < 4:
            continue
        names.update(KIND_LINK_RE.findall(cells[-1]))
        names.update(t.strip() for t in CODE_RE.findall(cells[-1]) if re.fullmatch(KEBAB, t.strip()))
    return frozenset(names)


def _banned_tools(text: str) -> frozenset[str]:
    section = re.search(r"^## Banned tools\s*$(.*?)(?=^## |\Z)", text, re.M | re.S)
    rows = [line for line in (section.group(1) if section else "").splitlines() if line.lstrip().startswith("|")]
    names = (row.strip().strip("|").split("|")[0].strip().strip("`*").lower() for row in rows[2:])
    return frozenset(name for name in names if name)


def _style_anchor_ids(root: Path) -> frozenset[str]:
    kinds = root / KINDS_DIR
    if not kinds.is_dir():
        return frozenset()
    ids: set[str] = set()
    for path in kinds.rglob("*.md"):
        for match in STYLE_ANCHORS_RE.finditer(_read(path)):
            body = match.group(1).strip()
            if body.lower().startswith("none"):
                continue
            ids.update(UUID7_RE.findall(body))
    return frozenset(ids)


def _read(path: Path) -> str:
    return COMMENT_RE.sub("", path.read_text(encoding="utf-8")) if path.exists() else ""


def read_hub(root: Path) -> Hub:
    text = _read(root / HUB)
    banned = _banned_tools(_read(root / TOOLS_DOC))
    return Hub(
        _bullet_path(text, "Catalog root"),
        _bullet_path(text, "Asset root"),
        _kind_specs(text),
        banned,
        _style_anchor_ids(root),
    )


def _non_empty(entry: dict[str, Any], key: str) -> bool:
    return entry.get(key) not in (None, "", [], {})


def _parts(rel: str, entry: dict[str, Any], key: str, parts: tuple[str, ...], check: str) -> list[Finding]:
    value = entry.get(key)
    if not isinstance(value, dict):
        return [Finding(rel, check, f"'{key}' must be an object with {', '.join(parts)}")]
    missing = [p for p in parts if not _non_empty(value, p)]
    findings = [Finding(rel, check, f"'{key}' is missing {', '.join(missing)}")] if missing else []
    if "date" in parts and value.get("date") and not DATE_RE.match(str(value["date"])):
        findings.append(Finding(rel, check, f"'{key}.date' must be YYYY-MM-DD"))
    return findings


def check_entry(rel: str, stem: str, entry: dict[str, Any], hub: Hub) -> list[Finding]:
    findings = [Finding(rel, "fields", f"missing '{k}'") for k in ALWAYS if not _non_empty(entry, k)]
    findings += [Finding(rel, "fields", f"'{k}' is null") for k, v in entry.items() if v is None]
    asset_id, handle = entry.get("id"), entry.get("handle")
    if asset_id is not None and not (isinstance(asset_id, str) and is_asset_id(asset_id)):
        findings.append(Finding(rel, "I2", "'id' is not a lowercase UUID version 7"))
    elif asset_id is not None and asset_id != stem:
        findings.append(Finding(rel, "I2", "file name must be '<id>.json'"))
    if handle is not None:
        m = HANDLE_RE.match(handle) if isinstance(handle, str) else None
        if not m:
            findings.append(Finding(rel, "I7", "'handle' must be '<kind>/<name>' in kebab-case"))
        elif m.group(1) not in hub.kind_specs:
            findings.append(Finding(rel, "I7", f"handle prefix '{m.group(1)}' is not a kind spec named in {HUB}"))
        elif entry.get("kind_spec") != f"AK-{m.group(1)}":
            findings.append(Finding(rel, "I4", f"'kind_spec' must be 'AK-{m.group(1)}' to match the handle"))
    if entry.get("state") is not None and entry["state"] not in STATES:
        findings.append(Finding(rel, "fields", f"'state' must be one of {sorted(STATES)}"))
    version = entry.get("version")
    if version is not None and (type(version) is not int or version < 1):
        findings.append(Finding(rel, "fields", "'version' must be an integer from 1"))
    source = entry.get("source_type")
    if source is not None and source not in SOURCE_TYPES:
        findings.append(Finding(rel, "fields", f"'source_type' must be one of {sorted(SOURCE_TYPES)}"))
    files = entry.get("files")
    if files is not None and not (isinstance(files, list) and all(isinstance(f, str) and f and not f.startswith("/") and ".." not in Path(f).parts for f in files)):
        findings.append(Finding(rel, "fields", "'files' must list paths relative to the asset root"))
    person_supplied = _non_empty(entry, "supplier")
    if not person_supplied and not _non_empty(entry, "coverage"):
        if isinstance(asset_id, str) and asset_id in hub.style_anchors:
            pass  # I9: SS1 style anchors may carry empty production coverage
        elif entry.get("coverage") == []:
            findings.append(
                Finding(rel, "I9", "empty 'coverage' is only allowed for SS1 style anchors")
            )
        else:
            findings.append(Finding(rel, "fields", "missing 'coverage'"))
    if source in GENERATED:
        if not _non_empty(entry, "generation"):
            findings.append(Finding(rel, "fields", "generated asset is missing 'generation'"))
        elif not person_supplied:
            findings += _check_generation(rel, entry["generation"])
        if not person_supplied:
            findings += [Finding(rel, "fields", f"agent-generated asset is missing '{k}'") for k in ("tool_role", "recipe") if not _non_empty(entry, k)]
            if _non_empty(entry, "tool_role"):
                findings += _parts(rel, entry, "tool_role", ("role", "adr"), "fields")
    if _non_empty(entry, "exemption"):
        findings += _parts(rel, entry, "exemption", ("granted_by", "date", "reason"), "I6")
    if _non_empty(entry, "review"):
        findings += _parts(rel, entry, "review", ("verdict", "date", "reviewer", "report"), "fields")
    if entry.get("state") == "approved" and not _non_empty(entry, "exemption"):
        review = entry.get("review")
        if not (isinstance(review, dict) and review.get("verdict") == "Pass"):
            findings.append(Finding(rel, "I3", "approved entry needs a review with verdict 'Pass', or an exemption"))
    if entry.get("state") == "deprecated" and not _non_empty(entry, "deprecation_reason"):
        findings.append(Finding(rel, "fields", "deprecated entry is missing 'deprecation_reason'"))
    findings += _check_touchups(rel, entry, person_supplied)
    findings += _check_banned(rel, entry, hub.banned_tools)
    return findings


def _check_series(rel: str, series: Any) -> list[Finding]:
    if not isinstance(series, dict):
        return [Finding(rel, "fields", f"'series' must be an object with '{SERIES_ID_PART}' and a style binding")]
    findings: list[Finding] = []
    if not _non_empty(series, SERIES_ID_PART):
        findings.append(Finding(rel, "fields", f"'series' is missing {SERIES_ID_PART}"))
    hard = [k for k in SERIES_HARD_BINDINGS if _non_empty(series, k)]
    soft = series.get("soft_enforce") is True
    if soft and hard:
        findings.append(Finding(rel, "fields", "'series' cannot combine soft_enforce with a hard style binding"))
    elif soft:
        pass
    elif len(hard) == 1:
        pass
    elif len(hard) > 1:
        findings.append(Finding(rel, "fields", f"'series' must have exactly one of {', '.join(SERIES_HARD_BINDINGS)}"))
    else:
        findings.append(
            Finding(
                rel,
                "fields",
                f"'series' needs one of {', '.join(SERIES_HARD_BINDINGS)} or soft_enforce: true",
            )
        )
    return findings


def _check_generation(rel: str, generation: Any) -> list[Finding]:
    if not isinstance(generation, dict):
        return [Finding(rel, "fields", f"'generation' must be an object with {', '.join(GENERATION_PARTS)}")]
    findings = _parts(rel, {"generation": generation}, "generation", GENERATION_PARTS, "fields")
    settings = generation.get("settings")
    needs_series = _non_empty(generation, "series") or (
        isinstance(settings, dict) and any(_non_empty(settings, k) for k in SERIES_BINDING_SETTINGS)
    )
    if needs_series:
        findings += _check_series(rel, generation.get("series"))
    return findings


def _check_touchups(rel: str, entry: dict[str, Any], person_supplied: bool) -> list[Finding]:
    if "touchups" not in entry:
        return []
    touchups = entry["touchups"]
    if not (isinstance(touchups, list) and touchups):
        return [Finding(rel, "fields", "'touchups' must be a non-empty list")]
    parts = TOUCHUP_PARTS + (("agreed_by",) if person_supplied else ())
    findings: list[Finding] = []
    for i, touchup in enumerate(touchups):
        findings += _parts(rel, {f"touchups[{i}]": touchup}, f"touchups[{i}]", parts, "fields")
        if isinstance(touchup, dict) and str(touchup.get("run_by", "")).casefold() == "agent":
            findings += _parts(
                rel, {f"touchups[{i}]": touchup}, f"touchups[{i}]", ("prompt", "inputs"), "fields"
            )
    return findings


def _check_banned(rel: str, entry: dict[str, Any], banned: frozenset[str]) -> list[Finding]:
    generation, touchups = entry.get("generation"), entry.get("touchups")
    tools = [generation.get("tool")] if isinstance(generation, dict) else []
    tools += [t.get("tool") for t in touchups if isinstance(t, dict)] if isinstance(touchups, list) else []
    return [Finding(rel, "I8", f"tool '{tool}' is banned by {TOOLS_DOC}")
            for tool in tools if isinstance(tool, str) and any(name in tool.lower() for name in banned)]


@dataclass(frozen=True)
class _KindCoverage:
    rows: dict[str, int]
    templates: tuple[str, ...]
    patterns: tuple[re.Pattern[str], ...]
    paired: dict[str, str] | None
    outputs: str


def _section(text: str, heading: str) -> str:
    match = re.search(rf"^## {re.escape(heading)}\s*$(.*?)(?=^## |\Z)", text, re.M | re.S)
    return match.group(1) if match else ""


def _coverage_rows(text: str) -> dict[str, int]:
    rows: dict[str, int] = {}
    for line in text.splitlines():
        if not line.lstrip().startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 4 or not re.fullmatch(r"V\d+", cells[0]):
            continue
        numbers = [int(number) for number in re.findall(r"\d+", cells[-1])]
        if numbers:
            rows[cells[0]] = max(numbers)
    return rows


def _handle_templates(text: str) -> tuple[str, ...]:
    match = re.search(r"^\s*-\s+\*\*Handle name\*\*:\s*(.*)$", text, re.M)
    return tuple(re.findall(r"`([^`]+)`", match.group(1))) if match else ()


def _compile_template(template: str) -> re.Pattern[str]:
    template = template.replace("\\|", "|")
    parts: list[str] = []
    index = 0
    while index < len(template):
        if template[index] != "<":
            nxt = template.find("<", index)
            chunk = template[index:] if nxt < 0 else template[index:nxt]
            parts.append(re.escape(chunk))
            if nxt < 0:
                break
            index = nxt
            continue
        end = template.find(">", index)
        if end < 0:
            parts.append(re.escape(template[index:]))
            break
        inner = template[index + 1:end]
        if "|" in inner:
            parts.append("(?:%s)" % "|".join(re.escape(piece) for piece in inner.split("|")))
        else:
            parts.append(KEBAB)
        index = end + 1
    return re.compile("^" + "".join(parts) + "$")


def _collect_outputs(root: Path, kind: str, main: str) -> str:
    texts = [main]
    sub = root / KINDS_DIR / kind
    if sub.is_dir():
        texts.extend(_read(path) for path in sorted(sub.glob("*.md")))
    lines: list[str] = []
    for text in texts:
        for match in re.finditer(r"^\s*-\s+\*\*Outputs\*\*:\s*(.*)$", text, re.M):
            line = match.group(1).strip()
            if not line.lower().startswith("n/a"):
                lines.append(line)
    return " ".join(lines)


def _load_kind(root: Path, kind: str) -> _KindCoverage | None:
    main = _read(root / KINDS_DIR / f"{kind}.md")
    rows = _coverage_rows(_section(main, "Coverage"))
    if not rows:
        return None
    templates = _handle_templates(_section(main, "Naming"))
    paired = None
    if templates and all("<" not in template for template in templates) and len(templates) == len(rows):
        paired = dict(zip(rows, templates))
    return _KindCoverage(
        rows,
        templates,
        tuple(_compile_template(template) for template in templates),
        paired,
        _collect_outputs(root, kind, main),
    )


def _naming_exceptions(root: Path) -> frozenset[str]:
    found: set[str] = set()
    for rel in NAMING_EXCEPTION_DOCS:
        text = _read(root / rel)
        blobs = [match.group(1) for match in re.finditer(r"(?ms)^### CAT\.I10\s*$(.*?)(?=^#{1,3} |\Z)", text)]
        blobs.extend(line for line in text.splitlines() if "CAT.I10" in line or re.search(r"\|\s*`I10`\s*\|", line))
        for blob in blobs:
            found.update(HANDLE_TOKEN_RE.findall(blob))
    return frozenset(found)


def _entry_kind(entry: dict[str, Any]) -> str:
    handle = entry.get("handle")
    if isinstance(handle, str) and "/" in handle:
        return handle.split("/", 1)[0]
    kind_spec = entry.get("kind_spec")
    if isinstance(kind_spec, str) and kind_spec.startswith("AK-"):
        return kind_spec[3:]
    return ""


def _coverage_in_scope(entry: dict[str, Any]) -> bool:
    coverage = entry.get("coverage")
    return entry.get("state") in ("draft", "approved") and isinstance(coverage, list) and len(coverage) > 0


def _file_rule(outputs: str) -> tuple[str, tuple[str, ...]]:
    lowered = outputs.lower()
    if "one file per coverage row" in lowered or "one file per v row" in lowered:
        return "one-row", ()
    if "one v1 file" in lowered:
        return "v1-only", ()
    vids: list[str] = []
    for number in re.findall(r"\bV(\d+)\b", outputs):
        vid = f"V{number}"
        if vid not in vids:
            vids.append(vid)
    if len(vids) >= 2:
        return "one-of", tuple(vids)
    return "open", ()


def _cited_ids(rel: str, entry: dict[str, Any], kind: str, rules: _KindCoverage, findings: list[Finding]) -> list[str]:
    ok: list[str] = []
    for item in entry.get("coverage", []):
        match = QUALIFIED_COVERAGE_RE.fullmatch(item) if isinstance(item, str) else None
        if match is None:
            shown = item if isinstance(item, str) else type(item).__name__
            findings.append(Finding(rel, "I10", f"'{shown}' is not a qualified coverage ID 'AK-<kind>.V<n>'"))
            continue
        if match.group(1) != kind or match.group(2) not in rules.rows:
            findings.append(Finding(rel, "I10", f"'{item}' is not a Coverage row of {kind}"))
            continue
        ok.append(item)
    return ok


def _check_handle(
    rel: str,
    entry: dict[str, Any],
    rules: _KindCoverage,
    cited: list[str],
    exceptions: frozenset[str],
    findings: list[Finding],
) -> None:
    handle = entry.get("handle")
    if not isinstance(handle, str) or not cited or handle in exceptions:
        return
    if rules.paired is not None:
        vids = []
        for qid in dict.fromkeys(cited):
            match = QUALIFIED_COVERAGE_RE.fullmatch(qid)
            if match is not None:
                vids.append(match.group(2))
        expected = {rules.paired[vid] for vid in vids if vid in rules.paired}
        if handle not in expected:
            findings.append(Finding(rel, "I10", f"handle '{handle}' does not match Naming for {', '.join(dict.fromkeys(cited))}"))
        return
    if any(pattern.fullmatch(handle) for pattern in rules.patterns):
        return
    shown = ", ".join(rules.templates) or "(none)"
    findings.append(Finding(rel, "I10", f"handle '{handle}' does not match Naming {shown}"))


def _check_files(rel: str, entry: dict[str, Any], kind: str, rules: _KindCoverage, cited: list[str], findings: list[Finding]) -> None:
    if not cited:
        return
    mode, vids = _file_rule(rules.outputs)
    unique = list(dict.fromkeys(cited))
    files = entry.get("files")
    if mode in ("one-row", "v1-only"):
        if isinstance(files, list) and len(files) != 1:
            findings.append(Finding(rel, "I10", "files must have one path when Outputs say one file per coverage row or one V1 file"))
        if mode == "one-row" and len(unique) != 1:
            findings.append(Finding(rel, "I10", "one file carries one Coverage row; this entry lists more"))
        elif mode == "v1-only" and unique != [f"AK-{kind}.V1"]:
            findings.append(Finding(rel, "I10", f"one V1 file carries only 'AK-{kind}.V1'"))
    elif mode == "one-of":
        allowed = [f"AK-{kind}.{vid}" for vid in vids]
        if len(unique) != 1 or unique[0] not in allowed:
            findings.append(Finding(rel, "I10", f"Outputs name {', '.join(allowed)} for the kind; one entry lists one of them"))


def check_coverage_integrity(root: Path, entries: dict[str, dict[str, Any]]) -> list[Finding]:
    """CAT.I10: in-scope coverage must match kind Coverage, Naming, and Outputs."""
    exceptions = _naming_exceptions(root)
    cache: dict[str, _KindCoverage | None] = {}

    def kind_rules(kind: str) -> _KindCoverage | None:
        if kind not in cache:
            cache[kind] = _load_kind(root, kind) if kind else None
        return cache[kind]

    findings: list[Finding] = []
    claims: dict[str, list[str]] = {}
    for rel, entry in entries.items():
        if not _coverage_in_scope(entry):
            continue
        kind = _entry_kind(entry)
        rules = kind_rules(kind)
        if rules is None:
            findings.append(Finding(rel, "I10", f"kind '{kind}' has no Coverage rows"))
            continue
        cited = _cited_ids(rel, entry, kind, rules, findings)
        _check_handle(rel, entry, rules, cited, exceptions, findings)
        _check_files(rel, entry, kind, rules, cited, findings)
        for qid in dict.fromkeys(cited):
            claims.setdefault(qid, []).append(rel)
    for qid, rels in claims.items():
        match = QUALIFIED_COVERAGE_RE.fullmatch(qid)
        rules = kind_rules(match.group(1)) if match else None
        if match is None or rules is None:
            continue
        cap = rules.rows[match.group(2)]
        if len(rels) > cap:
            findings.append(Finding(rels[0], "I10", f"'{qid}' is claimed by {len(rels)} entries; maximum is {cap}"))
    return findings


@dataclass(frozen=True)
class _DurationBand:
    low_samples: int
    high_samples: int
    low_text: str
    high_text: str
    label: str


def _samples(text: str) -> int:
    return int((Decimal(text) * Decimal(OPUS_RATE)).to_integral_value(rounding=ROUND_HALF_UP))


def _format_seconds(samples: int) -> str:
    text = format(Decimal(samples) / Decimal(OPUS_RATE), "f")
    return text.rstrip("0").rstrip(".") if "." in text else text


def _table_row(section: str, row_id: str) -> str:
    for line in section.splitlines():
        if not line.lstrip().startswith("|"):
            continue
        cells = [cell.strip().strip("`") for cell in line.strip().strip("|").split("|")]
        if cells and cells[0] == row_id:
            return line
    return ""


def _band(low: str, high: str, label: str) -> _DurationBand | None:
    low_samples, high_samples = _samples(low), _samples(high)
    if low_samples > high_samples:
        return None
    return _DurationBand(low_samples, high_samples, low, high, label)


def _parse_sfx_bands(text: str) -> dict[str, _DurationBand]:
    bands: dict[str, _DurationBand] = {}
    bad: set[str] = set()
    for number, low, high in SFX_RANGE_RE.findall(_table_row(_section(text, "Specification"), "S1")):
        label = f"X{number}"
        if label in bands or label in bad:
            bad.add(label)
            bands.pop(label, None)
            continue
        parsed = _band(low, high, label)
        if parsed is not None:
            bands[label] = parsed
    return bands


def _parse_music_band(text: str) -> _DurationBand | None:
    spec = DURATION_RANGE_RE.findall(_table_row(_section(text, "Specification"), "S4"))
    check = DURATION_RANGE_RE.findall(_table_row(_section(text, "Checks"), "K3"))
    if len(spec) != 1 or len(check) != 1:
        return None
    if (_samples(spec[0][0]), _samples(spec[0][1])) != (_samples(check[0][0]), _samples(check[0][1])):
        return None
    return _band(spec[0][0], spec[0][1], "S4/K3")


def _ogg_pages(data: bytes) -> list[tuple[int, bytes]] | None:
    pages: list[tuple[int, bytes]] = []
    index, size = 0, len(data)
    while index < size:
        if size - index < 27 or data[index:index + 4] != OGG_CAPTURE:
            return None
        granule = int.from_bytes(data[index + 6:index + 14], "little", signed=True)
        segments = data[index + 26]
        table = index + 27
        if size < table + segments:
            return None
        body = sum(data[table:table + segments])
        start = table + segments
        end = start + body
        if size < end:
            return None
        pages.append((granule, data[start:end]))
        index = end
    return pages


def _measure_opus(data: bytes) -> tuple[int | None, str]:
    """Return pre-skip-corrected 48 kHz samples, or (None, reason)."""
    if not data.startswith(OGG_CAPTURE):
        return None, "non-ogg"
    pages = _ogg_pages(data)
    if not pages:
        return None, "unreadable"
    head = pages[0][1]
    if not head.startswith(OPUS_HEAD) or len(head) < 12:
        return None, "non-opus"
    pre_skip = int.from_bytes(head[10:12], "little")
    last = next((granule for granule, _payload in reversed(pages) if granule != GRANULE_NONE), None)
    if last is None or last < pre_skip:
        return None, "unreadable"
    return last - pre_skip, ""


def _sfx_band(entry: dict[str, Any], bands: dict[str, _DurationBand]) -> _DurationBand | None:
    coverage = entry.get("coverage")
    if not isinstance(coverage, list) or not coverage:
        return None
    labels: list[str] = []
    for item in coverage:
        match = SFX_COVERAGE_RE.fullmatch(item) if isinstance(item, str) else None
        if match is None:
            return None
        labels.append(f"X{match.group(1)}")
    unique = list(dict.fromkeys(labels))
    if len(unique) != 1 or unique[0] not in bands:
        return None
    return bands[unique[0]]


def _duration_files(rel: str, entry: dict[str, Any], asset_root: Path, band: _DurationBand) -> list[Finding]:
    files = entry.get("files")
    if not isinstance(files, list) or not files:
        return [Finding(rel, "I11", "no audio file to measure")]
    findings: list[Finding] = []
    for rel_file in files:
        shown = rel_file if isinstance(rel_file, str) else type(rel_file).__name__
        path = asset_root / rel_file if isinstance(rel_file, str) else None
        if path is None or not path.is_file():
            findings.append(Finding(rel, "I11", f"'{shown}' is unreadable"))
            continue
        try:
            samples, reason = _measure_opus(path.read_bytes())
        except OSError:
            findings.append(Finding(rel, "I11", f"'{shown}' is unreadable"))
            continue
        if samples is None:
            message = {"non-ogg": "is not an OGG file", "non-opus": "is Ogg but not Opus"}.get(reason, "is unreadable")
            findings.append(Finding(rel, "I11", f"'{shown}' {message}"))
            continue
        if band.low_samples <= samples <= band.high_samples:
            continue
        findings.append(Finding(
            rel,
            "I11",
            f"'{shown}' measures {_format_seconds(samples)} s, outside {band.label} {band.low_text}–{band.high_text} s",
        ))
    return findings


def check_audio_duration(root: Path, hub: Hub, entries: dict[str, dict[str, Any]]) -> list[Finding]:
    """CAT.I11: approved sound-effects and music durations, read from the kind specs."""
    if not hub.asset_root:
        return []
    asset_root = root / hub.asset_root
    if not asset_root.is_dir():
        return []
    sfx_bands = _parse_sfx_bands(_read(root / KINDS_DIR / "sound-effects.md"))
    music_band = _parse_music_band(_read(root / KINDS_DIR / "music.md"))
    findings: list[Finding] = []
    for rel, entry in entries.items():
        if entry.get("state") != "approved":
            continue
        kind = _entry_kind(entry)
        if kind not in DURATION_KINDS:
            continue
        if kind == "sound-effects":
            if not sfx_bands:
                findings.append(Finding(rel, "I11", "kind spec S1 does not state Xn duration ranges"))
                continue
            band = _sfx_band(entry, sfx_bands)
            if band is None:
                findings.append(Finding(rel, "I11", "coverage does not resolve to exactly one Xn range in S1"))
                continue
        else:
            if music_band is None:
                findings.append(Finding(rel, "I11", "kind spec S4 and K3 do not state one inclusive duration band"))
                continue
            band = music_band
        findings += _duration_files(rel, entry, asset_root, band)
    return findings


def check_catalog(entries: dict[str, dict[str, Any]]) -> list[Finding]:
    findings: list[Finding] = []
    ids = {e.get("id") for e in entries.values()}
    seen: dict[str, str] = {}
    for rel, entry in entries.items():
        handle = entry.get("handle")
        if isinstance(handle, str):
            if handle in seen:
                findings.append(Finding(rel, "I7", f"handle '{handle}' is also used by {seen[handle]}"))
            seen.setdefault(handle, rel)
        successor = entry.get("successor")
        if successor is not None and (successor == entry.get("id") or successor not in ids):
            findings.append(Finding(rel, "I4", f"successor '{successor}' is not another cataloged asset"))
    return findings


def check_files(root: Path, hub: Hub, entries: dict[str, dict[str, Any]]) -> list[Finding]:
    asset_root = root / hub.asset_root
    if not asset_root.is_dir():
        return [Finding(hub.asset_root, "I1", "asset root does not exist")]
    findings: list[Finding] = []
    owner: dict[str, str] = {}
    for rel, entry in entries.items():
        files = entry.get("files")
        for f in files if isinstance(files, list) else []:
            if not isinstance(f, str):
                continue
            if not (asset_root / f).is_file():
                findings.append(Finding(rel, "I1", f"file '{f}' does not exist under {hub.asset_root}"))
            if f in owner:
                findings.append(Finding(rel, "I1", f"file '{f}' also belongs to {owner[f]}"))
            owner.setdefault(f, rel)
    catalog_root = (root / hub.catalog_root).resolve()
    for path in sorted(p for p in asset_root.rglob("*") if p.is_file()):
        if (
            path.suffix in ENGINE_SIDECARS
            or path.name in ROOT_PLACEHOLDERS
            or catalog_root in path.resolve().parents
        ):
            continue
        f = path.relative_to(asset_root).as_posix()
        if f not in owner:
            findings.append(Finding(f"{hub.asset_root}/{f}", "I1", "file belongs to no catalog entry"))
    return findings


def check(root: Path) -> tuple[list[Finding], list[str]]:
    hub = read_hub(root)
    if hub.catalog_root is None:
        return [], [f"catalog root not set in {HUB}; catalog checks skipped"]
    catalog = root / hub.catalog_root
    if not catalog.is_dir():
        return [Finding(hub.catalog_root, "catalog", "catalog root does not exist")], []
    findings: list[Finding] = []
    entries: dict[str, dict[str, Any]] = {}
    for path in sorted(p for p in catalog.iterdir() if p.is_file()):
        rel = path.relative_to(root).as_posix()
        if path.suffix in ENGINE_SIDECARS or path.name in ROOT_PLACEHOLDERS:
            continue
        if path.suffix != ".json":
            findings.append(Finding(rel, "catalog", "only entry files ('<id>.json') may live in the catalog root"))
            continue
        try:
            entry = json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError) as exc:
            findings.append(Finding(rel, "catalog", f"not valid UTF-8 JSON: {exc}"))
            continue
        if not isinstance(entry, dict):
            findings.append(Finding(rel, "catalog", "entry file must hold one JSON object"))
            continue
        findings += check_entry(rel, path.stem, entry, hub)
        entries[rel] = entry
    findings += check_catalog(entries)
    findings += check_coverage_integrity(root, entries)
    notes: list[str] = []
    if hub.asset_root is None:
        notes.append(f"asset root not set in {HUB}; file checks skipped")
    else:
        findings += check_files(root, hub, entries)
        findings += check_audio_duration(root, hub, entries)
    return findings, notes


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2], help="repository root")
    findings, notes = check(parser.parse_args().root)
    for note in notes:
        print(f"NOTE: {note}")
    for finding in findings:
        print(f"ERROR: {finding}")
    print(f"Asset catalog: {len(findings)} error(s).")
    sys.exit(1 if findings else 0)


if __name__ == "__main__":
    main()
