extends SceneTree
## #558 — read the shipped advice fields on the release scene graph.
##
## The release Web export carries no `PlaytestSeams` (ADR-0004 `G2`), so `DBG.2`
## cannot be called on the shipped build at all. This probe loads the same
## `res://main_release.tscn` the release preset exports, drives it through
## `Presentation`'s control path, and reads `SharedGameSession.play_state()` —
## the data `DBG.2` returns on a playtest build — for the Advice-Off and
## offline-and-On legs of this task.
##
## It changes nothing: the session it reads is built by the shipped router from
## the shipped configuration, and its advice endpoint stays empty (T9/T10), as
## on the release. Each reading prints `R558 {json}`; the exit code counts
## failed checks.

const RELEASE_SCENE := "res://main_release.tscn"

var _failures := 0
var _checks := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var root: Node = (load(RELEASE_SCENE) as PackedScene).instantiate()
	root.process_mode = Node.PROCESS_MODE_DISABLED
	get_root().add_child(root)
	root.process_mode = Node.PROCESS_MODE_INHERIT
	await _frames(2)

	_check("release_scene_has_no_seams", root.get_node_or_null("PlaytestSeams") == null, "main_release.tscn")
	var router := root.get_node_or_null("SessionRouter") as SessionRouter
	var presentation := root.get_node_or_null("Presentation") as Presentation
	if presentation == null:
		presentation = root as Presentation
	_check("router_present", router != null)
	_check("presentation_present", presentation != null)
	if router == null or presentation == null:
		await _finish()
		return

	presentation.control_activate.emit("mode-pick", "C1")
	await _frames(2)
	presentation.control_activate.emit("shared-setup", "C4")
	await _frames(2)
	presentation.control_activate.emit("shared-setup", "C5")
	await _frames(2)
	_check("shared_play_reached", router.stage == SessionRouter.STAGE_SHARED_PLAY, router.stage)

	var session := router.shared_session
	if session == null:
		_check("shared_session_present", false)
		await _finish()
		return
	_check("advice_client_is_shipped", session.advice_client != null)
	_check("advice_endpoint_empty", router.advice_endpoint.is_empty(), router.advice_endpoint)

	# Leg 1 — Advice Off in Shared play.
	_report("advice_off.start", session)
	_check("advice_off.advice_is_off", session.advice_on == false, str(session.advice_on))
	_check("advice_off.best_move_none", session.play_state().get("advice_best_move") == null, "")
	_check("advice_off.eval_none", session.play_state().get("advice_eval") == null, "")

	_check("move.f2f3", router.handle_input_commit("f2", "f3"), "")
	await _frames(4)
	_report("advice_off.after_move", session)
	_check("advice_off.after_move.side_black", session.side_to_move() == ChessRules.SIDE_BLACK, session.side_to_move())
	_check("advice_off.after_move.best_move_none", session.play_state().get("advice_best_move") == null, "")
	_check("advice_off.after_move.eval_none", session.play_state().get("advice_eval") == null, "")
	_check("advice_off.after_move.no_error", session.advice_error == false, "")

	# Leg 2 — Advice On with the build offline (no backend was ever reachable).
	presentation.control_activate.emit("shared-play", "C3")
	await _frames(2)
	_check("online_on.advice_is_on", session.advice_on == true, str(session.advice_on))
	_check("online_on.advice_client_unavailable", session.advice_client.is_available() == false, "T9/T10 empty on the release")
	_check("online_on.best_move_none", session.play_state().get("advice_best_move") == null, "")
	_check("online_on.eval_none", session.play_state().get("advice_eval") == null, "")
	session.online = false
	await _frames(2)
	_check("offline.move.e7e5", router.handle_input_commit("e7", "e5"), "")
	await _frames(4)
	_report("offline_and_on.after_move", session)
	_check("offline_and_on.online_false", session.online == false, "")
	_check("offline_and_on.best_move_none", session.play_state().get("advice_best_move") == null, "")
	_check("offline_and_on.eval_none", session.play_state().get("advice_eval") == null, "")
	_check("offline_and_on.no_error", session.advice_error == false, "")

	# R9 — going offline clears anything set and stops evaluation.
	var cleared := session.advice_control("offline")
	await _frames(2)
	_report("offline.r9", session)
	_check("offline.r9.best_move_none", session.play_state().get("advice_best_move") == null, "")
	_check("offline.r9.eval_none", session.play_state().get("advice_eval") == null, "")
	_check("offline.r9.events_array", cleared.get("events") is Array, "")

	await _finish()


func _report(name: String, session: SharedGameSession) -> void:
	var state := session.play_state()
	print(
		"R558 ",
		JSON.stringify(
			{
				"check": name,
				"advice": state.get("advice"),
				"online": state.get("online"),
				"advice_best_move": state.get("advice_best_move"),
				"advice_eval": state.get("advice_eval"),
				"advice_error": session.advice_error,
				"side_to_move": state.get("position", {}).get("side_to_move"),
				"mode": state.get("mode"),
			}
		)
	)


func _check(name: String, ok: bool, detail: String = "") -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print("R558 ", JSON.stringify({"check": name, "ok": ok, "detail": detail}))


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


func _finish() -> void:
	print("R558 ", JSON.stringify({"summary": {"checks": _checks, "failures": _failures}}))
	quit(0 if _failures == 0 else 1)
