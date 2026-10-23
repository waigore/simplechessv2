extends SceneTree
## Independent check of AC3 (#545): O11 assert_telemetry is absent from a release build.

func _initialize() -> void:
	var seams := PlaytestSeams.new()
	seams.playtest_override = 0
	root.add_child(seams)
	seams.configure()
	# Force a would-be match into the path: emit is a no-op in release, so the buffer stays empty.
	seams.emit_tel("pause", "pass", "EX.loading")
	var result := seams.assert_telemetry([{"event": "pause", "outcome": "pass", "story_id": "EX.loading"}])
	print("A545R playtest_build=%s" % seams.playtest_build)
	print("A545R verdict=%s matched=%d missing=%d event_count=%d" % [
		result["verdict"], result["matched"].size(), result["missing"].size(), result["event_count"]
	])
	print("A545R keys=%s" % [result.keys()])
	var ok: bool = (
		seams.playtest_build == false
		and result["verdict"] == "fail"
		and result["matched"].is_empty()
		and result["missing"].is_empty()
		and int(result["event_count"]) == 0
	)
	print("A545R_PROBE %s" % ("pass" if ok else "fail"))
	quit(0 if ok else 1)
