extends SceneTree
## Why is R2 one letter wide? Report the Label's wrap/clip and the parent's sizing.

var _main: Node


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene := load("res://main.tscn") as PackedScene
	_main = scene.instantiate()
	root.add_child(_main)
	for i in 8:
		await process_frame
	var router := _main.get_node("SessionRouter") as SessionRouter
	router.call("_go_mode_pick", "S1")
	await process_frame
	router.handle_control("mode-pick", "C2")
	for i in 6:
		await process_frame
	var panel: Node = _main.get_node("ScreenHost/PuzzlePlay")
	var r2 := panel.find_child("EloAndStatus", true, false) as Control
	var elo := panel.find_child("PlayerElo", true, false) as Label
	var chrome := panel.find_child("PuzzleChrome", true, false) as Control
	print("panel=", (panel as Control).get_global_rect(), " size=", (panel as Control).size)
	print("chrome=", chrome.get_global_rect(), " grow_v=", chrome.grow_vertical)
	print("r2=", r2.get_global_rect(), " size=", r2.size, " min=", r2.get_combined_minimum_size())
	print("elo=", elo.get_global_rect(), " size=", elo.size, " min=", elo.get_combined_minimum_size())
	print("elo.text=", elo.text, " autowrap=", elo.autowrap_mode, " clip=", elo.clip_text)
	print("elo custom_min=", elo.custom_minimum_size, " size_flags_h=", elo.size_flags_horizontal)
	print("font_px=", elo.get_theme_font_size("font_size"))
	# What does the text actually need?
	var f := elo.get_theme_font("font")
	var px := elo.get_theme_font_size("font_size")
	print("text_width_at_px=", f.get_string_size(elo.text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x)
	quit(0)
