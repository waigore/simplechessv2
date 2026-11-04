extends SceneTree
## Throwaway wrapper (acceptance run #334, parallel id 3): run the shipped
## copy-gate document and report its verdict. The judgements are all in
## `game/string_table_test.gd`; this only gives this run one log to cite.

const Gate := preload("res://string_table_test.gd")

var _gate: SceneTree


func _initialize() -> void:
	_gate = Gate.new()
	call_deferred("_drive")


func _drive() -> void:
	_gate.call_deferred("_start")
	for i in 300:
		await process_frame
	if _gate.root != null:
		_gate.root.queue_free()
	print("GATE RUN COMPLETE")
	quit()


func _process(_delta: float) -> bool:
	return false
