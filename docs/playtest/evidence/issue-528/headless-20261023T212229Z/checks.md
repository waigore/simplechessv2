# Checks run — issue #528 headless run

| Check | Result | Log |
|-------|--------|-----|
| `godot --headless --path game --import --quit` | exit 0 | `logs/import.log`, `logs/import.status` |
| `python3 .github/scripts/gdscript_tests.py test` | 25 headless unit tests passed (run 4×) | `logs/unit-tests.log`, `logs/unit-tests.status` |
| `python3 .github/scripts/gdscript_tests.py coverage` | 85.8% (4466/5206), threshold 80 | `logs/coverage.log`, `logs/coverage.status` |
| `gdformat --check game` | 58 files unchanged | `logs/gdformat.log` |
| `gdlint game` | no problems | `logs/gdlint.log` |
| `python3 .github/scripts/spec_lint.py` | 0 errors, 1 pre-existing glossary warning | `logs/spec-lint.log` |
| Playtest smoke `godot --headless --path game` | exit 0, `TEL.5` pass rows | `logs/headless-smoke.log`, `logs/headless-smoke.status` |
| Acceptance drive (`logs/drive.gd`) | 93 checks pass, `ACCEPT DRIVE PASS`, exit 0 | `logs/drive-headless.log` |