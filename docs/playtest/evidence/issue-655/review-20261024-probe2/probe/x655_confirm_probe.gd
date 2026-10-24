extends SceneTree
## #655 branch-independent probe — the C5 / S1 leg (Expected behavior item 4).
## Writes each observation to the file named by X655_LOG as it is taken, so a
## run that does not reach `quit` still leaves its measured rows behind.

const LOG := "user://x655_probe.log"


func _initialize() -> void:
	var log := FileAccess.open(LOG, FileAccess.WRITE)
	var Flow := preload("res://puzzle_play_flow.gd")
	var flow = Flow.new()
	flow.enter(null, "", "", null)
	log.store_line("X655 B5 endpoint=<> key_set=false is_available=%s" % flow.client.is_available())
	var session = flow.session
	log.store_line("X655 ENTERED state=%s has_puzzle=%s pid=<%s> elo=%.2f last_failure=<%s>" % [
		session.play_ui_state, session.has_open_puzzle(), session.puzzle_id,
		session.player_elo, flow.stream.last_failure,
	])
	log.flush()
	var entered: String = session.play_ui_state
	log.store_line("X655 PANEL_C5_GATE=%s" % (entered != "S2" and entered != "S4"))
	log.flush()
	flow.control("C5")
	var after: String = session.play_ui_state
	var kind := str(session.confirm_kind)
	log.store_line("X655 C5_ACTIVATED state=%s confirm_kind=<%s> confirm_shown=%s" % [
		after, kind, after == "S2",
	])
	log.flush()
	if after == "S2":
		flow.control("cancel")
		log.store_line("X655 CANCEL state=%s" % session.play_ui_state)
	var conforming := after == "S2" and kind == "leave_confirm"
	log.store_line("X655_PROBE %s" % ("pass" if conforming else "fail"))
	log.close()
	quit(0)
