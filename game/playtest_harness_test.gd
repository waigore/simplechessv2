class_name PlaytestHarnessTest
extends SceneTree

var _probe: ProbeHarness


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var host := Node.new()
	var seams := PlaytestSeams.new()
	seams.name = "PlaytestSeams"
	seams.playtest_override = 1
	var stage := {"id": "loading"}
	seams.register_stages(PackedStringArray(["loading", "mode-pick-ready"]))
	seams.bind_state(_provider.bind(stage))
	seams.jump_requested.connect(_remember_stage.bind(stage))
	_probe = ProbeHarness.new()
	host.add_child(seams)
	host.add_child(_probe)
	root.add_child(host)
	if _probe.code != 0:
		_fail("headless smoke returned %s" % str(_probe.code))
		return
	var bare := PlaytestSeams.new()
	bare.name = "BareSeams"
	bare.playtest_override = 1
	root.add_child(bare)
	var harness := PlaytestHarness.new()
	if harness.run_smoke(bare) != 1:
		_fail("expected unknown jump to fail smoke")
		return
	bare.register_stages(PackedStringArray(["mode-pick-ready"]))
	bare.bind_state(_stale_stage)
	if harness.run_smoke(bare) != 1:
		_fail("expected inspect mismatch to fail smoke")
		return
	quit(0)


func _provider(stage: Dictionary) -> Dictionary:
	return {
		"stage": stage["id"],
		"mode": "",
		"game_ended": {"ended": false, "reason": ""},
	}


func _stale_stage() -> Dictionary:
	return {"stage": "loading", "mode": "", "game_ended": {"ended": false, "reason": ""}}


func _remember_stage(stage_id: String, stage: Dictionary) -> void:
	stage["id"] = stage_id


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


class ProbeHarness:
	extends PlaytestHarness
	var code := -1

	func _finish(status: int) -> void:
		code = status
