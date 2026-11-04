#!/bin/sh
# #882 acceptance: build the probe export used to reach the Boot failure.
#
# The acceptance export (`Web Release` over `main_release.tscn`) loads Boot from
# the pack even with the served `game_assets/` tree gone, so it never reaches the
# failure. This script exports the same tree with one extra scene as the main
# scene: `probe882web.tscn`, a `Node` that resolves an 11-ID Boot group against a
# served tree whose asset files are absent and logs `Boot assets failed`. It
# touches `game/project.godot`, `game/export_presets.cfg` (a third, `Web Probe`
# preset) and the staged `game/game_assets/` copies only for the export and
# restores all three afterwards.
#
#     sh scripts/build-probe.sh   # writes build/probe882f and build/served-probe
set -eu

REPO="$(cd "$(dirname "$0")/../../../../../.." && pwd)"
cd "$REPO"

cp game/project.godot /tmp/probe882-project.godot
cp game/export_presets.cfg /tmp/probe882-presets.cfg

cat > game/probe882web.gd <<'EOF'
extends Node
## #882 acceptance probe. Not part of the build under test.

func _ready() -> void:
	print("PROBE web=%s release=%s" % [OS.has_feature("web"), OS.has_feature("release")])
	var resolver := AssetResolver.new()
	add_child(resolver)
	await get_tree().process_frame
	print("PROBE boot ids=", resolver._group_ids("boot").size())
	resolver.preload_boot()
	await resolver.boot_settled
	print("PROBE boot_outcome=", resolver.boot_outcome)
EOF

cat > game/probe882web.tscn <<'EOF'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://probe882web.gd" id="1"]

[node name="ProbeRoot" type="Node"]
script = ExtResource("1")
EOF

python3 - <<'PY'
import pathlib
p = pathlib.Path('game/export_presets.cfg')
t = p.read_text()
release_block = t[t.index('[preset.1]'):]
probe = release_block.replace('name="Web Release"', 'name="Web Probe"', 1)
probe = probe.replace('export_path="../build/web/index.html"', 'export_path="../build/probe882f/index.html"', 1)
probe = probe.replace('[preset.1]', '[preset.2]').replace('[preset.1.options]', '[preset.2.options]')
p.write_text(t + '\n' + probe)
PY

rm -rf build/probe882f && mkdir -p build/probe882f
python3 - <<'PY'
import pathlib, subprocess, sys
sys.path.insert(0, '.github/scripts')
import web_export
proj = pathlib.Path('game/project.godot')
original = proj.read_text()
try:
    proj.write_text(original.replace('run/main_scene="res://main.tscn"', 'run/main_scene="res://probe882web.tscn"'))
    web_export.prepare_asset_root(pathlib.Path('.').resolve(), pathlib.Path('build/probe882f').resolve())
    run = subprocess.run(
        ['godot', '--headless', '--path', 'game', '--export-release', 'Web Probe',
         str(pathlib.Path('build/probe882f/index.html').resolve())],
        check=False,
    )
    if run.returncode != 0:
        raise SystemExit(f'probe export failed: {run.returncode}')
finally:
    proj.write_text(original)
    web_export.discard_asset_root(pathlib.Path('.').resolve())
PY

cp /tmp/probe882-presets.cfg game/export_presets.cfg
rm -f game/probe882web.gd game/probe882web.gd.uid game/probe882web.tscn

rm -rf build/served-probe && cp -R build/probe882f build/served-probe
find build/served-probe/game_assets build/served-probe/audio_runtime -type f -delete
echo "probe export written to build/probe882f; served copy with no asset files at build/served-probe"
