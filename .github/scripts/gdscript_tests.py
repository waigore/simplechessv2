#!/usr/bin/env python3
"""Headless GDScript unit tests and statement-line coverage for game/.

No game/**/*_test.gd: exit 0 and do not invoke Godot.
When those scripts exist, `test` runs Godot 4.7.2 --headless and fails if a
test fails. `coverage` runs the same tests and fails when main-code
statement-line coverage is under 80.

Main code is game/**/*.gd excluding *_test.gd, addons/, and .godot/.
Class-body declarations are not statement lines. A body statement on the
same line as the declaration that opens that body is not a statement line
either (a class-level inline lambda). Not the playtest ENV.1 smoke.
"""
from __future__ import annotations

import argparse
import hashlib
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
import zipfile
from pathlib import Path
from typing import Callable, Iterable

THRESHOLD = 80
GODOT_VERSION = "4.7.2"
GODOT_ZIP = "Godot_v4.7.2-stable_linux.x86_64.zip"
GODOT_URL = (
    "https://github.com/godotengine/godot/releases/download/"
    "4.7.2-stable/" + GODOT_ZIP
)
GODOT_SHA512 = (
    "9aa00f7a605200940bce3027a567b782f49bd8e940dd06ae9e987bd65aee1b14"
    "67edd56ed84fcdcbdd44354bf613bdbb4e5d2913e925850368e150c59ed54c65"
)
GODOT_BIN_NAME = "Godot_v4.7.2-stable_linux.x86_64"
HELPER_NAME = "_ci_line_cov.gd"
SKIP_LINES = {
    "test": (
        "No unit-test scripts under game/. Exit 0. Godot is not invoked. "
        "When *_test.gd scripts exist, this command runs Godot 4.7.2 "
        "--headless and fails if a test fails."
    ),
    "coverage": (
        "No unit-test scripts under game/. Exit 0. Godot is not invoked. "
        "When *_test.gd scripts exist, this command runs Godot 4.7.2 "
        "--headless and fails when main-code statement-line coverage is under 80."
    ),
}
COVERABLE = {
    "pass_stmt",
    "return_stmt",
    "break_stmt",
    "breakpoint_stmt",
    "continue_stmt",
    "expr_stmt",
    "const_stmt",
    "const_assigned",
    "const_typed_assigned",
    "const_inf",
    "func_var_empty",
    "func_var_assigned",
    "func_var_typed",
    "func_var_typed_assgnd",
    "func_var_inf",
    "if_branch",
    "elif_branch",
    "while_stmt",
    "for_stmt",
    "for_stmt_typed",
    "match_stmt",
}
# Children of these nodes are function-body statements. Class-body const and
# var stay outside so a coverage probe is never inserted at class scope.
BODY_ROOTS = frozenset({
    "func_def",
    "lambda",
    "property_custom_getter",
    "property_custom_setter",
})
HELPER_GD = """extends RefCounted

static func hit(path: String, line: int) -> void:
	var out := OS.get_environment("CI_COV_OUT")
	if out.is_empty():
		return
	var mode := FileAccess.WRITE
	if FileAccess.file_exists(out):
		mode = FileAccess.READ_WRITE
	var handle := FileAccess.open(out, mode)
	if handle == null:
		push_error("coverage file did not open")
		return
	handle.seek_end()
	handle.store_line("%s:%d" % [path, line])
	handle.close()
"""

Runner = Callable[[list[str], dict[str, str]], subprocess.CompletedProcess[str]]


class CiError(Exception):
    """Setup or measurement failed before a test result exists."""


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def default_game() -> Path:
    return repo_root() / "game"


def _ignored(path: Path) -> bool:
    return bool({".godot", "addons"} & set(path.parts))


def find_scripts(game: Path, *, tests: bool) -> list[Path]:
    if not game.is_dir():
        return []
    found: list[Path] = []
    for path in game.rglob("*.gd"):
        if _ignored(path):
            continue
        if path.name.endswith("_test.gd") == tests:
            found.append(path)
    return sorted(found)


def rel_game(game: Path, path: Path) -> str:
    return path.relative_to(game).as_posix()


_PARSER = None


def _parser():
    global _PARSER
    if _PARSER is None:
        try:
            from gdtoolkit.parser.parser import Parser
        except ImportError as exc:
            raise CiError(
                "gdtoolkit==4.5.0 is required to measure coverage once *_test.gd exists"
            ) from exc
        _PARSER = Parser()
    return _PARSER


def statement_lines(source: str) -> set[int]:
    """Statement lines inside functions, lambdas, getters, and setters.

    A class-body ``const`` shares the ``const_stmt`` node with a local const.
    Only the local one is executable. A statement on the same line as the
    declaration that opens its body is also skipped: ``var f := func(): return 1``
    keeps the ``return`` on the class-level line, and a probe at that indent is
    not valid GDScript. A body statement on a later line still counts.
    """
    tree = _parser().parse(source, gather_metadata=True)
    found: set[int] = set()

    def walk(node: object, in_body: bool, body_line: int | None) -> None:
        data = getattr(node, "data", None)
        if data == "class_def":
            in_body = False
            body_line = None
        line = getattr(getattr(node, "meta", None), "line", None)
        if (
            in_body
            and data in COVERABLE
            and isinstance(line, int)
            and line != body_line
        ):
            found.add(line)
        if data in BODY_ROOTS:
            child_body = True
            child_line = line if isinstance(line, int) else body_line
        else:
            child_body = in_body
            child_line = body_line
        for child in getattr(node, "children", ()):
            walk(child, child_body, child_line)

    walk(tree, False, None)
    return found


def _indent_of(line: str) -> str:
    match = re.match(r"[ \t]*", line)
    return match.group(0) if match else ""


def _probe(indent: str, rel: str, line_no: int) -> str:
    return f'{indent}_CiLineCov.hit("{rel}", {line_no})'


def _is_elif(line: str) -> bool:
    return line.lstrip().startswith("elif")


def _split_inline_suite(body: list[str], idx: int) -> None:
    """Move `elif cond: stmt` onto the next line so a probe can sit in the suite."""
    header, colon, tail = body[idx].rstrip().rpartition(":")
    if colon and tail.strip():
        body[idx] = header + ":"
        body.insert(idx + 1, _indent_of(body[idx]) + "\t" + tail.strip())


def _elif_insert_at(body: list[str], header_idx: int) -> tuple[int, str]:
    _split_inline_suite(body, header_idx)
    idx = header_idx
    while idx < len(body) and not body[idx].rstrip().endswith(":"):
        idx += 1
    insert_at = idx + 1
    header_indent = _indent_of(body[header_idx])
    if insert_at < len(body):
        indent = _indent_of(body[insert_at])
        if len(indent) > len(header_indent):
            return insert_at, indent
    return insert_at, header_indent + "\t"


def instrument(source: str, rel: str, lines: Iterable[int]) -> str:
    body = source.splitlines()
    escaped = rel.replace("\\", "\\\\").replace('"', '\\"')
    for line_no in sorted(set(lines), reverse=True):
        idx = line_no - 1
        if idx < 0 or idx >= len(body):
            raise CiError(f"{rel}: statement line {line_no} is outside the file")
        # A call between `if` and `elif` is a parse error. Record the elif line
        # from the first statement of its suite instead.
        if _is_elif(body[idx]):
            insert_at, indent = _elif_insert_at(body, idx)
            body.insert(insert_at, _probe(indent, escaped, line_no))
        else:
            body.insert(idx, _probe(_indent_of(body[idx]), escaped, line_no))
    body.append('const _CiLineCov = preload("res://_ci_line_cov.gd")')
    return "\n".join(body) + "\n"


def coverage_percent(
    coverable: set[tuple[str, int]], hits: set[tuple[str, int]]
) -> float:
    if not coverable:
        return 100.0
    return 100.0 * len(coverable & hits) / len(coverable)


def read_hits(path: Path) -> set[tuple[str, int]]:
    if not path.is_file():
        return set()
    hits: set[tuple[str, int]] = set()
    for raw in path.read_text(encoding="utf-8").splitlines():
        rel, sep, num = raw.rpartition(":")
        if sep and num.isdigit() and rel:
            hits.add((rel, int(num)))
    return hits


def default_runner(cmd: list[str], env: dict[str, str]) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            cmd,
            env=env,
            text=True,
            capture_output=True,
            timeout=180,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        stdout = exc.stdout or ""
        stderr = exc.stderr or ""
        if isinstance(stdout, bytes):
            stdout = stdout.decode()
        if isinstance(stderr, bytes):
            stderr = stderr.decode()
        return subprocess.CompletedProcess(cmd, 124, stdout, stderr + "\nGodot timed out")


def _output(proc: subprocess.CompletedProcess[str]) -> str:
    return f"{proc.stdout or ''}{proc.stderr or ''}"


def _failed(proc: subprocess.CompletedProcess[str]) -> bool:
    text = _output(proc)
    if proc.returncode != 0:
        return True
    return "SCRIPT ERROR" in text or "Parse Error" in text


def ensure_godot() -> Path:
    override = os.environ.get("GODOT_BIN", "").strip()
    if override:
        path = Path(override)
        if not path.is_file():
            raise CiError(f"GODOT_BIN is not a file: {path}")
        return path
    if platform.system() != "Linux" or platform.machine() not in {"x86_64", "AMD64"}:
        raise CiError("Set GODOT_BIN to a Godot 4.7.2 binary (auto-download is linux x86_64 only).")
    cache_root = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    cache = cache_root / "simplechess-godot" / GODOT_VERSION
    binary = cache / GODOT_BIN_NAME
    if binary.is_file():
        return binary
    cache.mkdir(parents=True, exist_ok=True)
    zip_path = cache / GODOT_ZIP
    urllib.request.urlretrieve(GODOT_URL, zip_path)
    digest = hashlib.sha512(zip_path.read_bytes()).hexdigest()
    if digest != GODOT_SHA512:
        zip_path.unlink(missing_ok=True)
        raise CiError("Godot 4.7.2 zip checksum mismatch; download removed.")
    with zipfile.ZipFile(zip_path) as archive:
        archive.extract(GODOT_BIN_NAME, cache)
    binary.chmod(0o755)
    return binary


def _version_ok(runner: Runner, binary: Path) -> bool:
    proc = runner([str(binary), "--version"], os.environ.copy())
    text = _output(proc)
    if GODOT_VERSION not in text:
        print(f"Godot binary is not {GODOT_VERSION}: {text.strip()}", file=sys.stderr)
        return False
    return True


def _run_one(
    runner: Runner,
    binary: Path,
    project: Path,
    res: str,
    env: dict[str, str],
) -> int:
    cmd = [str(binary), "--headless", "--path", str(project), "-s", res]
    proc = runner(cmd, env)
    if _failed(proc):
        sys.stderr.write(_output(proc))
        print(f"Fail: {res}", file=sys.stderr)
        return 1
    return 0


def _require_project(game: Path) -> int | None:
    if (game / "project.godot").is_file():
        return None
    print(
        "unit-test scripts exist but game/project.godot is missing; "
        "the headless runner cannot start.",
        file=sys.stderr,
    )
    return 1


def run_command(
    command: str,
    game: Path,
    *,
    godot_bin: Path | None = None,
    runner: Runner | None = None,
    check_version: bool = True,
) -> int:
    if command not in SKIP_LINES:
        raise CiError(f"unknown command {command}")
    tests = find_scripts(game, tests=True)
    if not tests:
        print(SKIP_LINES[command])
        return 0
    missing = _require_project(game)
    if missing is not None:
        return missing
    binary = godot_bin if godot_bin is not None else ensure_godot()
    run = runner or default_runner
    if check_version and not _version_ok(run, binary):
        return 1
    if command == "test":
        return _run_suite(run, binary, game, tests, os.environ.copy())
    return _run_coverage(run, binary, game, tests)


def _run_suite(
    runner: Runner,
    binary: Path,
    project: Path,
    tests: list[Path],
    env: dict[str, str],
) -> int:
    failed = 0
    for path in tests:
        res = "res://" + rel_game(project, path)
        failed |= _run_one(runner, binary, project, res, env)
    if failed:
        return 1
    print(f"{len(tests)} headless unit test(s) passed")
    return 0


def _coverable_map(game: Path, scripts: list[Path]) -> set[tuple[str, int]]:
    coverable: set[tuple[str, int]] = set()
    for path in scripts:
        rel = rel_game(game, path)
        try:
            lines = statement_lines(path.read_text(encoding="utf-8"))
        except CiError:
            raise
        except Exception as exc:
            raise CiError(f"cannot parse {rel}: {exc}") from exc
        coverable.update((rel, line) for line in lines)
    return coverable


def _prepare_coverage_project(
    game: Path, main_scripts: list[Path], lines_by_rel: dict[str, set[int]]
) -> Path:
    if any(path.name == HELPER_NAME for path in main_scripts):
        raise CiError(f"game/ must not contain {HELPER_NAME}; it is reserved for the coverage run")
    temp = Path(tempfile.mkdtemp(prefix="gdscript-cov-"))
    project = temp / "proj"
    shutil.copytree(game, project, ignore=shutil.ignore_patterns(".godot"))
    for path in main_scripts:
        rel = rel_game(game, path)
        target = project / rel
        target.write_text(
            instrument(path.read_text(encoding="utf-8"), rel, lines_by_rel.get(rel, ())),
            encoding="utf-8",
        )
    (project / HELPER_NAME).write_text(HELPER_GD, encoding="utf-8")
    return project


def _run_coverage(
    runner: Runner,
    binary: Path,
    game: Path,
    tests: list[Path],
) -> int:
    main_scripts = find_scripts(game, tests=False)
    coverable = _coverable_map(game, main_scripts)
    lines_by_rel: dict[str, set[int]] = {}
    for rel, line in coverable:
        lines_by_rel.setdefault(rel, set()).add(line)
    project = _prepare_coverage_project(game, main_scripts, lines_by_rel)
    try:
        hits_path = project.parent / "hits.txt"
        env = os.environ.copy()
        env["CI_COV_OUT"] = str(hits_path)
        # Tests were discovered under game/; run the copies in the temp project.
        copied = [project / rel_game(game, path) for path in tests]
        if _run_suite(runner, binary, project, copied, env) != 0:
            return 1
        hits = read_hits(hits_path)
        percent = coverage_percent(coverable, hits)
        covered = len(coverable & hits) if coverable else 0
        print(
            f"statement-line coverage {percent:.1f}% ({covered}/{len(coverable)}); threshold {THRESHOLD}"
        )
        if percent + 1e-9 < THRESHOLD:
            missing = sorted(coverable - hits)
            for rel, line in missing[:40]:
                print(f"uncovered {rel}:{line}", file=sys.stderr)
            print(
                f"Coverage {percent:.1f}% is under {THRESHOLD}",
                file=sys.stderr,
            )
            return 1
        return 0
    finally:
        shutil.rmtree(project.parent, ignore_errors=True)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=tuple(SKIP_LINES))
    parser.add_argument("--game", type=Path, default=None)
    args = parser.parse_args(argv)
    game = args.game if args.game is not None else default_game()
    try:
        return run_command(args.command, game)
    except CiError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
