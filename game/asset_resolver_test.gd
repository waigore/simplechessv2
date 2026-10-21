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
	call_deferred("_after_boot")


func _after_boot() -> void:
	var boot_id := _first_kind("icons")
	var play_id := _first_kind("piece-sprites")
	var sfx_id := _first_kind("sound-effects")
	var music_id := _first_kind("music")
	var problem := ""
	if not _resolver.group_loaded("boot") or _resolver.group_loaded("play"):
		problem = "boot group"
	elif _resolver.group_loaded("ambient"):
		problem = "ambient loaded on cold open"
	elif _resolver.resolve(boot_id) == null:
		problem = "boot id did not resolve"
	elif _any_cached("play"):
		problem = "play id loaded during boot"
	if not problem.is_empty():
		_fail(problem)
		return
	_router.enter_shared_play()
	_router.start_music()
	if not _resolver.group_loaded("play") or _resolver.group_loaded("ambient"):
		problem = "play entry"
	elif _resolver.resolve(play_id) == null:
		problem = "piece sprite did not resolve"
	if not problem.is_empty():
		_fail(problem)
		return
	_router.note_board_playable()
	_router.start_music()
	var before := _resolver.is_cached(play_id)
	_router.enter_shared_play()
	_router.start_music()
	if not _resolver.group_loaded("ambient") or not _resolver.session_playable:
		problem = "ambient after the board is playable"
	elif _resolver.is_cached(sfx_id) or _resolver.is_cached(music_id):
		problem = "undecodable audio was cached"
	elif not before or not _resolver.is_cached(play_id):
		problem = "group reload dropped a cached asset"
	if not problem.is_empty():
		_fail(problem)
		return
	if not _check_unresolved():
		return
	quit(0)


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
