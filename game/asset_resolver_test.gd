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
	elif _resolver.group_loaded("ambient"):
		## #856: the frame that first paints mode pick carries no Ambient read, so
		## the group is still unloaded in the frame mode pick became ready.
		problem = "ambient loaded in the mode-pick frame"
	if not problem.is_empty():
		_fail(problem)
		return
	## The frames after the paint are when `AST.G3`'s Ambient load lands (#856).
	await process_frame
	await process_frame
	if not _resolver.group_loaded("ambient"):
		problem = "ambient must load once mode pick is painted"
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
	if (
		not _check_unresolved()
		or not await _check_preload_gap()
		or not _check_vorbis_copy(music_id)
	):
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
	return await _check_boot_failure_surfaced()


func _check_boot_failure_surfaced() -> bool:
	## Inverted from the old "stall is correct" check: a Boot group that leaves an
	## approved ID unresolved settles as CTR-asset-resolve E4, the caller sees it,
	## and the router leaves `EX.loading` for `EX.load-failure` (#882).
	var probe := AssetResolver.new()
	probe.playtest_override = 1
	root.add_child(probe)
	(
		probe
		. apply_manifest(
			{
				"asset_root": str(_manifest.get("asset_root", "")),
				"groups": {"boot": ["missing-boot"], "play": [], "ambient": []},
				"assets":
				{
					"missing-boot":
					{"state": "approved", "kind": "icons", "files": ["icons/none.svg"]}
				},
			}
		)
	)
	var ready: Array[bool] = [false]
	var failed: Array[int] = [-1]
	probe.boot_ready.connect(func() -> void: ready[0] = true)
	probe.boot_failed.connect(func(count: int) -> void: failed[0] = count)
	var settled: Array[bool] = [false]
	probe.boot_settled.connect(func() -> void: settled[0] = true, CONNECT_ONE_SHOT)
	probe.preload_boot()
	await probe.boot_settled
	if not settled[0] or ready[0] or failed[0] != 1 or probe.group_loaded("boot"):
		return _fail("failed boot preload did not surface the failure")
	if probe.boot_outcome != 1 or probe.group_loaded("boot"):
		return _fail("failed boot preload did not log the unresolved count")
	var problem := await _router_loads_again_after_failure(probe._manifest)
	if not problem.is_empty():
		return _fail(problem)
	return _check_load_failure_surface()


## The router half: E4 ends the wait, `EX.load-failure` is named, and C5 Reload loads
## the game again from the start. The router gets its *own* resolver — the one it binds
## in `_ready` and reloads from — because a decoy resolver cannot show where the real
## reload lands (#923).
func _router_loads_again_after_failure(manifest: Dictionary) -> String:
	var parent := Node.new()
	root.add_child(parent)
	var resolver := AssetResolver.new()
	resolver.name = "AssetResolver"
	resolver.playtest_override = 1
	parent.add_child(resolver)
	var router := SessionRouter.new()
	router.name = "SessionRouter"
	parent.add_child(router)
	resolver.apply_manifest(manifest)
	var screens: Array[String] = []
	router.screen_requested.connect(
		func(screen_id: String, _state: Dictionary) -> void: screens.append(screen_id)
	)
	router.start()
	## The Boot preload is deferred; let it settle before judging the stage.
	await process_frame
	await process_frame
	var problem := _load_failure_is_named(router, screens)
	if problem.is_empty():
		router.handle_control(SessionRouter.STAGE_LOAD_FAILED, "C1")
		if router.stage != SessionRouter.STAGE_LOAD_FAILED:
			problem = "EX.load-failure acted on a control it does not offer"
	if problem.is_empty():
		screens.clear()
		router.handle_control(SessionRouter.STAGE_LOAD_FAILED, "C5")
		if router.stage != SessionRouter.STAGE_LOADING or router.boot_failure_count != 1:
			problem = "Reload did not load the game again from the start"
	if problem.is_empty():
		## The manifest leaves Boot unresolvable, so the reloaded attempt must fail the
		## same way, through a fresh read.
		if resolver.boot_outcome == 1 or resolver.group_loaded("boot"):
			problem = "Reload kept a failed Boot verdict the wait would not read again"
	## #923: the stage C5 sets is transient. Judge where the reloaded read *lands* —
	## `exceptions.md` EX.load-failure Recovery says "Boot assets, then `mode-pick` or
	## this row", so a Boot that fails again must come back to this row, never to
	## mode-pick.
	if problem.is_empty():
		await process_frame
		await process_frame
		if router.stage != SessionRouter.STAGE_LOAD_FAILED:
			problem = "Reload settled on %s, not EX.load-failure" % router.stage
		elif screens.is_empty() or screens[-1] != SessionRouter.STAGE_LOAD_FAILED:
			problem = "Reload's second Boot failure was not named to the presentation"
		elif router.boot_failure_count != 1:
			problem = "Reload lost the unresolved count"
	parent.queue_free()
	return problem


## E4 reached the router and replaced the wait with `EX.load-failure`.
func _load_failure_is_named(router: SessionRouter, screens: Array[String]) -> String:
	if router.boot_failure_count != 1:
		return "session router did not observe the boot failure"
	if router.stage != SessionRouter.STAGE_LOAD_FAILED:
		return "boot failure left STAGE_LOADING: EX.loading is waited on after it failed"
	## `start()` names `EX.loading` first; the failure replaces it.
	if screens.is_empty() or screens[-1] != SessionRouter.STAGE_LOAD_FAILED:
		return "boot failure did not name EX.load-failure to the presentation"
	return ""


## UI-mode-pick S5 — the shipped surface names the failure and offers Reload in
## every locale; `EX.loading` is gone rather than waited on (#882).
func _check_load_failure_surface() -> bool:
	var packed := load("res://main.tscn") as PackedScene
	var view := packed.instantiate() as Presentation
	var harness := view.get_node_or_null("PlaytestHarness")
	if harness != null:
		view.remove_child(harness)
		harness.free()
	root.add_child(view)
	view.show_screen(SessionRouter.STAGE_LOAD_FAILED, {})
	var panel := view.get_node_or_null("LoadFailure") as LoadFailurePanel
	if panel == null or not panel.visible:
		return _fail("EX.load-failure has no surface")
	if (view.get_node("LoadingLabel") as Label).visible:
		return _fail("EX.loading stays on screen after the Boot load failed")
	if (
		panel.button_for(LoadFailurePanel.CONTROL_RELOAD) == null
		or not panel.button_for(LoadFailurePanel.CONTROL_RELOAD).visible
	):
		return _fail("EX.load-failure offers no Reload")
	var problem := _load_failure_copy_is_localized(panel)
	if problem.is_empty():
		view.show_screen(SessionRouter.STAGE_LOADING, {})
		if panel.visible:
			problem = "EX.load-failure stayed up once the load gate returned"
	view.queue_free()
	if not problem.is_empty():
		return _fail(problem)
	return true


## Every locale carries its own load-failure message and Reload label, and nothing
## else is offered on S5.
func _load_failure_copy_is_localized(panel: LoadFailurePanel) -> String:
	if panel.control_available("C1") or panel.control_available("C4"):
		return "EX.load-failure offers a control it does not have"
	var message_label := panel.find_child("LoadFailureMessage", true, false) as Label
	var reload := panel.button_for(LoadFailurePanel.CONTROL_RELOAD)
	for locale in StringTable.LOCALES:
		panel.configure(locale, null, 1.0)
		var message := StringTable.exception_text("load_failure", locale)
		if message_label == null or message_label.text != message:
			return "EX.load-failure message missing in %s" % locale
		if reload.text != StringTable.exception_text("reload", locale):
			return "EX.load-failure Reload copy missing in %s" % locale
		if locale != "en" and message == StringTable.exception_text("load_failure", "en"):
			return "EX.load-failure message still English in %s" % locale
	return ""


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
	return _check_catalogued_audio_route()


## #785: an Opus catalogued under the real asset root (`music/…`) must play from its
## `audio_runtime/<asset ID>.ogg` copy. The check above cannot see this — it moves the
## catalogued path *onto* `audio_runtime/`, so it passed while the shipped read failed.
func _check_catalogued_audio_route() -> bool:
	var music_id := _first_kind("music")
	var source := _first_file("music")
	if music_id.is_empty() or source.is_empty():
		return _fail("no catalogued music to route")
	var probe := AssetResolver.new()
	probe.playtest_override = 1
	root.add_child(probe)
	probe.apply_manifest(_manifest)
	var catalogued := probe.resolve_absolute_path(source)
	if catalogued.begins_with(probe._runtime_audio_path(music_id)):
		return _fail("catalogued music sits on the runtime route; the test can prove nothing")
	if not probe._header_contains(catalogued, "OpusHead"):
		return _fail("catalogued music is not Opus, so O3 does not route it")
	var stream := probe.resolve(music_id) as AudioStreamOggVorbis
	if stream == null or stream.get_length() <= 0.0:
		return _fail("catalogued Opus did not play from its Vorbis copy")
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
