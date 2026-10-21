class_name AssetResolver
extends Node
## CMP-asset-resolver. Asset IDs only; groups boot, play, and ambient.

signal boot_ready
signal play_ready
signal ambient_ready
signal must_overlay(asset_id: String)

const MANIFEST_PATH := "res://asset_manifest.json"
const _LICENSE_EXT := "txt"

## Headless and editor runs are playtest unless this is 0 or 1.
var playtest_override := -1
var session_playable := true
var log_counts: Dictionary = {}

var _manifest: Dictionary = {}
var _cache: Dictionary = {}
var _loaded_groups: Dictionary = {}


func _ready() -> void:
	_read_manifest_file()


func preload_boot() -> void:
	call_deferred("_preload", "boot", boot_ready)


func preload_play() -> void:
	_preload("play", play_ready)


func preload_ambient() -> void:
	_preload("ambient", ambient_ready)


func resolve(asset_id: String) -> Resource:
	if _cache.has(asset_id):
		var cached: Array = _cache[asset_id]
		return cached[0] as Resource
	var entry := _entry(asset_id)
	if entry.is_empty() or str(entry.get("state", "")) != "approved":
		_reject(asset_id)
		return null
	var loaded: Array[Resource] = []
	for relative in entry.get("files", []):
		var path := str(relative)
		if path.get_extension().to_lower() == _LICENSE_EXT:
			continue
		var resource := _load_media(_absolute(path))
		if resource == null:
			_reject(asset_id)
			return null
		loaded.append(resource)
	if loaded.is_empty():
		_reject(asset_id)
		return null
	_cache[asset_id] = loaded
	return loaded[0]


func group_loaded(group_name: String) -> bool:
	return bool(_loaded_groups.get(group_name, false))


func is_cached(asset_id: String) -> bool:
	return _cache.has(asset_id)


func apply_manifest(data: Dictionary) -> void:
	_manifest = data
	_cache.clear()
	_loaded_groups.clear()
	log_counts.clear()


func _preload(group_name: String, done: Signal) -> void:
	if not group_loaded(group_name):
		for asset_id in _group_ids(group_name):
			resolve(str(asset_id))
		_loaded_groups[group_name] = true
	done.emit()


func _read_manifest_file() -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		push_warning("Boot manifest missing; continuing without Boot assets")
		_manifest = {}
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if parsed is Dictionary:
		_manifest = parsed
		return
	push_error("Asset manifest is not an object")
	_manifest = {}


func _entry(asset_id: String) -> Dictionary:
	var assets: Variant = _manifest.get("assets", {})
	if assets is Dictionary and (assets as Dictionary).has(asset_id):
		var entry: Variant = (assets as Dictionary)[asset_id]
		if entry is Dictionary:
			return entry
	return {}


func _group_ids(group_name: String) -> Array:
	var groups: Variant = _manifest.get("groups", {})
	if groups is Dictionary and (groups as Dictionary).has(group_name):
		var ids: Variant = (groups as Dictionary)[group_name]
		if ids is Array:
			return ids
	return []


func _absolute(relative: String) -> String:
	var project := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var root_name := str(_manifest.get("asset_root", ""))
	return project.get_base_dir().path_join(root_name).path_join(relative)


func _load_media(path: String) -> Resource:
	var ext := path.get_extension().to_lower()
	if ext == "png" or ext == "svg":
		return _load_texture(path)
	if ext == "woff2" or ext == "ttf" or ext == "otf":
		return _load_font(path)
	if ext == "ogg":
		return _load_audio(path)
	push_error("Unsupported asset file: %s" % path.get_file())
	return null


func _load_texture(path: String) -> Resource:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)


func _load_font(path: String) -> Resource:
	var font := FontFile.new()
	if font.load_dynamic_font(path) != OK:
		return null
	return font


func _load_audio(path: String) -> Resource:
	return AudioStreamOggVorbis.load_from_file(path)


func _reject(asset_id: String) -> void:
	session_playable = true
	if _is_playtest():
		log_counts[asset_id] = int(log_counts.get(asset_id, 0)) + 1
		push_error("Unresolved asset ID: %s" % asset_id)
		must_overlay.emit(asset_id)
		return
	if int(log_counts.get(asset_id, 0)) > 0:
		return
	log_counts[asset_id] = 1
	push_warning("Unresolved asset ID: %s" % asset_id)


func _is_playtest() -> bool:
	if OS.has_feature("playtest"):
		return true
	if OS.has_feature("release"):
		return false
	if playtest_override == 0:
		return false
	if playtest_override == 1:
		return true
	return true
