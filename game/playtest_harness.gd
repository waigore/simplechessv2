class_name PlaytestHarness
extends Node
## SEQ-playtest-headless-smoke harness for ENV.1. Release builds no-op (G2).

const SMOKE_STAGE := "mode-pick"
const SMOKE_STORY := "EX.loading"


func run_smoke(seams: PlaytestSeams) -> int:
	var jump_error := seams.jump(SMOKE_STAGE)
	if jump_error != OK:
		push_error("smoke jump failed")
		return 1
	var inspected := seams.inspect(PackedStringArray(["stage", "mode", "game_ended"]))
	if str(inspected.get("stage", "")) != SMOKE_STAGE:
		push_error("smoke inspect failed")
		return 1
	seams.emit_tel("smoke_inspect", "pass", SMOKE_STORY)
	seams.pause()
	if not seams.is_paused():
		push_error("smoke pause failed")
		return 1
	seams.resume()
	if seams.is_paused():
		push_error("smoke resume failed")
		return 1
	return 0


func _ready() -> void:
	if not PlaytestGate.is_playtest():
		return
	if DisplayServer.get_name() != "headless":
		return
	_smoke_and_quit()


func _smoke_and_quit() -> void:
	var seams := get_parent().get_node("PlaytestSeams") as PlaytestSeams
	_finish(run_smoke(seams))


func _finish(code: int) -> void:
	get_tree().quit(code)
