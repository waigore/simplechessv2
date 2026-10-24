class_name DemoAssetLoader
extends RefCounted
## Loads cataloged approved assets by asset ID from the catalog's asset root
## (`game_assets/`, ADR-0005). Mirrors the runtime-load approach of the main
## game's CMP-asset-resolver but lives entirely inside the demo.

const MANIFEST_PATH := "res://assets.json"
const AUDIO_RUNTIME := "audio_runtime"


var manifest: Dictionary = {}
var assets_root := ""
var audio_runtime := ""
var cache: Dictionary = {}
var problems: PackedStringArray = PackedStringArray()


func _init() -> void:
	_read_manifest()
	var project := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var repo_root := project.get_base_dir().get_base_dir()
	assets_root = repo_root.path_join(str(manifest.get("asset_root", "game_assets")))
	audio_runtime = repo_root.path_join(AUDIO_RUNTIME)


func _read_manifest() -> void:
	var text := FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		manifest = parsed
	else:
		problems.append("demo asset manifest is not an object")


func resolve(asset_id: String) -> Resource:
	# Assets referenced only by ID; approval state is checked before load.
	if cache.has(asset_id):
		return cache[asset_id]
	var entry: Dictionary = manifest.get("assets", {}).get(asset_id, {})
	if entry.is_empty():
		problems.append("unknown asset ID %s" % _short(asset_id))
		return null
	if str(entry.get("state", "")) != "approved":
		problems.append("asset %s is not approved" % _short(asset_id))
		return null
	var files: Array = entry.get("files", [])
	var resource: Resource = null
	for relative in files:
		var path := _asset_path(asset_id, str(relative))
		if path.is_empty():
			continue  # license records and similar companions are not shown
		resource = _load_one(path)
		if resource == null:
			problems.append("could not load %s" % str(relative))
			return null
	cache[asset_id] = resource
	return resource


func _asset_path(asset_id: String, relative: String) -> String:
	var ext := relative.get_extension().to_lower()
	if ext == "txt":
		return ""  # license records are not shown assets
	if ext == "ogg":
		# AST.O3: Ogg Opus masters ship Vorbis runtime copies under audio_runtime/.
		return audio_runtime.path_join("%s.ogg" % asset_id)
	return assets_root.path_join(relative)


func _load_one(path: String) -> Resource:
	var ext := path.get_extension().to_lower()
	var open := FileAccess.open(path, FileAccess.READ)
	if open == null:
		problems.append("missing file %s" % path.get_file())
		return null
	var data := open.get_buffer(open.get_length())
	if ext == "png":
		var image := Image.new()
		var error := image.load(path)
		if error != OK:
			return null
		return ImageTexture.create_from_image(image)
	if ext == "svg":
		var image := Image.new()
		# Godot's Image loader reads SVG files directly (verified on 4.7.2).
		var error := image.load(path)
		if error != OK:
			return null
		return ImageTexture.create_from_image(image)
	if ext == "woff2":
		var font := FontFile.new()
		if font.load_dynamic_font(path) != OK:
			return null
		return font
	if ext == "ogg":
		var stream := AudioStreamOggVorbis.load_from_file(path)
		if stream == null:
			return null
		return stream
	problems.append("unsupported extension %s" % ext)
	return null


func _short(asset_id: String) -> String:
	return asset_id.substr(0, 8)
