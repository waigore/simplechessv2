class_name AssetResolverTest
extends SceneTree

var _resolver: AssetResolver
var _router: SessionRouter
var _seams: PlaytestSeams
var _manifest: Dictionary = {}


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://asset_manifest.json")
	)
	if parsed is Dictionary:
		_manifest = parsed
	var parent := Node.new()
	_resolver = AssetResolver.new()
	_resolver.name = "AssetResolver"
	_seams = PlaytestSeams.new()
	_seams.name = "PlaytestSeams"
	_seams.playtest_override = 1
	_router = SessionRouter.new()
	_router.name = "SessionRouter"
	parent.add_child(_resolver)
	parent.add_child(_seams)
	parent.add_child(_router)
	root.add_child(parent)
	_router.start()
	## Cold open: boot preload is deferred, and Ambient must not start before mode pick.
	_router.start_music()
	if _resolver.group_loaded("ambient"):
		_fail("ambient loaded on cold open")
		return
	call_deferred("_after_boot")


func _after_boot() -> void:
	var boot_id := _first_kind("icons")
	var play_id := _first_kind("piece-sprites")
	var sfx_id := _first_kind("sound-effects")
	var music_id := _first_kind("music")
	var problem := ""
	if not _resolver.group_loaded("boot") or _resolver.group_loaded("play"):
		problem = "boot group"
	elif _router.stage != SessionRouter.STAGE_MODE_PICK:
		problem = "mode pick did not become ready"
	elif not _resolver.group_loaded("ambient"):
		problem = "ambient must load when mode pick is ready"
	elif _resolver.resolve(boot_id) == null:
		problem = "boot id did not resolve"
	elif _any_cached("play"):
		problem = "play id loaded during boot"
	if not problem.is_empty():
		_fail(problem)
		return
	_router.enter_shared_play()
	_router.start_music()
	if not _resolver.group_loaded("play") or not _resolver.group_loaded("ambient"):
		problem = "play entry"
	elif _resolver.resolve(play_id) == null or not _resolver.is_cached(sfx_id):
		problem = "play id did not resolve"
	if not problem.is_empty():
		_fail(problem)
		return
	var before := _resolver.is_cached(play_id)
	_router.enter_shared_play()
	_router.start_music()
	if not _resolver.group_loaded("ambient") or not _resolver.session_playable:
		problem = "ambient after mode pick ready"
	elif not _resolver.is_cached(sfx_id) or not _resolver.is_cached(music_id):
		problem = "approved audio did not resolve"
	elif _resolver.unresolved_count("play") != 0 or _resolver.unresolved_count("ambient") != 0:
		problem = "preload left approved IDs unresolved"
	elif not before or not _resolver.is_cached(play_id):
		problem = "group reload dropped a cached asset"
	if not problem.is_empty():
		_fail(problem)
		return
	if not _check_unresolved() or not _check_preload_gap() or not _check_vorbis_copy(music_id):
		return
	if not _check_cjk_font_faces():
		return
	quit(0)


func _check_cjk_font_faces() -> bool:
	## Multi-file fonts/noto-sans-cjk must wire TC then JP as fallbacks (#62).
	var cjk := _resolver.resolve(UiChrome.FONT_CJK) as Font
	if cjk == null:
		return _fail("CJK font missing")
	if cjk.fallbacks.is_empty():
		return _fail("CJK font missing JP fallback face")
	return true


func _check_unresolved() -> bool:
	var probe := AssetResolver.new()
	probe.playtest_override = 1
	root.add_child(probe)
	probe.apply_manifest(_bad_manifest())
	var overlays: Array[String] = []
	probe.must_overlay.connect(_remember_overlay.bind(overlays))
	if probe.resolve("missing") != null or probe.resolve("draft-id") != null:
		return _fail("draft or unknown id resolved")
	if probe.resolve("deprecated-id") != null or probe.resolve("broken-id") != null:
		return _fail("deprecated or missing file resolved")
	if overlays.size() < 4 or not probe.session_playable:
		return _fail("playtest overlay")
	var again := int(probe.log_counts.get("missing", 0))
	probe.resolve("missing")
	if int(probe.log_counts.get("missing", 0)) != again + 1:
		return _fail("playtest did not log again")
	probe.playtest_override = 0
	probe.log_counts.clear()
	probe.resolve("missing")
	probe.resolve("missing")
	if int(probe.log_counts.get("missing", 0)) != 1 or not probe.session_playable:
		return _fail("release log once")
	return true


func _check_preload_gap() -> bool:
	var probe := AssetResolver.new()
	probe.playtest_override = 1
	root.add_child(probe)
	var asset_root := str(_manifest.get("asset_root", ""))
	var sfx_path := _first_file("sound-effects")
	(
		probe
		. apply_manifest(
			{
				"asset_root": asset_root,
				"groups": {"boot": [], "play": ["missing-runtime"], "ambient": []},
				"assets":
				{
					"missing-runtime":
					{"state": "approved", "kind": "sound-effects", "files": [sfx_path]},
				},
			}
		)
	)
	var ready: Array[bool] = [false]
	probe.play_ready.connect(func() -> void: ready[0] = true)
	probe.preload_play()
	if probe.group_loaded("play") or ready[0] or probe.unresolved_count("play") != 1:
		return _fail("partial play preload was marked ready")
	if probe.resolve("missing-runtime") != null or not probe.session_playable:
		return _fail("missing Vorbis copy resolved")
	return true


func _check_vorbis_copy(music_id: String) -> bool:
	var probe := AssetResolver.new()
	probe.playtest_override = 1
	root.add_child(probe)
	(
		probe
		. apply_manifest(
			{
				"asset_root": "audio_runtime",
				"groups": {"boot": [], "play": [], "ambient": []},
				"assets":
				{
					music_id:
					{"state": "approved", "kind": "music", "files": ["%s.ogg" % music_id]},
				},
			}
		)
	)
	if probe.resolve(music_id) == null:
		return _fail("vorbis copy did not resolve")
	return true


func _first_file(kind: String) -> String:
	var assets: Dictionary = _manifest.get("assets", {})
	var ids: Array = assets.keys()
	ids.sort()
	for asset_id in ids:
		var entry: Dictionary = assets[asset_id]
		if str(entry.get("kind", "")) != kind:
			continue
		for relative in entry.get("files", []):
			var path := str(relative)
			if path.get_extension().to_lower() == "ogg":
				return path
	return ""


func _bad_manifest() -> Dictionary:
	return {
		"asset_root": str(_manifest.get("asset_root", "")),
		"groups": {"boot": [], "play": [], "ambient": []},
		"assets":
		{
			"draft-id": {"state": "draft", "files": ["icons/quit.svg"]},
			"deprecated-id": {"state": "deprecated", "files": ["icons/quit.svg"]},
			"broken-id": {"state": "approved", "files": ["icons/missing.svg"]},
		},
	}


func _first_kind(kind: String) -> String:
	var assets: Dictionary = _manifest.get("assets", {})
	var ids: Array = assets.keys()
	ids.sort()
	for asset_id in ids:
		var entry: Dictionary = assets[asset_id]
		if str(entry.get("kind", "")) == kind:
			return str(asset_id)
	return ""


func _any_cached(group_name: String) -> bool:
	var groups: Dictionary = _manifest.get("groups", {})
	for asset_id in groups.get(group_name, []):
		if _resolver.is_cached(str(asset_id)):
			return true
	return false


func _remember_overlay(asset_id: String, overlays: Array[String]) -> void:
	overlays.append(asset_id)


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
