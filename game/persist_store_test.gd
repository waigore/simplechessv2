class_name PersistStoreTest
extends SceneTree
## Headless checks for CMP-persist-store / CTR-persist-document. The `player_elo` and
## `recent_solved` slots this file asserts are `SCH-persist-doc.F2` and `.F4`, committed
## per `PRG.M1` and promised by `persistence.md` M2 / M4 / G1.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := _defaults_and_schema()
	if err.is_empty():
		err = _successful_commit_and_reload()
	if err.is_empty():
		err = _forced_write_failure_keeps_prior()
	if err.is_empty():
		err = _cleared_storage_cold_open()
	if err.is_empty():
		err = _corrupt_and_missing_fields()
	if err.is_empty():
		err = await _session_last_mode_roundtrip()
	if err.is_empty():
		quit(0)
		return
	push_error(err)
	quit(1)


func _defaults_and_schema() -> String:
	var store := PersistStore.new()
	root.add_child(store)
	var doc := store.load_document()
	if int(doc.get("version", 0)) != PersistStore.VERSION:
		return "default version"
	if float(doc.get("player_elo", -1)) != float(PersistStore.ELO_START):
		return "default player_elo / CFG.ELO_START"
	if str(doc.get("last_mode", "")) != PersistStore.MODE_NONE:
		return "default last_mode none"
	var recent: Variant = doc.get("recent_solved", null)
	if not (recent is Array) or (recent as Array).size() != 0:
		return "default recent_solved empty"
	store.free()
	return ""


func _successful_commit_and_reload() -> String:
	var shared: Dictionary = {}
	var store := PersistStore.new()
	store.memory_backend = shared
	root.add_child(store)
	if not store.commit_last_mode(PersistStore.MODE_SHARED):
		return "commit last_mode shared"
	var committed := store.read_committed()
	if str(committed.get("last_mode", "")) != PersistStore.MODE_SHARED:
		return "read_committed after write"
	if float(committed.get("player_elo", -1)) != float(PersistStore.ELO_START):
		return "SCH-persist-doc.F2 player_elo slot preserved on Last mode commit"
	var recent: Array = committed.get("recent_solved", [])
	if recent.size() != 0:
		return "SCH-persist-doc.F4 recent_solved slot preserved"
	store.free()

	var reloaded := PersistStore.new()
	reloaded.memory_backend = shared
	root.add_child(reloaded)
	var loaded := reloaded.load_document()
	if str(loaded.get("last_mode", "")) != PersistStore.MODE_SHARED:
		return "reload did not restore last_mode"
	reloaded.free()
	return ""


func _forced_write_failure_keeps_prior() -> String:
	var shared: Dictionary = {}
	var store := PersistStore.new()
	store.memory_backend = shared
	root.add_child(store)
	if not store.commit_last_mode(PersistStore.MODE_SHARED):
		return "seed commit"
	var prior_raw := str(shared.get(PersistStore.STORAGE_KEY, ""))
	var failed_flag: Array = [false]
	store.write_failed.connect(func() -> void: failed_flag[0] = true)
	store.force_write_failure = true
	if store.commit_last_mode(PersistStore.MODE_PUZZLE):
		return "forced failure returned success"
	if not failed_flag[0]:
		return "write_failed not emitted"
	if str(shared.get(PersistStore.STORAGE_KEY, "")) != prior_raw:
		return "forced failure mutated storage"
	if str(store.read_committed().get("last_mode", "")) != PersistStore.MODE_SHARED:
		return "forced failure mutated committed snapshot"
	store.free()
	return ""


func _cleared_storage_cold_open() -> String:
	var shared: Dictionary = {}
	var store := PersistStore.new()
	store.memory_backend = shared
	root.add_child(store)
	store.commit_last_mode(PersistStore.MODE_SHARED)
	store.clear_storage()
	var doc := store.load_document()
	if str(doc.get("last_mode", "")) != PersistStore.MODE_NONE:
		return "cleared storage last_mode"
	if float(doc.get("player_elo", -1)) != float(PersistStore.ELO_START):
		return "cleared storage elo"
	store.free()
	return ""


func _corrupt_and_missing_fields() -> String:
	var shared: Dictionary = {}
	shared[PersistStore.STORAGE_KEY] = "{not-json"
	var store := PersistStore.new()
	store.memory_backend = shared
	root.add_child(store)
	var doc := store.load_document()
	if str(doc.get("last_mode", "")) != PersistStore.MODE_NONE:
		return "corrupt → defaults last_mode"
	store.free()

	shared[PersistStore.STORAGE_KEY] = JSON.stringify({"version": 1})
	store = PersistStore.new()
	store.memory_backend = shared
	root.add_child(store)
	doc = store.load_document()
	if float(doc.get("player_elo", -1)) != float(PersistStore.ELO_START):
		return "missing fields → elo default"
	if str(doc.get("last_mode", "")) != PersistStore.MODE_NONE:
		return "missing fields → last_mode default"
	var recent: Array = doc.get("recent_solved", ["x"])
	if recent.size() != 0:
		return "missing fields → recent_solved default"
	store.free()
	return ""


func _session_last_mode_roundtrip() -> String:
	## Cold open → choose Shared → reload → forced fail keeps prior.
	var shared: Dictionary = {}
	var first := await _boot_router(shared)
	if first["err"] != "":
		return str(first["err"])
	var router: SessionRouter = first["router"]
	var parent: Node = first["parent"]
	router.handle_control("mode-pick", "C1")
	if router.last_mode != PersistStore.MODE_SHARED or router.stage != "shared-setup":
		parent.free()
		return "C1 commit → shared-setup"
	parent.free()

	var second := await _boot_router(shared)
	if second["err"] != "":
		return str(second["err"])
	router = second["router"]
	parent = second["parent"]
	var persist: PersistStore = second["persist"]
	var err := ""
	if router.last_mode != PersistStore.MODE_SHARED:
		err = "reload last_mode shared"
	else:
		var prior := router.last_mode
		persist.force_write_failure = true
		if persist.commit_last_mode(PersistStore.MODE_PUZZLE):
			err = "session forced fail should fail"
		elif str(persist.read_committed().get("last_mode", "")) != PersistStore.MODE_SHARED:
			err = "session prior kept after fail"
		elif router.last_mode != prior:
			err = "router last_mode changed on failed write"
	parent.free()
	return err


func _boot_router(shared: Dictionary) -> Dictionary:
	var parent := Node.new()
	root.add_child(parent)
	var persist := PersistStore.new()
	persist.name = "PersistStore"
	persist.memory_backend = shared
	var resolver := AssetResolver.new()
	resolver.name = "AssetResolver"
	var seams := PlaytestSeams.new()
	seams.name = "PlaytestSeams"
	seams.playtest_override = 1
	var router := SessionRouter.new()
	router.name = "SessionRouter"
	parent.add_child(persist)
	parent.add_child(resolver)
	parent.add_child(seams)
	parent.add_child(router)
	router.start()
	await resolver.boot_ready
	# boot_ready.emit() resumes this await on the emitter's stack.
	# Yield once so parent.free() does not destroy AssetResolver mid-signal.
	await process_frame
	var err := ""
	if router.stage != "mode-pick" and router.stage != "mode-pick-ready":
		err = "boot did not reach mode-pick"
	return {"err": err, "parent": parent, "router": router, "persist": persist}
