class_name AssetResolver
extends Node
## CMP-asset-resolver. Asset IDs only; groups boot, play, and ambient.

signal boot_ready
signal play_ready
signal ambient_ready
## CTR-asset-resolve E4 — a preload group left approved IDs unresolved (a surfaced
## failure, never a silent wait). Carries the unresolved count.
signal boot_failed(unresolved: int)
## Settles the Boot preload either way (E1 or E4), for a caller or a test that must
## not wait on an event that already fired.
signal boot_settled
signal must_overlay(asset_id: String)

const MANIFEST_PATH := "res://asset_manifest.json"
const AUDIO_RUNTIME := "audio_runtime"
const _LICENSE_EXT := "txt"

## Headless and editor runs are playtest unless this is 0 or 1.
var playtest_override := -1
var session_playable := true
var log_counts: Dictionary = {}

## CTR-asset-resolve E4 — Boot's outcome once it settles: 0 when every approved ID
## resolved, the unresolved count when the Boot preload failed, -1 while pending.
## The resolver records it here as well as emitting, so a caller that starts late
## still observes the failure instead of waiting on an event that already happened.
var boot_outcome := -1

var _manifest: Dictionary = {}
var _cache: Dictionary = {}
var _loaded_groups: Dictionary = {}
var _unresolved_counts: Dictionary = {}


func _ready() -> void:
	_read_manifest_file()


func preload_boot() -> void:
	boot_outcome = -1
	call_deferred("_preload", "boot", boot_ready, boot_failed)


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
		var resource := _load_media(asset_id, _absolute(path))
		if resource == null:
			_reject(asset_id)
			return null
		loaded.append(resource)
	if loaded.is_empty():
		_reject(asset_id)
		return null
	_wire_font_fallbacks(loaded)
	_cache[asset_id] = loaded
	return loaded[0]


## Chain every Font face of a multi-file asset so TC + JP (and Latin weights) cover glyphs.
func _wire_font_fallbacks(loaded: Array[Resource]) -> void:
	var fonts: Array[Font] = []
	for resource in loaded:
		if resource is Font:
			fonts.append(resource as Font)
	if fonts.size() < 2:
		return
	var extras: Array[Font] = []
	for index in range(1, fonts.size()):
		extras.append(fonts[index])
	fonts[0].fallbacks = extras


## Resolve every ID in a load group (for CTR-presentation.O5 via L2).
func resolve_group(group_name: String) -> Dictionary:
	var out: Dictionary = {}
	for asset_id in _group_ids(group_name):
		var resource := resolve(str(asset_id))
		if resource != null:
			out[str(asset_id)] = resource
	return out


## Resolve an ad-hoc ID set from CTR-presentation.E3.
func resolve_ids(asset_ids: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for asset_id in asset_ids:
		var resource := resolve(str(asset_id))
		if resource != null:
			out[str(asset_id)] = resource
	return out


func group_loaded(group_name: String) -> bool:
	return bool(_loaded_groups.get(group_name, false))


func is_cached(asset_id: String) -> bool:
	return _cache.has(asset_id)


func unresolved_count(group_name: String) -> int:
	return int(_unresolved_counts.get(group_name, 0))


func apply_manifest(data: Dictionary) -> void:
	_manifest = data
	_cache.clear()
	_loaded_groups.clear()
	_unresolved_counts.clear()
	log_counts.clear()


func _preload(group_name: String, done: Signal, failed: Signal = Signal()) -> void:
	if group_loaded(group_name):
		done.emit()
		if group_name == "boot":
			boot_settled.emit()
		return
	var missing := 0
	for asset_id in _group_ids(group_name):
		if resolve(str(asset_id)) == null:
			missing += 1
	_unresolved_counts[group_name] = missing
	_loaded_groups[group_name] = missing == 0
	var settles_boot := group_name == "boot"
	if settles_boot:
		boot_outcome = missing
	if missing > 0:
		# E4: settle the group as a surfaced failure. Without it the caller waits forever.
		push_error("Preload %s left %d approved IDs unresolved" % [group_name, missing])
		if failed.get_object() != null:
			failed.emit(missing)
		if settles_boot:
			boot_settled.emit()
		return
	done.emit()
	if settles_boot:
		boot_settled.emit()


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


func resolve_absolute_path(relative: String) -> String:
	## Where a manifest-relative asset path resolves on this platform. Web reads the
	## asset root as loose files under `res://` (staged beside `index.html`); every
	## other platform reads the repo-root root (ADR-0005).
	var root_name := str(_manifest.get("asset_root", ""))
	if OS.has_feature("web"):
		return "res://".path_join(root_name).path_join(relative)
	var project := ProjectSettings.globalize_path("res://").trim_suffix("/")
	return project.get_base_dir().path_join(root_name).path_join(relative)


func _absolute(relative: String) -> String:
	return resolve_absolute_path(relative)


func _load_media(asset_id: String, path: String) -> Resource:
	var ext := path.get_extension().to_lower()
	if ext == "png" or ext == "svg":
		return _load_texture(path)
	if ext == "woff2" or ext == "ttf" or ext == "otf":
		return _load_font(path)
	if ext == "ogg":
		return _load_audio(asset_id, path)
	push_error("Unsupported asset file: %s" % path.get_file())
	return null


func _load_texture(path: String) -> Resource:
	# On Web the packed route holds the imported texture, not the source file, so
	# read the resource (the virtual filesystem falls back to the PCK); the loose
	# source path stays available for builds that serve one.
	if OS.has_feature("web"):
		var loaded := ResourceLoader.load(path)
		if loaded is Texture2D:
			return loaded
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)


func _load_font(path: String) -> Resource:
	if OS.has_feature("web"):
		var loaded := ResourceLoader.load(path)
		if loaded is Font:
			return loaded
	var font := FontFile.new()
	if font.load_dynamic_font(path) != OK:
		return null
	return font


func _load_audio(asset_id: String, path: String) -> Resource:
	# `AST.O3` / `CTR-asset-resolve` G5: an approved Opus file plays from its
	# committed Vorbis copy under `audio_runtime/`, on every platform.
	if _header_contains(path, "OpusHead"):
		var runtime := _runtime_audio_path(asset_id)
		if not FileAccess.file_exists(runtime):
			return null
		return AudioStreamOggVorbis.load_from_file(runtime)
	return AudioStreamOggVorbis.load_from_file(path)


func _runtime_audio_path(asset_id: String) -> String:
	if OS.has_feature("web"):
		return "res://".path_join(AUDIO_RUNTIME).path_join("%s.ogg" % asset_id)
	var project := ProjectSettings.globalize_path("res://").trim_suffix("/")
	return project.get_base_dir().path_join(AUDIO_RUNTIME).path_join("%s.ogg" % asset_id)


func _header_contains(path: String, needle: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var header := file.get_buffer(64)
	file.close()
	var pattern := needle.to_ascii_buffer()
	if header.size() < pattern.size():
		return false
	for start in range(header.size() - pattern.size() + 1):
		var matched := true
		for index in pattern.size():
			if header[start + index] != pattern[index]:
				matched = false
				break
		if matched:
			return true
	return false


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
