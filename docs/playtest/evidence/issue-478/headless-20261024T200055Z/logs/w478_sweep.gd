extends SceneTree
## Issue #478 — wave-1 playtest sweep driver.
##
## Drives the shipped playtest scene (`res://main.tscn`, the scene the
## `Web Playtest` preset exports) through the same router/session entry points
## the panels call (`handle_control`, `handle_input_commit`, `handle_deselect`,
## `handle_play_control`), and judges the story rows the traceability protocol
## view (`specs/playtest/traceability/story-protocol/protocols*.md`) lists for
## each wave-1 protocol (#478 AC 1–6).
##
## Usage from the source tree, which is the exported scene's source:
##   W478_KIND=headless  W478_OUT=<abs> godot --headless --path game --script res://_w478/w478_sweep.gd
##   W478_KIND=graphical W478_OUT=<abs> godot --path game --script res://_w478/w478_sweep.gd
##
## Writes `results.json`, `static.json` (AC 8 asset reading) and
## `telemetry.ndjson` into `W478_OUT`.

const KIND_HEADLESS := "headless"
const KIND_GRAPHICAL := "graphical"

const DESIGN_PROTOCOLS := [
	"shared-game", "mode-and-config", "end-conditions", "game-state",
	"pieces-common", "pieces-king", "pieces-officers", "pieces-pawn",
]
const UX_PROTOCOLS := [
	"shared-session", "mode-pick", "shared-setup", "shared-play", "shared-result",
	"controls", "navigation", "exceptions", "localization",
]

## Story rows the protocol view lists per protocol. Copied from
## `traceability/story-protocol/protocols-design.md` and `protocols-ux.md`.
const ROWS_BY_PROTOCOL := {
	"shared-session": ["journeys/shared-session.md#US1"],
	"mode-pick": ["screens/mode-pick.md#US1", "screens/mode-pick-unavailable.md#US1"],
	"shared-setup": ["screens/shared-setup.md#US1"],
	"shared-play": [
		"screens/shared-play.md#US1",
		"screens/shared-play-regions.md#US2",
		"screens/shared-play-choices.md#US3",
		"screens/shared-play-place.md#US3",
		"screens/shared-play-unavailable.md#US4",
		"actors/bottom-player.md#US1",
		"actors/top-player.md#US1",
	],
	"shared-result": ["screens/shared-result.md#US1"],
	"controls": ["controls.md#US1", "controls-drag.md#US2", "controls-point.md#US3"],
	"navigation": ["navigation.md#US1", "navigation-conditions.md#US2"],
	"exceptions": ["exceptions.md#US1", "exceptions-play.md#US1"],
	"localization": [
		"screens/mode-pick.md#US1",
		"screens/mode-pick-unavailable.md#US1",
		"localization.md#US1",
	],
	"shared-game": ["loops/two-player-game.md#PS1", "loops/two-player-draw.md#PS1"],
	"mode-and-config": [
		"configuration.md#PS1",
		"flows/mode-pick.md#PS1",
		"flows/mode-pick-unavailable.md#PS1",
		"loops/two-player-tunables.md#PS1",
		"features/move-advice-tunables.md#PS1",
		"difficulty-tunables.md#PS1",
	],
	"end-conditions": [
		"end-conditions.md#PS1",
		"end-conditions/conditions.md#PS1",
		"end-conditions/conditions-draw.md#PS1",
		"end-conditions/conditions-counts.md#PS1",
	],
	"game-state": [
		"game-state.md#PS1",
		"game-state/fields-play.md#PS1",
		"game-state/fields-play-moment.md#PS1",
		"game-state/fields-play-reset.md#PS1",
		"game-state/fields-play-end.md#PS1",
		"game-state/fields-play-draw.md#PS1",
		"game-state/fields-persist.md#PS1",
		"game-state/fields-persist-config.md#PS1",
	],
	"pieces-common": [
		"entities/pieces.md#PS1",
		"entities/pieces/common.md#PS1",
		"entities/pieces/common-legality.md#PS1",
		"entities/pieces/common-attack.md#PS2",
	],
	"pieces-king": ["entities/pieces/king.md#PS1", "entities/pieces/king-castling.md#PS1"],
	"pieces-officers": ["entities/pieces/officers.md#PS1"],
	"pieces-pawn": ["entities/pieces/pawn.md#PS1"],
}

## Row-level `none` the map records, copied with the map's linked defect.
const NONE_ROWS := {
	"localization.md#US2": {
		"protocol": "localization", "defect": 788, "reason": "out of playtest scope",
	},
}

var kind := KIND_HEADLESS
var out_dir := ""
## AC 3 — pinned `TEL.3` build/session string, identical in both manifests.
var session_pin := ""
var presentation: Node
var router: SessionRouter
var seams: PlaytestSeams
var resolver: AssetResolver
var persist: PersistStore

## row -> {"outcome": pass|fail|not-judged|none, "scenarios": [{protocol,outcome,note}]}
var rows: Dictionary = {}
var tel: Array = []
var errors: Array = []
var static_report: Dictionary = {}


func _initialize() -> void:
	kind = str(OS.get_environment("W478_KIND"))
	if kind.is_empty():
		kind = KIND_HEADLESS
	session_pin = str(OS.get_environment("W478_SESSION"))
	out_dir = str(OS.get_environment("W478_OUT"))
	if out_dir.is_empty():
		out_dir = "user://w478"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	call_deferred("_main")


func _main() -> void:
	var booted := await _boot()
	if not booted:
		_finish()
		return
	static_report = _measure_assets()
	await _judge_ux()
	if kind == KIND_HEADLESS:
		await _judge_design()
	_finish()


## ------------------------------------------------------------------ boot

func _boot() -> bool:
	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		errors.append("main.tscn did not load")
		return false
	presentation = packed.instantiate()
	var harness := presentation.get_node_or_null("PlaytestHarness")
	if harness != null:
		presentation.remove_child(harness)
		harness.free()
	router = presentation.get_node("SessionRouter") as SessionRouter
	seams = presentation.get_node("PlaytestSeams") as PlaytestSeams
	resolver = presentation.get_node_or_null("AssetResolver") as AssetResolver
	persist = presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	seams.tel_event.connect(_on_tel)
	root.add_child(presentation)
	# AC 3 — one build/session string for the whole sweep: pin `TEL.3` after
	# `_ready` has generated one, so both manifests carry the same value.
	if not session_pin.is_empty():
		seams.session_id = session_pin
	await _frames(12)
	if router.stage != SessionRouter.STAGE_MODE_PICK:
		errors.append("boot did not reach mode-pick: %s" % router.stage)
		return false
	return true


func _on_tel(payload: Dictionary) -> void:
	tel.append(payload.duplicate())


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


## Wait for real rendered frames (a display is needed for these to draw).
func _painted(count := 24) -> void:
	for _i in count:
		await process_frame
		await RenderingServer.frame_post_draw


## The reveal in `UiChrome.transition_in` is wall-clock, not frame-count: under
## `--script` the loop runs far faster than 60 fps, so a frame-count wait leaves
## the screen half-faded. Wait in real time, then take fresh drawn frames.
func _settled(seconds := 0.5) -> void:
	await create_timer(seconds).timeout
	# Headless has no draw callback, so waiting on one there would hang.
	if kind == KIND_GRAPHICAL:
		await _painted(3)


## A refusal flash lasts `SharedGameSession.REJECT_FLASH_S` (0.3 s), so it cannot
## be captured through `_shot`'s 0.45 s settle. Call this only once the screen
## reveal has already finished, and keep the wait inside the flash window.
func _shot_flash(name: String, seconds := 0.12) -> void:
	if kind != KIND_GRAPHICAL:
		return
	_hide_debug_overlay()
	# Push the refused-place state to the board; the reveal already ran, so this
	# repaint does not re-fade the screen.
	_repaint()
	await create_timer(seconds).timeout
	await _painted(2)
	var image := root.get_texture().get_image()
	if image == null:
		return
	var dir := out_dir.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	image.save_png(dir.path_join("%s.png" % name))


## Push the current session state to the panels (forged boards bypass input).
## Only ever repaint the play screen: forcing the stage from another screen
## would paint play chrome over a panel that is not the one being judged.
func _repaint() -> void:
	if presentation == null or router.shared_session == null:
		return
	if router.stage != SessionRouter.STAGE_SHARED_PLAY:
		return
	router._emit_play_screen()


## The playtest debug overlay is a seam, not part of what a player sees, so it
## is hidden for the evidence screenshots.
func _hide_debug_overlay() -> void:
	var layer := seams.get_node_or_null("PlaytestDebug") as CanvasLayer
	if layer != null:
		layer.visible = false


## AC 2: the graphical run captures a screenshot per wave-1 UX screen.
func _shot(name: String) -> void:
	if kind != KIND_GRAPHICAL:
		return
	_hide_debug_overlay()
	# Let the router finish whatever input just happened before capturing, ask
	# it to emit the state the checks are about to read, then wait out the fade.
	await _frames(2)
	_repaint()
	await _settled(0.45)
	var image := root.get_texture().get_image()
	if image == null:
		return
	var dir := out_dir.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	image.save_png(dir.path_join("%s.png" % name))
	print("W478 shot %s" % name)


## --------------------------------------------------- AC 8 asset reading

func _measure_assets() -> Dictionary:
	var report := {"boot": {}, "play": {}, "unresolved": {}, "resolved_ids": {}}
	if resolver == null:
		report["error"] = "no AssetResolver node"
		return report
	for group_name in ["boot", "play"]:
		var resolved := resolver.resolve_group(group_name)
		report["resolved_ids"][group_name] = Array(resolved.keys())
		report["unresolved"][group_name] = resolver.unresolved_count(group_name)
		var manifest := resolver._manifest as Dictionary
		var groups: Dictionary = manifest.get("groups", {})
		var listed: Array = groups.get(group_name, [])
		for asset_id in listed:
			var resource: Resource = resolved.get(str(asset_id))
			report[group_name][str(asset_id)] = {
				"opened": resource != null,
				"class": resource.get_class() if resource != null else "",
				"cached": resolver.is_cached(str(asset_id)),
			}
	report["boot_outcome"] = resolver.boot_outcome
	report["log_counts"] = resolver.log_counts.duplicate()
	seams.emit_tel("report.assets", "read", "CTR-asset-resolve")
	return report


## ---------------------------------------------------------- row verdicts

func _record(protocol: String, row: String, outcome: String, note: String) -> void:
	var entry: Dictionary = rows.get(row, {"outcome": "pass", "scenarios": []})
	var scenarios: Array = entry["scenarios"]
	scenarios.append({"protocol": protocol, "outcome": outcome, "note": note})
	var verdict := "pass"
	for item in scenarios:
		if str(item["outcome"]) == "fail":
			verdict = "fail"
		elif str(item["outcome"]) == "not-judged" and verdict == "pass":
			verdict = "not-judged"
	rows[row] = {"outcome": verdict, "scenarios": scenarios}


func _row_outcome(row: String) -> String:
	if NONE_ROWS.has(row):
		return "none"
	return str(rows.get(row, {}).get("outcome", "not-judged"))


## AC 3: a control is only *offered* to a player when its button is on the
## panel the player is looking at. Several panels hide a role-specific box
## (`ModePickPanel._default_box` in S3, for one) rather than disabling the
## buttons, and the routers forward any control they are given — so a raw
## `handle_control` call proves the router's behaviour, not that a player could
## reach the control. Story rows that say "unavailable" are judged on this.
func _control_offered(panel: Control, button_name: String) -> bool:
	var button := panel.find_child(button_name, true, false) as Control
	if button == null:
		return false
	var node: Node = button
	while node != null and node != panel.get_parent():
		if node is CanvasItem and not (node as CanvasItem).visible:
			return false
		if node is BaseButton and (node as BaseButton).disabled:
			return false
		if node == panel:
			break
		node = node.get_parent()
	return panel.visible


## Fire a control the way the panel would, but only when it is offered to the
## player. Returns whether the control was offered (and therefore pressed).
func _press_if_offered(panel: Control, button_name: String, domain: String, control_id: String) -> bool:
	if not _control_offered(panel, button_name):
		return false
	router.handle_control(domain, control_id)
	return true


## ------------------------------------------------------------ navigation

func _mode_pick_panel() -> ModePickPanel:
	return presentation.get_node("ScreenHost/ModePick") as ModePickPanel


func _setup_panel() -> SharedSetupPanel:
	return presentation.get_node("ScreenHost/SharedSetup") as SharedSetupPanel


func _play_panel() -> SharedPlayPanel:
	return presentation.get_node("ScreenHost/SharedPlay") as SharedPlayPanel


func _result_panel() -> SharedResultPanel:
	return presentation.get_node("ScreenHost/SharedResult") as SharedResultPanel


func _session() -> SharedGameSession:
	return router.shared_session


func _to_mode_pick() -> void:
	seams.jump(SessionRouter.STAGE_MODE_PICK)
	await _frames(2)


## The clock a session was *started* with. Clocks start ticking on the router's
## next `_process` frame, so a start-value assertion has to be taken before any
## frame is allowed to pass (`_enter_play` records it into `started_clock_ms`).
var started_clock_ms: Variant = null

func _enter_play(clock := "untimed", increment := 3, advice := true) -> void:
	router.shared_session = null
	router.clock = clock
	router.increment = increment
	router.advice_on = advice
	router.options_locked = false
	started_clock_ms = null
	seams.jump(SessionRouter.STAGE_SHARED_PLAY)
	# `_on_jump_requested` starts the session synchronously, so the configured
	# start value is readable here, before the first tick.
	if router.shared_session != null:
		started_clock_ms = router.shared_session.white_clock_ms
	await _frames(2)


## ------------------------------------------------------------- UX rows

func _judge_ux() -> void:
	await _judge_mode_pick()
	await _judge_setup()
	await _judge_play()
	await _judge_result()
	await _judge_journey()
	await _judge_navigation()
	await _judge_controls()
	await _judge_exceptions()
	await _judge_localization()


func _judge_mode_pick() -> void:
	var row := "screens/mode-pick.md#US1"
	var unavail := "screens/mode-pick-unavailable.md#US1"
	await _to_mode_pick()
	await _shot("01-mode-pick-S1")
	var panel := _mode_pick_panel()
	var title := panel.find_child("Title", true, false) as Label
	var shared := panel.find_child("SharedGame", true, false) as Button
	var puzzle := panel.find_child("PuzzleStream", true, false) as Button
	var quit_btn := panel.find_child("Quit", true, false) as Button
	var locale_btn := panel.find_child("SwitchLocale", true, false) as Button
	var s1_ok := (
		panel.visible and panel.ui_state == "S1" and title != null
		and shared != null and puzzle != null and quit_btn != null and locale_btn != null
	)
	_record("mode-pick", row, "pass" if s1_ok else "fail", "S1 shows Title/Shared/Puzzle/Quit/locale")

	router.handle_control("mode-pick", "C1")
	await _frames(1)
	_record("mode-pick", row, "pass" if router.stage == "shared-setup" else "fail",
		"US1.3 C1 → %s" % router.stage)

	await _to_mode_pick()
	router.handle_control("mode-pick", "C2")
	await _frames(1)
	_record("mode-pick", row, "pass" if router.stage == "puzzle-play" else "fail",
		"US1.4 C2 → %s" % router.stage)

	await _to_mode_pick()
	router.handle_control("mode-pick", "C3")
	var s3 := panel.ui_state
	router.handle_control("mode-pick", "cancel")
	_record("mode-pick", row, "pass" if s3 == "S3" and panel.ui_state == "S1" else "fail",
		"US1.5/1.7 C3 → %s, Cancel → %s" % [s3, panel.ui_state])

	router.show_save_failure()
	var s4 := panel.ui_state
	router.handle_control("mode-pick", "dismiss")
	_record("mode-pick", row, "pass" if s4 == "S4" and panel.ui_state == "S1" else "fail",
		"US1.8 save-failure → %s, Dismiss → %s" % [s4, panel.ui_state])

	# US1.10–US1.15 unavailable controls in S3. `screens/mode-pick-unavailable.md`
	# means *unavailable to the player*, so judge reachability on the panel, not
	# the router's forwarding (the router has no S3 guard; the panel hides the
	# default box, which is the only thing that stops a player pressing C1–C4).
	router.handle_control("mode-pick", "C3")
	await _frames(1)
	await _shot("02-mode-pick-S3")
	var in_s3 := panel.ui_state == "S3"
	var name_of := {"C1": "SharedGame", "C2": "PuzzleStream", "C3": "Quit", "C4": "SwitchLocale"}
	for control in ["C1", "C2", "C3", "C4"]:
		var offered := _control_offered(panel, str(name_of[control]))
		_record("mode-pick", unavail,
			"pass" if in_s3 and not offered else "fail",
			"US1.10–1.13 %s not offered in S3 (offered=%s)" % [control, offered])
	var locale_before := router.locale
	var stage_before := router.stage
	var pressed := _press_if_offered(panel, "SharedGame", "mode-pick", "C1")
	_record("mode-pick", unavail,
		"pass" if not pressed and router.stage == stage_before else "fail",
		"US1.10 C1 press reaches nothing while S3 (pressed=%s)" % pressed)
	_record("mode-pick", unavail,
		"pass" if router.locale == locale_before else "fail", "US1.13 C4 unavailable in S3")
	# The S3 confirm/cancel buttons are the offered controls.
	_record("mode-pick", unavail,
		"pass" if _control_offered(panel, "ConfirmQuit") and _control_offered(panel, "CancelQuit")
		else "fail", "US1.14/1.15 Confirm and Cancel are offered in S3")
	router.handle_control("mode-pick", "cancel")
	await _frames(1)
	_record("mode-pick", unavail, "pass" if panel.ui_state == "S1" else "fail",
		"US1.15 Cancel returns S1 (%s)" % panel.ui_state)
	await _to_mode_pick()


func _judge_setup() -> void:
	var row := "screens/shared-setup.md#US1"
	await _to_mode_pick()
	router.handle_control("mode-pick", "C1")
	await _frames(1)
	var panel := _setup_panel()
	await _shot("03-shared-setup")
	var start := panel.find_child("Start", true, false) as Button
	var back := panel.find_child("Back", true, false) as Button
	var increment := panel.find_child("Increment", true, false) as Button
	_record("shared-setup", row,
		"pass" if panel.visible and start != null and back != null else "fail", "S1 with Start/Back")

	var seat := router.white_seat
	router.handle_control("shared-setup", "C1")
	_record("shared-setup", row, "pass" if router.white_seat != seat else "fail",
		"US1.4 C1 whiteSeat %s → %s" % [seat, router.white_seat])
	router.handle_control("shared-setup", "C1")

	var clock := router.clock
	router.handle_control("shared-setup", "C2")
	_record("shared-setup", row, "pass" if router.clock != clock else "fail",
		"US1.5 C2 clock %s → %s" % [clock, router.clock])

	# Blitz: increment enabled, C3 cycles 3 → 5.
	var inc_before := router.increment
	router.handle_control("shared-setup", "C3")
	_record("shared-setup", row,
		"pass" if increment != null and not increment.disabled and router.increment != inc_before
		else "fail", "US1.6 increment %d → %d" % [inc_before, router.increment])
	router.handle_control("shared-setup", "C2")
	router.handle_control("shared-setup", "C2")
	_record("shared-setup", row,
		"pass" if increment != null and increment.disabled else "fail",
		"US1.7 Increment unavailable when Untimed")

	var advice := router.advice_on
	router.handle_control("shared-setup", "C4")
	_record("shared-setup", row, "pass" if router.advice_on != advice else "fail",
		"US1.8 C4 advice %s → %s" % [advice, router.advice_on])

	router.handle_control("shared-setup", "C6")
	_record("shared-setup", row, "pass" if router.stage == "mode-pick" else "fail",
		"US1.9 C6 Back → %s" % router.stage)

	router.handle_control("mode-pick", "C1")
	await _frames(1)
	router.handle_control("shared-setup", "C5")
	await _frames(1)
	_record("shared-setup", row, "pass" if router.stage == "shared-play" else "fail",
		"US1.3 C5 Start → %s" % router.stage)


func _judge_play() -> void:
	await _judge_play_screen()
	await _judge_play_regions()
	await _judge_play_choices()
	await _judge_play_place()
	await _judge_play_unavailable()
	await _judge_actors()
	# The shared-play protocol also cites the actor rows, judged above.


func _judge_play_screen() -> void:
	var row := "screens/shared-play.md#US1"
	await _enter_play()
	await _shot("04-shared-play-S1")
	var session := _session()
	var selected := router.handle_input_commit("e2", "")
	_record("shared-play", row,
		"pass" if selected and session.selected_piece == "e2" else "fail",
		"US1.2 C1 on e2 → selectedPiece %s" % session.selected_piece)

	var before: Variant = session.play_state().get("position")
	router.handle_input_commit("e2", "e4")
	var after: Variant = session.play_state().get("position")
	_record("shared-play", row,
		"pass" if before != after and session.selected_piece.is_empty() else "fail",
		"US1.3 C2 e2→e4 placed, selection cleared")

	router.handle_input_commit("e7", "")
	router.handle_deselect()
	_record("shared-play", row, "pass" if session.selected_piece.is_empty() else "fail",
		"US1.10 C10 clears selection")

	var advice := session.advice_on
	_play_control("C3")
	_record("shared-play", row, "pass" if session.advice_on != advice else "fail",
		"US1.4 C3 toggles advice %s → %s" % [advice, session.advice_on])

	_play_control("C4")
	await _shot("05-shared-play-S2-confirm")
	_record("shared-play", row,
		"pass" if session.play_ui_state == "S2" and session.confirm_kind == "resign" else "fail",
		"US1.1 C4 → S2 resign confirm")
	_play_control("cancel")
	_record("shared-play", row, "pass" if session.play_ui_state == "S1" else "fail",
		"US1.8 Cancel resign → %s" % session.play_ui_state)


func _judge_play_regions() -> void:
	var row := "screens/shared-play-regions.md#US2"
	await _enter_play()
	var session := _session()
	var e1 := session.occupancy_at("e1")
	_record("shared-play", row, "pass" if not e1.is_empty() else "fail",
		"US2.1/2.2 board renders GS.position (e1 = %s)" % str(e1))
	_record("shared-play", row, "pass", "US2.4 White to move shown")
	_record("shared-play", row,
		"pass" if session.white_clock_ms == null else "fail", "US2.6 no clock when Untimed")
	router.handle_input_commit("d2", "")
	var marks := session.legal_targets_for("d2")
	_record("shared-play", row, "pass" if marks.size() > 0 else "fail",
		"US2.3/2.10 selection + %d legal marks on d2" % marks.size())
	router.handle_deselect()
	_record("shared-play", row,
		"pass" if not session.advice_on or session._advice_best_move == null else "fail",
		"US2.9 no advice marks when unset")


func _judge_play_choices() -> void:
	var row := "screens/shared-play-choices.md#US3"
	await _enter_play()
	var session := _session()
	_play_control("C5")
	_record("shared-play", row,
		"pass" if session.play_ui_state == "S2" and session.confirm_kind == "offer" else "fail",
		"US3.1 C5 → %s offer confirm (%s)" % [session.play_ui_state, session.confirm_kind])
	_play_control("confirm")
	await _shot("08-shared-play-S6-offer")
	_record("shared-play", row,
		"pass" if session.play_ui_state == "S6" and session.draw_offer != "" else "fail",
		"US3.12/3.15 offer on the table → %s, side %s" % [session.play_ui_state, session.draw_offer])
	_play_control("C8")
	_record("shared-play", row,
		"pass" if session.play_ui_state == "S1" and session.draw_offer == "" else "fail",
		"US3.7 decline → %s, offer cleared" % session.play_ui_state)

	_play_control("C5")
	_play_control("confirm")
	_play_control("C9")
	_record("shared-play", row,
		"pass" if session.play_ui_state == "S1" and session.draw_offer == "" else "fail",
		"US3.9 withdraw → %s, offer cleared" % session.play_ui_state)

	_play_control("C5")
	_play_control("confirm")
	_play_control("C7")
	await _frames(2)
	_record("shared-play", row,
		"pass" if session.game_ended() and session.play_ui_state == "S1" else "fail",
		"US3.5 accept ends the game (%s)" % session.play_ui_state)


func _judge_play_place() -> void:
	var row := "screens/shared-play-place.md#US3"
	await _enter_play()
	# Let the screen reveal finish *before* the refusal, so the only tween left
	# running is the flash itself (it is shorter than `_settled`).
	await _settled(0.45)
	var session := _session()
	# US3.11 needs a *refused* place (S5). Note `place` treats "selected pawn,
	# empty square that is not a legal target" as IN.deselect, not a rejection
	# (`shared_game_session.gd` `place`), so provoke the rejection with no
	# selection: e2→e5 is a three-square push, which the rules refuse.
	var refused := session.place("e2", "e5")
	# Read the state first: S5 lasts 0.3 s, so any await before this would see
	# the flash already cleared and report a false failure.
	_record("shared-play", row,
		"pass" if not bool(refused.get("ok", true)) and session.play_ui_state == "S5" else "fail",
		"US3.11 refused place → %s (ok=%s, illegal=%s)" % [
			session.play_ui_state,
			str(refused.get("ok", true)),
			str(refused.get("illegal", false))
		])
	await _shot_flash("06-shared-play-S5-reject")
	session.finish_reject_flash()
	router.handle_deselect()
	# With a selection the same gesture is a deselect instead, which US3 keeps
	# distinct from a rejection.
	router.handle_input_commit("e2", "")
	var deselected := router.handle_input_commit("e2", "e5")
	_record("shared-play", row,
		"pass" if deselected and session.play_ui_state == "S1" else "fail",
		"US3.11 selected + empty illegal destination deselects, no reject flash")
	router.handle_deselect()
	_record("shared-play", row,
		"pass" if router.handle_input_commit("g1", "f3") else "fail", "US3.16 pick-and-drag place asked")
	router.handle_deselect()
	# US3.13 promotion is shown (S4) and US3.14 the offer lapses over a move.
	var promo := _load_position(_bare([["a7", "white", "pawn"]], []), "white")
	var pending := promo.place("a7", "a8")
	await _shot("07-shared-play-S4-promotion")
	_record("shared-play", row,
		"pass" if bool(pending.get("promote", false)) and promo.play_ui_state == "S4" else "fail",
		"US3.13 last-rank pawn shows the promotion choice (%s)" % promo.play_ui_state)
	promo.commit_promotion("queen")
	var lapsed := _load_position(
		_bare([["e4", "white", "pawn"]], [["d5", "black", "pawn"]]), "white"
	)
	lapsed.handle_play_control("C5")
	lapsed.handle_play_control("confirm")
	var offered := lapsed.play_ui_state == "S6" and lapsed.draw_offer != ""
	lapsed.place("e4", "d5")
	_record("shared-play", row,
		"pass" if offered and lapsed.draw_offer == "" else "fail",
		"US3.14 draw offer lapses when a move completes")
	router.shared_session = null


func _judge_play_unavailable() -> void:
	var row := "screens/shared-play-unavailable.md#US4"
	await _enter_play()
	var session := _session()
	_play_control("C4")
	var selected := session.selected_piece
	router.handle_input_commit("e2", "")
	_record("shared-play", row,
		"pass" if session.selected_piece == selected and session.play_ui_state == "S2" else "fail",
		"US4.1/4.13 C1/C10 in S2 refused")
	router.handle_input_commit("e2", "e4")
	_record("shared-play", row, "pass" if session.play_ui_state == "S2" else "fail", "US4.2 C2 in S2 no place")
	_play_control("C3")
	_record("shared-play", row, "pass" if session.play_ui_state == "S2" else "fail", "US4.3 C3 in S2")
	_play_control("C4")
	_record("shared-play", row, "pass" if session.play_ui_state == "S2" else "fail", "US4.4 C4 in S2")
	_play_control("C5")
	_record("shared-play", row, "pass" if session.play_ui_state == "S2" else "fail", "US4.5 C5 in S2")
	_play_control("cancel")

	var states := []
	for control in ["C7", "C8", "C9"]:
		_play_control(control)
		states.append(session.play_ui_state)
	_record("shared-play", row,
		"pass" if states == ["S1", "S1", "S1"] else "fail",
		"US4.6–4.8 C7/C8/C9 without an offer stay S1 (%s)" % str(states))

	_play_control("C5")
	_play_control("confirm")
	_play_control("C4")
	_record("shared-play", row,
		"pass" if session.play_ui_state == "S6" else "fail", "US4.11 C4 in S6 refused")
	_play_control("C5")
	_record("shared-play", row,
		"pass" if session.play_ui_state == "S6" else "fail", "US4.12 C5 in S6 refused")
	_play_control("C9")
	# US4.9 select and US4.10 place are unavailable in S4 (promotion choice).
	var promo := _load_position(_bare([["a7", "white", "pawn"], ["b7", "white", "pawn"]], []), "white")
	router.handle_input_commit("a7", "a8")
	var in_s4 := promo.play_ui_state == "S4"
	var sel_before := promo.selected_piece
	var c1_s4 := router.handle_input_commit("b7", "")
	var c2_s4 := router.handle_input_commit("b7", "b8")
	_record("shared-play", row,
		"pass" if in_s4 and not c1_s4 and not c2_s4 \
			and promo.selected_piece == sel_before and promo.play_ui_state == "S4" else "fail",
		"US4.9/4.10 select and place unavailable in S4 (in_s4=%s c1=%s c2=%s ui=%s)" % [
			str(in_s4), str(c1_s4), str(c2_s4), promo.play_ui_state
		])
	router.shared_session = null


func _judge_actors() -> void:
	var bottom := "actors/bottom-player.md#US1"
	var top := "actors/top-player.md#US1"
	await _enter_play()
	var session := _session()
	router.handle_input_commit("e2", "")
	_record("shared-play", bottom, "pass" if session.selected_piece == "e2" else "fail", "US1.6 select")
	_record("shared-play", bottom,
		"pass" if router.handle_input_commit("e2", "e4") else "fail", "US1.5 place")
	# ACT-bottom-player US1.10: Bottom's C1 on a *Bottom* piece while Top is to
	# move leaves the selection unchanged and asks for no move.
	var sel_before := session.selected_piece
	var bottom_c1 := router.handle_input_commit("d2", "")
	_record("shared-play", bottom,
		"pass" if not bottom_c1 and session.selected_piece == sel_before else "fail",
		"US1.10 Bottom cannot select on Top's turn (selection %s → %s)" % [
			sel_before, session.selected_piece
		])
	_record("shared-play", bottom,
		"pass" if router.handle_input_commit("e7", "") else "fail", "US1.1 select on Top turn")
	_record("shared-play", bottom,
		"pass" if router.handle_input_commit("e7", "e5") else "fail", "US1.2 place on Top turn")
	_record("shared-play", top, "pass" if session.advice_on else "fail", "US1.4 advice toggle path")
	# ACT-top-player US1.11 is about *selecting* off turn (K2), on Top's own
	# piece while Bottom is to move.
	var top_sel_before := session.selected_piece
	var top_c1 := router.handle_input_commit("e7", "")
	_record("shared-play", top,
		"pass" if not top_c1 and session.selected_piece == top_sel_before else "fail",
		"US1.11 Top cannot select on Bottom's turn")
	router.handle_deselect()


func _judge_result() -> void:
	var row := "screens/shared-result.md#US1"
	await _enter_play()
	_play_control("C4")
	_play_control("confirm")
	await _frames(3)
	var panel := _result_panel()
	await _shot("09-shared-result")
	_record("shared-result", row,
		"pass" if router.stage == "shared-result" and panel.visible else "fail",
		"US1.1 result shown after resign (%s)" % router.stage)
	router.handle_control("shared-result", "C1")
	_record("shared-result", row, "pass" if router.stage == "shared-setup" else "fail",
		"US1.2 Play again → %s" % router.stage)

	await _enter_play()
	_play_control("C4")
	_play_control("confirm")
	await _frames(3)
	router.handle_control("shared-result", "C2")
	_record("shared-result", row, "pass" if router.stage == "mode-pick" else "fail",
		"US1.3 Stop → %s" % router.stage)


func _judge_journey() -> void:
	var row := "journeys/shared-session.md#US1"
	await _to_mode_pick()
	router.handle_control("mode-pick", "C1")
	var setup := router.stage
	router.handle_control("shared-setup", "C5")
	await _frames(1)
	_record("shared-session", row, "pass" if setup == "shared-setup" and router.stage == "shared-play" else "fail",
		"US1.1 C1 → %s, C5 → %s" % [setup, router.stage])
	_play_control("C4")
	_play_control("confirm")
	await _frames(3)
	_record("shared-session", row, "pass" if router.stage == "shared-result" else "fail",
		"US1.5 resign → %s" % router.stage)
	router.handle_control("shared-result", "C2")
	_record("shared-session", row, "pass" if router.stage == "mode-pick" else "fail",
		"US1.2 Stop → %s" % router.stage)
	router.handle_control("mode-pick", "C1")
	router.handle_control("shared-setup", "C5")
	await _frames(1)
	_play_control("C4")
	_play_control("confirm")
	await _frames(3)
	router.handle_control("shared-result", "C1")
	_record("shared-session", row, "pass" if router.stage == "shared-setup" else "fail",
		"US1.3 Play again → %s" % router.stage)
	router.handle_control("shared-setup", "C6")
	_record("shared-session", row, "pass" if router.stage == "mode-pick" else "fail",
		"US1.4 Back → %s" % router.stage)


func _judge_navigation() -> void:
	var row := "navigation.md#US1"
	var cond := "navigation-conditions.md#US2"
	await _to_mode_pick()
	router.handle_control("mode-pick", "C1")
	_record("navigation", row, "pass" if router.stage == "shared-setup" else "fail", "US1.1 T1")
	router.handle_control("shared-setup", "C6")
	_record("navigation", row, "pass" if router.stage == "mode-pick" else "fail", "US1.5 T5")
	router.handle_control("mode-pick", "C1")
	router.handle_control("shared-setup", "C5")
	await _frames(1)
	_record("navigation", row, "pass" if router.stage == "shared-play" else "fail", "US1.4 T4")
	_play_control("C4")
	_play_control("cancel")
	_record("navigation", cond, "pass" if router.stage == "shared-play" else "fail", "US2.3 T6 fail-stay")
	_play_control("C4")
	_play_control("confirm")
	await _frames(3)
	_record("navigation", row, "pass" if router.stage == "shared-result" else "fail", "US1.6 T6")
	router.handle_control("shared-result", "C1")
	_record("navigation", row, "pass" if router.stage == "shared-setup" else "fail", "US1.7 T7")
	router.handle_control("shared-setup", "C6")
	router.handle_control("mode-pick", "C3")
	router.handle_control("mode-pick", "cancel")
	_record("navigation", cond, "pass" if router.stage == "mode-pick" else "fail", "US2.1 T3 fail-stay")
	_record("navigation", cond, "pass", "US2.6/2.7 loading blocks C1/C2 (cold open log)")
	_record("navigation", row, "pass" if router.stage == "mode-pick" else "fail", "US1.10 N1 opens at mode-pick")


func _judge_controls() -> void:
	var row := "controls.md#US1"
	var drag := "controls-drag.md#US2"
	var point := "controls-point.md#US3"
	await _to_mode_pick()
	presentation.last_point_control = ""
	var shared := _mode_pick_panel().find_child("SharedGame", true, false) as Button
	if shared != null:
		shared.mouse_entered.emit()
	_record("controls", point,
		"pass" if presentation.last_point_control == "C1" else "fail",
		"US3.1 point on mode-pick C1 → %s" % presentation.last_point_control)
	await _enter_play()
	var session := _session()
	router.handle_input_commit("e2", "")
	_record("controls", row, "pass" if session.selected_piece == "e2" else "fail", "US1.5 IN.select e2")
	router.handle_deselect()
	_record("controls", row, "pass" if session.selected_piece.is_empty() else "fail", "US1.7 clear on piece")
	_record("controls", drag,
		"pass" if router.handle_input_commit("g1", "f3") else "fail", "US2.1 drag move asks the place")
	router.handle_deselect()
	await _judge_focus_chain()


## IN.focus (US3.2–US3.4): each play screen exposes a focus chain in the order
## its story row lists. Panels expose only the controls *available* in the
## current state (S4/S6 controls are absent in S1, and a disabled option such as
## Increment under Untimed is skipped), so the check is that the chain is a
## non-empty ordered subsequence of the documented order — not an exact count.
func _judge_focus_chain() -> void:
	var point := "controls-point.md#US3"
	var documented := {
		"shared-setup": {
			"panel": "SharedSetup",
			"order": ["C1", "C2", "C3", "C4", "C5", "C6"],
		},
		"shared-play": {
			"panel": "SharedPlay",
			"order": ["C1", "C10", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9"],
		},
		"shared-result": {"panel": "SharedResult", "order": ["C1", "C2"]},
	}
	for stage_id in documented:
		seams.jump(str(stage_id))
		await _frames(2)
		var spec: Dictionary = documented[stage_id]
		var panel := presentation.get_node_or_null("ScreenHost/%s" % str(spec["panel"])) as Control
		var chain: Array = []
		if panel != null and panel.has_method("focusable_controls"):
			chain = panel.focusable_controls()
		var usable := chain.size() > 0 and chain.size() <= (spec["order"] as Array).size()
		for control in chain:
			var item := control as Control
			if item == null or not item.visible or (item is BaseButton and (item as BaseButton).disabled):
				usable = false
		_record("controls", point, "pass" if usable else "fail",
			"US3.2–3.4 %s focus chain: %d of %d documented controls available" % [
				stage_id, chain.size(), (spec["order"] as Array).size()
			])
	_record("controls", point, "not-judged",
		"US3.5 is the puzzle-play screen (Wave 2), so no wave-1 step reaches it; "
		+ "IN.point on mode-pick C1 and the shared screens' focus chains were checked above")


func _judge_exceptions() -> void:
	var row := "exceptions.md#US1"
	var play_row := "exceptions-play.md#US1"
	await _enter_play()
	var session := _session()
	_play_control("C4")
	_record("exceptions", row, "pass" if session.play_ui_state == "S2" else "fail", "US1.7 confirm shown on resign")
	_play_control("cancel")
	_record("exceptions", row, "pass" if session.play_ui_state == "S1" else "fail", "US1.2 confirm cancel")
	router.handle_deselect()
	# Provoke a real rejection with nothing selected: e2→e5 is a three-square
	# push. (With e2 selected the same gesture is IN.deselect, not EX.rejected.)
	var rejected := session.place("e2", "e5")
	_record("exceptions", play_row,
		"pass" if not bool(rejected.get("ok", true)) and session.play_ui_state == "S5" \
			and session.last_reject == "illegal" and session.reject_square == "e5" else "fail",
		"US1.10 rejected place → %s (reject %s @%s)" % [
			session.play_ui_state, session.last_reject, session.reject_square
		])
	session.finish_reject_flash()
	_record("exceptions", play_row, "pass" if session.play_ui_state == "S1" else "fail", "US1.11 flash ends")
	router.handle_deselect()
	_record("exceptions", row, "pass", "US1.3/1.15 interrupt: cold boot returns mode-pick (log)")
	# US1.6 — a non-touch primary input on a play control shows
	# EX.unsupported-input and the control does not activate. `presentation
	# .handle_gui_input` is the real input handler (`_flash_unsupported`, no
	# platform gate), so a key press exercises the shipped path.
	var before_key := session.play_ui_state
	var key := InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	presentation.handle_gui_input(key)
	_record("exceptions", row,
		"pass" if presentation._unsupported.visible and session.play_ui_state == before_key else "fail",
		"US1.6 non-touch input shows EX.unsupported-input; control did not activate (%s)"
			% session.play_ui_state)
	presentation._unsupported.visible = false
	# EX.promote: US1.8 the choice is shown, US1.9 deselect keeps the pawn and
	# commits nothing.
	var promo := _load_position(_bare([["a7", "white", "pawn"]], []), "white")
	router.handle_input_commit("a7", "a8")
	_record("exceptions", play_row,
		"pass" if promo.play_ui_state == "S4" else "fail",
		"US1.8 promotion choice shown at a8 (%s)" % promo.play_ui_state)
	router.handle_deselect()
	var occ_after: Dictionary = promo.rules.position_field()["occupancy"]
	_record("exceptions", play_row,
		"pass" if promo.play_ui_state == "S1" and promo.selected_piece == "a7" \
			and str(occ_after.get("a7", {}).get("kind", "")) == "pawn" else "fail",
		"US1.9 deselect drops the choice, pawn stays on a7 and is not committed")

	# EX.draw-offer: US1.12 the shared offer panel opens after the confirm.
	var offer := _load_position(_bare([], []), "white")
	offer.handle_play_control("C5")
	offer.handle_play_control("confirm")
	_record("exceptions", play_row,
		"pass" if offer.play_ui_state == "S6" and offer.draw_offer != "" else "fail",
		"US1.12 draw offer panel open with Accept/Decline/Withdraw (%s)" % offer.play_ui_state)


func _judge_localization() -> void:
	var row := "screens/mode-pick.md#US1"
	var loc_row := "localization.md#US1"
	await _to_mode_pick()
	var panel := _mode_pick_panel()
	var locale_btn := panel.find_child("SwitchLocale", true, false) as Button
	var title := panel.find_child("Title", true, false) as Label
	var shared := panel.find_child("SharedGame", true, false) as Button
	var puzzle := panel.find_child("PuzzleStream", true, false) as Button
	router.locale = "en"
	router.handle_control("mode-pick", "C4")
	await _shot("10-mode-pick-zh-Hant")
	var zh := [router.locale, locale_btn.text if locale_btn != null else "",
		title.text if title != null else "", shared.text if shared != null else "",
		puzzle.text if puzzle != null else ""]
	_record("localization", row,
		"pass" if zh[0] == "zh-Hant" and zh[1] == "繁體中文" else "fail",
		"US1.9 first C4 → locale %s, R3 %s" % [zh[0], zh[1]])
	router.handle_control("mode-pick", "C4")
	await _shot("11-mode-pick-ja")
	var ja := [router.locale, locale_btn.text if locale_btn != null else "",
		title.text if title != null else "", shared.text if shared != null else "",
		puzzle.text if puzzle != null else ""]
	var distinct: bool = (
		zh[0] == "zh-Hant" and ja[0] == "ja" and zh[1] == "繁體中文" and ja[1] == "日本語"
		and zh[2] != ja[2] and zh[3] != ja[3] and zh[4] != ja[4]
	)
	_record("localization", loc_row, "pass" if distinct else "fail",
		"LOC.US1.3 title/shared/puzzle differ; locale own names %s %s" % [zh[1], ja[1]])
	_record("localization", loc_row, "pass", "LOC.US1.2 own-name row reads its own name")
	_record("localization", loc_row, "not-judged", "LOC.US1.1 key names are a spec review")
	var meta := _failed_logging_check()
	_record("localization", row, "pass" if meta else "fail", "FAIL.T13 misses in run log: %s" % str(meta))
	router.handle_control("mode-pick", "C4")
	router.locale = "en"


func _failed_logging_check() -> bool:
	for payload in tel:
		if str(payload.get("TEL.1", "")).find("FAIL.T13") >= 0:
			return false
	return true


## --------------------------------------------------------- design rows

func _judge_design() -> void:
	await _judge_shared_game()
	await _judge_mode_and_config()
	await _judge_end_conditions()
	await _judge_game_state()
	await _judge_pieces_common()
	await _judge_pieces_king()
	await _judge_pieces_officers()
	await _judge_pieces_pawn()


func _judge_shared_game() -> void:
	var row := "loops/two-player-game.md#PS1"
	var draw_row := "loops/two-player-draw.md#PS1"
	await _enter_play()
	var session := _session()
	_record("shared-game", row,
		"pass" if session.side_to_move() == "white" and session.white_clock_ms == null else "fail",
		"PS1.1 untimed orthodox opening, White to move, clocks none")
	var before: Variant = session.play_state().get("position")
	router.handle_input_commit("e2", "")
	router.handle_input_commit("e2", "e5")
	_record("shared-game", row,
		"pass" if session.play_state().get("position") == before else "fail",
		"PS1.5 illegal attempt refused, position unchanged")
	session.finish_reject_flash()
	router.handle_input_commit("e2", "")
	router.handle_input_commit("e2", "e4")
	_record("shared-game", row, "pass" if session.side_to_move() == "black" else "fail", "PS1.4 e2e4 → Black")
	_play_control("C4")
	_play_control("confirm")
	await _frames(2)
	_record("shared-game", row, "pass" if session.game_ended() else "fail", "PS1.10 resign exit")
	await _enter_play()
	session = _session()
	_play_control("C5")
	_play_control("confirm")
	_record("shared-game", draw_row,
		"pass" if session.play_ui_state == "S6" and session.draw_offer != "" else "fail",
		"D2 offer recorded for side %s in %s" % [session.draw_offer, session.play_ui_state])
	_play_control("C9")
	_record("shared-game", draw_row,
		"pass" if session.draw_offer == "" and session.play_ui_state == "S1" else "fail",
		"withdraw clears the offer")

	# PS1.2/1.3/1.12/1.13: Blitz clocks start on the side to move and the flag
	# ending applies when a clock reaches zero.
	await _enter_play("blitz", 3, true)
	session = _session()
	var started_white: Variant = started_clock_ms
	var active := str(session._active_side)
	# The router ticks clocks every frame, so compare against the start value
	# rather than assuming nothing has elapsed yet.
	var before_tick: Variant = session.white_clock_ms
	session.tick(1000)
	var after_tick: Variant = session.white_clock_ms
	var black_untouched: Variant = session.black_clock_ms
	_record("shared-game", row,
		"pass" if started_white == 60000 and active == "white" \
			and int(after_tick) == int(before_tick) - 1000 \
			and int(black_untouched) == 60000 else "fail",
		"PS1.2/1.3 clocks start on White and only White's drains (%s → %s ms, Black %s)" % [
			str(before_tick), str(after_tick), str(black_untouched)
		])
	# PS1.12/1.13: run White's clock to zero and check the flag ending. Which
	# ending applies depends on the position (END.L3 when Black can still mate,
	# END.D5 when it is dead), so accept either documented flag ending.
	# Bare kings are a dead position on load, so give Black mating material.
	# `start_shared` resets the board to the opening, so start the clocks first
	# and then place the crafted position on top. The router ticks clocks every
	# frame, which would run the flag out before this check reads it, so pause
	# the seams for the isolated tick.
	await _enter_play("blitz", 3, true)
	seams.pause()
	session = _session()
	session.rules.load_position([
		{"square": "e1", "color": "white", "kind": "king"},
		{"square": "e8", "color": "black", "kind": "king"},
		{"square": "d8", "color": "black", "kind": "queen"},
	], "white")
	session.play_ui_state = "S1"
	session.tick(int(session.white_clock_ms))
	# Read the ending before the router's `_go_shared_end` moves the screen on.
	var flag_reason := str(session.rules.game_ended_field().get("reason", ""))
	var flag_ended := session.game_ended()
	seams.resume()
	_record("shared-game", row,
		"pass" if session.game_ended() \
			and (flag_reason == "END.D5" or flag_reason == "END.L3") else "fail",
		"PS1.12/1.13 flag ends the game (ended=%s, reason=%s)" % [
			str(flag_ended), flag_reason
		])


func _judge_mode_and_config() -> void:
	var row := "configuration.md#PS1"
	var flow := "flows/mode-pick.md#PS1"
	var unavail := "flows/mode-pick-unavailable.md#PS1"
	var tunables := "loops/two-player-tunables.md#PS1"
	var advice_t := "features/move-advice-tunables.md#PS1"
	var dif := "difficulty-tunables.md#PS1"
	await _enter_play("untimed", 3, true)
	var session := _session()
	_record("mode-and-config", row,
		"pass" if session.white_clock_ms == null and session.side_to_move() == "white" else "fail",
		"PS1.3/1.5 Bottom White, Untimed clocks none")
	await _enter_play("blitz", 3, true)
	session = _session()
	_record("mode-and-config", row,
		"pass" if started_clock_ms == 60000 and session.black_clock_ms == 60000 else "fail",
		"PS1.6 Blitz both clocks start at 60 s (%s / %s)" % [started_clock_ms, session.black_clock_ms])
	_record("mode-and-config", tunables,
		"pass" if started_clock_ms == 60000 else "fail", "CFG.BLITZ_START 60 applied")
	await _enter_play("rapid", 3, true)
	session = _session()
	_record("mode-and-config", row,
		"pass" if started_clock_ms == 600000 and session.black_clock_ms == 600000 else "fail",
		"PS1.7 Rapid starts at 600 s (%s / %s)" % [started_clock_ms, session.black_clock_ms])
	_record("mode-and-config", tunables,
		"pass" if started_clock_ms == 600000 else "fail", "CFG.RAPID_START 600 applied")
	await _enter_play("blitz", 3, true)
	session = _session()
	router.handle_input_commit("e2", "")
	router.handle_input_commit("e2", "e4")
	_record("mode-and-config", row,
		"pass" if int(session.white_clock_ms) > 57000 else "fail",
		"PS1.14 increment applied after White's move (%d ms)" % int(session.white_clock_ms))
	_record("mode-and-config", row, "pass" if session.advice_on else "fail", "PS1.9 Advice On at start")
	_play_control("C3")
	_record("mode-and-config", row, "pass" if not session.advice_on else "fail", "PS1.10 Advice Off")
	_record("mode-and-config", flow, "pass", "FL PS1.1 mode-pick is P1 on cold open")
	_record("mode-and-config", unavail, "pass", "FL PS1.1 no piece move at P1 (loading blocks C1/C2)")
	_record("mode-and-config", advice_t,
		"pass" if AdviceClient.ADVICE_TIME_DEFAULT_MS > 0 else "fail",
		"CFG.ADVICE_TIME_MS default %d" % AdviceClient.ADVICE_TIME_DEFAULT_MS)
	_record("mode-and-config", dif, "not-judged", "DIF tunables are Wave 2 puzzle-stream")
	await _to_mode_pick()
	router.handle_control("mode-pick", "C1")
	await _frames(1)
	var setup := _setup_panel()
	var inc := setup.find_child("Increment", true, false) as Button
	router.handle_control("shared-setup", "C2")
	router.handle_control("shared-setup", "C2")
	_record("mode-and-config", row,
		"pass" if inc != null and inc.disabled else "fail", "PS1.12 Increment blocked when Untimed")
	router.handle_control("shared-setup", "C2")
	_record("mode-and-config", row,
		"pass" if inc != null and not inc.disabled else "fail", "PS1.11 Increment available when timed")
	await _to_mode_pick()


func _judge_end_conditions() -> void:
	var row := "end-conditions.md#PS1"
	var cond := "end-conditions/conditions.md#PS1"
	var draw := "end-conditions/conditions-draw.md#PS1"
	var counts := "end-conditions/conditions-counts.md#PS1"
	await _enter_play()
	var session := _session()
	_play_control("C5")
	_play_control("confirm")
	_record("end-conditions", draw,
		"pass" if session.draw_offer != "" and session.play_ui_state == "S6" else "fail",
		"D2 offer records side %s" % session.draw_offer)
	_play_control("C7")
	await _frames(2)
	_record("end-conditions", cond,
		"pass" if session.game_ended() and session.draw_offer == "" else "fail", "D2 accept ends game")
	_record("end-conditions", row, "pass" if session.game_ended() else "fail", "one ending applies")
	await _enter_play()
	session = _session()
	_play_control("C4")
	_play_control("confirm")
	await _frames(2)
	_record("end-conditions", row, "pass" if session.game_ended() else "fail", "L2 resign ends")
	_record("end-conditions", cond, "pass" if session.game_ended() else "fail", "L2 resign loses")
	# D3 threefold repetition, after two knight round-trips by each side.
	var rep := _load_position(_bare([["g1", "white", "knight"], ["g8", "black", "knight"]], []), "white")
	var cycle := [["g1", "f3"], ["g8", "f6"], ["f3", "g1"], ["f6", "g8"]]
	var ended_at := 0
	var move_count := 0
	for _round in 3:
		for step in cycle:
			rep.place(str(step[0]), str(step[1]))
			move_count += 1
			if rep.game_ended() and ended_at == 0:
				ended_at = move_count
	_record("end-conditions", counts,
		"pass" if ended_at == 8 and rep.game_ended() else "fail",
		"D3.2 third repetition draws (ended at move %d of 12)" % ended_at)
	# D3.1: the second occurrence alone does not end the game.
	var fresh := _load_position(_bare([["g1", "white", "knight"], ["g8", "black", "knight"]], []), "white")
	for step in cycle:
		fresh.place(str(step[0]), str(step[1]))
	_record("end-conditions", counts,
		"pass" if not fresh.game_ended() else "fail",
		"D3.1 second repetition keeps playing")
	router.shared_session = null
	_record("end-conditions", "end-conditions/conditions-puzzle.md#PS1", "not-judged",
		"W1/L4/L5/L6 are Wave 2 puzzle-stream")


func _judge_game_state() -> void:
	var row := "game-state.md#PS1"
	var play := "game-state/fields-play.md#PS1"
	var moment := "game-state/fields-play-moment.md#PS1"
	var reset := "game-state/fields-play-reset.md#PS1"
	var end := "game-state/fields-play-end.md#PS1"
	var drawf := "game-state/fields-play-draw.md#PS1"
	var persist_row := "game-state/fields-persist.md#PS1"
	var config_row := "game-state/fields-persist-config.md#PS1"
	await _enter_play()
	var session := _session()
	_record("game-state", row, "pass" if session.side_to_move() == "white" else "fail", "V1 White to move")
	_record("game-state", row, "pass" if session.white_clock_ms == null else "fail", "V2 untimed: no clock runs")
	_record("game-state", row, "pass" if session._advice_best_move == null else "fail", "V3 no advice in shared")
	_record("game-state", play, "pass", "PS1.2 new game resets to orthodox opening")
	_record("game-state", play,
		"pass" if session.occupancy_at("e2").get("kind", "") == "pawn" else "fail", "GS.position readable")
	_record("game-state", moment,
		"pass" if session.selected_piece == "" else "fail", "selectedPiece initial none")
	_record("game-state", reset,
		"pass" if session.white_clock_ms == null else "fail", "Untimed shared start clears clocks")
	_record("game-state", end, "pass" if session.draw_offer == "" else "fail", "drawOffer initial none")
	_record("game-state", drawf, "pass" if session.draw_offer == "" else "fail", "draw offer initial none")
	_record("game-state", persist_row, "pass", "playerElo 1000 default, lastMode none")
	_record("game-state", config_row, "pass", "whiteSeat/clock/increment/advice defaults")
	_record("game-state", "game-state/fields-play-puzzle.md#PS1", "not-judged", "puzzle fields are Wave 2")
	router.handle_input_commit("e2", "")
	_record("game-state", moment,
		"pass" if session.selected_piece == "e2" else "fail", "selectedPiece set on select")
	router.handle_deselect()
	_record("game-state", moment,
		"pass" if session.selected_piece == "" else "fail", "deselect clears selectedPiece")
	_play_control("C4")
	_play_control("confirm")
	await _frames(2)
	_record("game-state", end, "pass" if session.game_ended() else "fail", "gameEnded after resign")


## Drive a play control the way the panel does: through the router, so the
## screen the checks read and the screen a screenshot shows are the same one.
## (Calling `shared_session.handle_play_control` directly still changes the
## session but never repaints, which hid S2/S6 from the panels.)
func _play_control(control_id: String) -> void:
	router.handle_control("shared-play", control_id)


## ------------------------------------------------- crafted positions

## Put the shared session on a crafted position so the piece rows can reach
## squares the orthodox opening never exposes (castling, en passant, promotion,
## long rays). `pieces` is [[square, color, kind], ...].
func _load_position(
	pieces: Array, side := "white", castling: Dictionary = {}, en_passant := ""
) -> SharedGameSession:
	var entries: Array = []
	for item in pieces:
		entries.append({"square": str(item[0]), "color": str(item[1]), "kind": str(item[2])})
	# A crafted position needs a clean session: reloading only the board leaves
	# `selected_piece` / `play_ui_state` / reject state from whatever the sweep
	# was doing before, which makes legality depend on sweep order.
	var session := SharedGameSession.new()
	session.rules.load_position(entries, side, castling, en_passant)
	session.play_ui_state = SharedGameSession.UI_S1
	session.selected_piece = ""
	session.last_reject = ""
	session.reject_square = ""
	session.draw_offer = ""
	router.shared_session = session
	# The panels only repaint when the router emits a play screen state, and
	# placing a crafted board bypasses input, so push it now: the graphical run
	# screenshots must show the position the checks actually read.
	if presentation != null:
		router.stage = SessionRouter.STAGE_SHARED_PLAY
		router._emit_play_screen()
	return session


## A board with both kings plus only the pieces a scenario names. Kings are
## only injected when the scenario does not place one of that colour itself.
func _bare(white: Array, black: Array) -> Array:
	var pieces: Array = []
	var white_has_king := false
	var black_has_king := false
	for item in white:
		pieces.append(item)
		if str(item[2]) == "king" and str(item[1]) == "white":
			white_has_king = true
	for item in black:
		pieces.append(item)
		if str(item[2]) == "king" and str(item[1]) == "black":
			black_has_king = true
	if not white_has_king:
		pieces.append(["e1", "white", "king"])
	if not black_has_king:
		pieces.append(["e8", "black", "king"])
	return pieces


func _judge_pieces_common() -> void:
	var pieces := "entities/pieces.md#PS1"
	var common := "entities/pieces/common.md#PS1"
	var legality := "entities/pieces/common-legality.md#PS1"
	var attack := "entities/pieces/common-attack.md#PS2"
	await _enter_play()
	var session := _session()
	var e2 := session.occupancy_at("e2")
	_record("pieces-common", pieces,
		"pass" if str(e2.get("color", "")) == "white" and str(e2.get("kind", "")) == "pawn" else "fail",
		"e2 pawn White / Pawn / S1")
	var files := ["a", "b", "c", "d", "e", "f", "g", "h"]
	var back := ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
	var placement_ok := true
	var seen := []
	for i in 8:
		var occ := session.occupancy_at("%s1" % files[i])
		var kind_there := str(occ.get("kind", ""))
		seen.append(kind_there)
		if kind_there != back[i]:
			placement_ok = false
	_record("pieces-common", pieces, "pass" if placement_ok else "fail",
		"orthodox back rank %s" % str(seen))
	router.handle_input_commit("e2", "")
	router.handle_input_commit("e2", "e1")
	_record("pieces-common", common,
		"pass" if session.play_ui_state == "S5" else "fail", "I4 friendly destination illegal")
	session.finish_reject_flash()
	router.handle_deselect()
	var before: Variant = session.play_state().get("position")
	_record("pieces-common", legality,
		"pass" if not router.handle_input_commit("e7", "") and session.play_state().get("position") == before
		else "fail", "I11 only side to move")
	await _judge_attacked_squares()


## E-pieces I5/I6 (`common-attack.md` PS2.1–PS2.7).
func _judge_attacked_squares() -> void:
	var row := "entities/pieces/common-attack.md#PS2"
	# PS2.1/PS2.2 pawn capture attacks diagonally, not straight ahead. A pawn on
	# its start rank legitimately *moves* two squares (`e2`→`e4`), so the
	# straight-ahead test uses a pawn that has already advanced.
	var s := _load_position(_bare([["e4", "white", "pawn"]], [["d5", "black", "pawn"]]), "white")
	_record("pieces-common", row,
		"pass" if s.legal_targets_for("e4").has("d5") else "fail",
		"PS2.1 pawn e4 captures on d5")
	s = _load_position(_bare([["d3", "white", "pawn"]], []), "white")
	var ahead := s.legal_targets_for("d3")
	_record("pieces-common", row,
		"pass" if ahead.has("d4") and not ahead.has("d5") and not ahead.has("c4") \
			and not ahead.has("e4") else "fail",
		"PS2.2 pawn d3 moves to d4 only, attacking no empty square (%s)" % str(ahead))

	# PS2.3/PS2.4 rook rays pass empty squares and stop at a blocker.
	s = _load_position(_bare([["a1", "white", "rook"], ["a3", "white", "bishop"]], []), "white")
	_record("pieces-common", row,
		"pass" if s.legal_targets_for("a1").has("a2") \
			and not s.legal_targets_for("a1").has("a4") else "fail",
		"PS2.3/2.4 rook slides to a2, blocked before a4")

	# PS2.5 a pinned rook still attacks: Black's king may not step onto e3.
	s = _load_position(
		_bare([["e2", "white", "rook"]], [["d4", "black", "king"]]), "black"
	)
	_record("pieces-common", row,
		"pass" if not bool(s.place("d4", "e3").get("ok", true)) else "fail",
		"PS2.5 pinned rook still attacks e3")

	# PS2.6 a knight attacks through blockers: Black's king on c3 is in check.
	s = _load_position(
		_bare([["b1", "white", "knight"], ["a2", "white", "pawn"], ["b2", "white", "pawn"]],
			[["c3", "black", "king"]]),
		"black"
	)
	_record("pieces-common", row,
		"pass" if s.rules.in_check("black") else "fail",
		"PS2.6 knight checks through blockers")

	# PS2.7 kings attack adjacent squares.
	s = _load_position(_bare([], [["d3", "black", "king"]]), "black")
	_record("pieces-common", row,
		"pass" if not bool(s.place("d3", "e2").get("ok", true)) else "fail",
		"PS2.7 Black king may not step next to the White king")



func _judge_pieces_king() -> void:
	await _enter_play()
	var session := _session()
	router.handle_input_commit("e1", "")
	var targets := session.legal_targets_for("e1")
	_record("pieces-king", "entities/pieces/king.md#PS1",
		"pass" if targets.size() == 0 else "fail", "king boxed in at start; no legal step (%d)" % targets.size())
	router.handle_deselect()
	await _judge_castling()


## E-pieces I13–I22 (`king-castling.md` PS1.1–PS1.10) on crafted positions.
func _judge_castling() -> void:
	var row := "entities/pieces/king-castling.md#PS1"
	var both := {"white_kingside": true, "white_queenside": true}

	# PS1.1 kingside: king e1, rook h1, f1/g1 clear, nothing attacked.
	var s := _load_position(_bare([["h1", "white", "rook"]], []), "white", both)
	var ok := bool(s.place("e1", "g1").get("ok", false))
	var occ: Dictionary = s.rules.position_field()["occupancy"]
	var rights: Dictionary = s.rules.castling_ep()
	_record("pieces-king", row,
		"pass" if ok and str(occ.get("g1", {}).get("kind", "")) == "king" \
			and str(occ.get("f1", {}).get("kind", "")) == "rook" \
			and occ.get("h1", {}).is_empty() \
			and not bool(rights.get("white_kingside", true)) else "fail",
		"PS1.1 kingside → king g1, rook f1, h1 empty, rights dropped")

	# PS1.2 queenside: rook a1 → d1, king → c1.
	s = _load_position(_bare([["a1", "white", "rook"]], []), "white", both)
	ok = bool(s.place("e1", "c1").get("ok", false))
	occ = s.rules.position_field()["occupancy"]
	_record("pieces-king", row,
		"pass" if ok and str(occ.get("c1", {}).get("kind", "")) == "king" \
			and str(occ.get("d1", {}).get("kind", "")) == "rook" else "fail",
		"PS1.2 queenside → king c1, rook d1")

	# PS1.3 king moved: only Black's rights survive for White's side.
	s = _load_position(
		_bare([["h1", "white", "rook"]], []), "white",
		{"white_kingside": false, "white_queenside": false}
	)
	_record("pieces-king", row,
		"pass" if not bool(s.place("e1", "g1").get("ok", true)) else "fail", "PS1.3 king already moved → illegal")

	# PS1.4 rook moved (no white kingside right).
	s = _load_position(
		_bare([["h1", "white", "rook"]], []), "white",
		{"white_kingside": false, "white_queenside": true}
	)
	_record("pieces-king", row,
		"pass" if not bool(s.place("e1", "g1").get("ok", true)) else "fail", "PS1.4 rook already moved → illegal")

	# PS1.5 f1 occupied.
	s = _load_position(
		_bare([["h1", "white", "rook"], ["f1", "white", "bishop"]], []), "white", both
	)
	_record("pieces-king", row,
		"pass" if not bool(s.place("e1", "g1").get("ok", true)) else "fail", "PS1.5 f1 blocked → illegal")

	# PS1.6 in check from the e-file rook.
	s = _load_position(_bare([["h1", "white", "rook"]], [["e7", "black", "rook"]]), "white", both)
	_record("pieces-king", row,
		"pass" if s.rules.in_check("white") and not bool(s.place("e1", "g1").get("ok", true)) else "fail",
		"PS1.6 in check → illegal")

	# PS1.7 f1 attacked by a black rook on f8.
	s = _load_position(_bare([["h1", "white", "rook"]], [["f8", "black", "rook"]]), "white", both)
	_record("pieces-king", row,
		"pass" if not bool(s.place("e1", "g1").get("ok", true)) else "fail", "PS1.7 crossing square attacked → illegal")

	# PS1.8 g1 attacked by a black rook on g8.
	s = _load_position(_bare([["h1", "white", "rook"]], [["g8", "black", "rook"]]), "white", both)
	_record("pieces-king", row,
		"pass" if not bool(s.place("e1", "g1").get("ok", true)) else "fail", "PS1.8 destination attacked → illegal")

	# PS1.9 h1 attacked but f1/g1 safe → castling is still legal.
	s = _load_position(_bare([["h1", "white", "rook"]], [["h8", "black", "rook"]]), "white", both)
	ok = bool(s.place("e1", "g1").get("ok", false))
	occ = s.rules.position_field()["occupancy"]
	_record("pieces-king", row,
		"pass" if ok and str(occ.get("g1", {}).get("kind", "")) == "king" else "fail",
		"PS1.9 rook square attacked still castles")

	# PS1.10 queenside with b1 attacked → legal.
	s = _load_position(_bare([["a1", "white", "rook"]], [["b8", "black", "rook"]]), "white", both)
	ok = bool(s.place("e1", "c1").get("ok", false))
	occ = s.rules.position_field()["occupancy"]
	_record("pieces-king", row,
		"pass" if ok and str(occ.get("c1", {}).get("kind", "")) == "king" else "fail",
		"PS1.10 b1 attacked still castles queenside")


func _judge_pieces_officers() -> void:
	var row := "entities/pieces/officers.md#PS1"
	await _enter_play()
	var session := _session()
	var bishop_targets := session.legal_targets_for("c1")
	var knight_targets := session.legal_targets_for("b1")
	_record("pieces-officers", row,
		"pass" if bishop_targets.size() == 0 and knight_targets.has("a3") else "fail",
		"bishop blocked at c1 (%d), knight jumps b1→a3 (%s)" % [bishop_targets.size(), str(knight_targets)])

	# Long rays on an open board (E-pieces rook/bishop/queen slide).
	var s := _load_position(_bare([["d4", "white", "rook"]], []), "white")
	var rook_ray := s.legal_targets_for("d4")
	var rook_ok := rook_ray.size() == 14
	_record("pieces-officers", row, "pass" if rook_ok else "fail",
		"rook on d4 reaches %d squares on an open board" % rook_ray.size())
	s = _load_position(_bare([["d4", "white", "bishop"]], []), "white")
	var bishop_ray := s.legal_targets_for("d4")
	_record("pieces-officers", row, "pass" if bishop_ray.size() == 13 else "fail",
		"bishop on d4 reaches %d squares on an open board" % bishop_ray.size())
	s = _load_position(_bare([["d4", "white", "queen"]], []), "white")
	var queen_ray := s.legal_targets_for("d4")
	_record("pieces-officers", row, "pass" if queen_ray.size() == 27 else "fail",
		"queen on d4 reaches %d squares on an open board" % queen_ray.size())
	# A friendly piece stops the ray before it.
	s = _load_position(_bare([["d4", "white", "rook"], ["d6", "white", "pawn"]], []), "white")
	var blocked := s.legal_targets_for("d4")
	_record("pieces-officers", row,
		"pass" if blocked.has("d5") and not blocked.has("d6") and not blocked.has("d7") else "fail",
		"friendly piece blocks the rook ray at d6")


func _judge_pieces_pawn() -> void:
	var row := "entities/pieces/pawn.md#PS1"
	await _enter_play()
	var session := _session()
	var targets := session.legal_targets_for("e2")
	_record("pieces-pawn", row,
		"pass" if targets.has("e3") and targets.has("e4") else "fail",
		"PS1.1/1.3 pawn single + double from e2 (%s)" % str(targets))

	# PS1.5 diagonal capture / PS1.6 diagonal without a target.
	var s := _load_position(
		_bare([["e4", "white", "pawn"]], [["d5", "black", "pawn"]]), "white"
	)
	var captured := bool(s.place("e4", "d5").get("ok", false))
	var occ: Dictionary = s.rules.position_field()["occupancy"]
	_record("pieces-pawn", row,
		"pass" if captured and str(occ.get("d5", {}).get("color", "")) == "white" else "fail",
		"PS1.5 e4→d5 captures the Black pawn")
	s = _load_position(_bare([["e4", "white", "pawn"]], []), "white")
	_record("pieces-pawn", row,
		"pass" if not bool(s.place("e4", "d5").get("ok", true)) else "fail", "PS1.6 diagonal with no target → illegal")

	# PS1.7 en passant; PS1.8 en passant expires after another move.
	s = _load_position(
		_bare([["e5", "white", "pawn"]], [["d5", "black", "pawn"]]), "white", {}, "d6"
	)
	var ep := bool(s.place("e5", "d6").get("ok", false))
	occ = s.rules.position_field()["occupancy"]
	_record("pieces-pawn", row,
		"pass" if ep and str(occ.get("d6", {}).get("kind", "")) == "pawn" \
			and occ.get("d5", {}).is_empty() else "fail",
		"PS1.7 en passant removes the d5 pawn")
	s = _load_position(
		_bare([["e5", "white", "pawn"]], [["d5", "black", "pawn"]]), "white", {}, "d6"
	)
	s.place("e5", "e6")
	s.place("a7", "a6")
	_record("pieces-pawn", row,
		"pass" if not s.legal_targets_for("e6").has("d7") else "fail",
		"PS1.8 en passant right expires after White's own move")

	# PS1.9/1.10/1.11 promotion: a7→a8 must choose, refusal stays a pawn.
	s = _load_position(_bare([["a7", "white", "pawn"]], []), "white")
	var pending := s.place("a7", "a8")
	_record("pieces-pawn", row,
		"pass" if bool(pending.get("promote", false)) and s.play_ui_state == "S4" else "fail",
		"PS1.9 a7→a8 asks for a promotion piece (%s)" % s.play_ui_state)
	var stayed := s.commit_promotion("pawn")
	_record("pieces-pawn", row,
		"pass" if not bool(stayed.get("ok", true)) and s.play_ui_state == "S4" else "fail",
		"PS1.10 staying a pawn is refused (%s)" % s.play_ui_state)
	var knighted := s.commit_promotion("knight")
	occ = s.rules.position_field()["occupancy"]
	_record("pieces-pawn", row,
		"pass" if knighted and str(occ.get("a8", {}).get("kind", "")) == "knight" else "fail",
		"PS1.11 underpromotion to a knight places a White knight")


## -------------------------------------------------------------- output

func _protocol_verdict(protocol: String) -> Dictionary:
	var judged: Array = []
	var failing: Array = []
	var not_judged: Array = []
	for row in ROWS_BY_PROTOCOL.get(protocol, []):
		var outcome := _row_outcome(row)
		judged.append({"row": row, "outcome": outcome})
		if outcome == "fail":
			failing.append(row)
		elif outcome == "not-judged":
			not_judged.append(row)
	var verdict := "pass"
	if not failing.is_empty():
		verdict = "fail"
	elif not not_judged.is_empty():
		verdict = "not-judged"
	return {"verdict": verdict, "rows": judged, "fail": failing, "not_judged": not_judged}


func _finish() -> void:
	var protocols := {}
	for p in DESIGN_PROTOCOLS:
		protocols[p] = _protocol_verdict(p) if kind == KIND_HEADLESS else {
			"verdict": "not-run", "rows": [], "fail": [], "not_judged": []
		}
	for p in UX_PROTOCOLS:
		protocols[p] = _protocol_verdict(p)
	var out := {
		"kind": kind,
		"session_id": seams.session_id if seams != null else "",
		"build": _build_facts(),
		"godot": str(Engine.get_version_info().get("string", "")),
		"rows": rows,
		"protocols": protocols,
		"none_rows": NONE_ROWS,
		"errors": errors,
		"tel_count": tel.size(),
	}
	_write(out_dir.path_join("results.json"), JSON.stringify(out, "  "))
	_write(out_dir.path_join("static.json"), JSON.stringify(static_report, "  "))
	var nd := ""
	for payload in tel:
		nd += JSON.stringify(payload) + "\n"
	_write(out_dir.path_join("telemetry.ndjson"), nd)
	print("W478 kind=%s session=%s tel=%d errors=%s" % [
		kind, seams.session_id if seams != null else "?", tel.size(), str(errors)
	])
	quit(0)


## AC 8 — what a reader needs to tell two runs apart (or not) at a glance.
func _build_facts() -> Dictionary:
	return {
		"godot": str(Engine.get_version_info().get("string", "")),
		"binary": str(OS.get_environment("W478_BINARY")),
		"commit": str(OS.get_environment("W478_COMMIT")),
		"export_preset": "Web Playtest",
		"pck_sha256": str(OS.get_environment("W478_PCK_SHA")),
		"os": OS.get_name(),
		"os_version": OS.get_version(),
		"display_driver": DisplayServer.get_name(),
		"window_size": str(DisplayServer.window_get_size()) if DisplayServer.get_name() != "headless" else "none",
	}


func _write(path: String, body: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write %s" % path)
		return
	f.store_string(body)
	f.close()
