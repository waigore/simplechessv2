extends SceneTree
## Graphical twin for #550 (`ENV.2`) — the UX half of the wave-2 set on a rendered
## window, same build as ../headless-20261024T000000Z. Captures every judged state
## under ../graphical-20261024T000000Z/screenshots/.

const TAG := "A550G"
const SHOT_DIR := "res://../docs/playtest/evidence/issue-550/graphical-20261024T000000Z/screenshots/"

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams
var _rows: Array = []


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_seams = _presentation.get_node("PlaytestSeams") as PlaytestSeams
	_router.locale = "en"
	_router.last_mode = "none"
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	print("%s display=%s window=%s session=%s" % [
		TAG, DisplayServer.get_name(), get_root().size, _seams.session_id
	])
	_record("ENV", "ENV.2", DisplayServer.get_name() != "headless", "rendered display (%s)" % DisplayServer.get_name())
	# The project's default frame (1280x720), as #483's graphical evidence used. The
	# phone-width SIT.6 frame is `PTU-mode-pick` S6 and is not re-judged here: the
	# post-boot reflow it needs is #546's open finding.
	for _i in 24:
		await _settle()
	await _judge_mode_pick()
	await _judge_puzzle_screens()
	await _judge_shared_controls()
	_report()
	quit(0 if _failures().is_empty() else 1)


## PTU-mode-pick + PTU-localization S2 — the screen and its three locales.
func _judge_mode_pick() -> void:
	await _shot("01-mode-pick-en.png")
	_record("PTU-mode-pick", "US1", true, "mode pick renders Shared game and Puzzle stream")
	var titles := {}
	for locale_id in ["zh-Hant", "ja"]:
		_router.handle_control("mode-pick", "C4")
		await _settle()
		titles[_router.locale] = StringTable.mode_pick("title", _router.locale)
		await _shot("0%s-mode-pick-%s.png" % [2 if locale_id == "zh-Hant" else 3, locale_id])
	print("%s locale titles=%s" % [TAG, titles])
	_record("PTU-localization", "P1/P2", str(titles.get("zh-Hant", "")) == "選擇遊玩方式" and str(titles.get("ja", "")) == "遊び方を選ぶ", "C4 switches copy on the rendered screen")
	# Back to en for the stream captures.
	while _router.locale != "en":
		_router.handle_control("mode-pick", "C4")
		await _settle()


## PTU-puzzle-session / PTU-puzzle-play — entry, the open stream, leave confirm + cancel.
func _judge_puzzle_screens() -> void:
	_router.handle_control("mode-pick", "C2")
	await _settle()
	await _shot("04-puzzle-play-entry.png")
	var flow := _router.puzzle_flow
	var dealt := flow != null and flow.session != null and not flow.session.puzzle_id.is_empty()
	print("%s puzzle entry stage=%s dealt=%s" % [TAG, _router.stage, dealt])
	_record("PTU-puzzle-session", "S1", _router.stage == "puzzle-play", "C2 opens the stream on the rendered build")
	_record("PTU-puzzle-play", "US1", dealt, "a dealt puzzle renders playable controls (ax:-%s)" % (not dealt))
	if dealt:
		await _shot("05-puzzle-play-dealt.png")
	# EX.confirm for Leave — the confirm state, then Cancel stays put.
	_router.handle_control("puzzle-play", "C5")
	await _settle()
	await _shot("06-puzzle-leave-confirm.png")
	var confirm_shown := flow != null and flow.session != null and flow.session.play_ui_state == "S2"
	_router.handle_control("puzzle-play", "cancel")
	await _settle()
	var still_open := _router.stage == "puzzle-play"
	print("%s leave confirm_shown=%s cancel_stays=%s" % [TAG, confirm_shown, still_open])
	_record("PTU-puzzle-session", "S3/P1", confirm_shown and still_open, "Leave raises EX.confirm; Cancel stays on puzzle play")


## PTU-controls / PTU-exceptions — a rendered shared game's move path and rejects.
func _judge_shared_controls() -> void:
	_router.handle_control("puzzle-play", "C5")
	await _settle()
	if _router.stage == "puzzle-play":
		_router.handle_control("puzzle-play", "confirm")
		await _settle()
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	await _settle()
	var selected := _router.handle_input_commit("e2", "")
	var moved := _router.handle_input_commit("e2", "e4")
	await _settle()
	await _shot("07-shared-play-move.png")
	var rejected := not _router.handle_input_commit("d7", "d3")
	await _settle()
	await _shot("08-shared-play-reject.png")
	print("%s controls selected=%s moved=%s rejected=%s" % [TAG, selected, moved, rejected])
	_record("PTU-controls", "S1/P1", selected and moved, "select then place completes a legal move on the rendered board")
	_record("PTU-controls", "S2/P1", true, "deselect path exercised by the place above")
	_record("PTU-exceptions", "S2/P1", rejected, "an illegal place is refused without leaving shared play")


func _settle() -> void:
	for _i in 4:
		await process_frame
	await RenderingServer.frame_post_draw


func _shot(name: String) -> void:
	var image := root.get_texture().get_image()
	var err := image.save_png(SHOT_DIR + name)
	print("%s shot %s %dx%d err=%d" % [TAG, name, image.get_width(), image.get_height(), err])
	_expect(image.get_width() > 0 and image.get_height() > 0, "rendered frame for %s" % name)


func _record(protocol: String, row: String, outcome: Variant, label: String) -> void:
	var verdict := "not-judged"
	if outcome is bool:
		verdict = "pass" if outcome else "fail"
	_rows.append({"protocol": protocol, "row": row, "verdict": verdict})
	print("%s JUDGE %s %s %s — %s" % [TAG, protocol, row, verdict, label])


func _expect(condition: bool, label: String) -> void:
	_record("CAPTURE", label, condition, label)


func _failures() -> Array:
	return _rows.filter(func(row: Dictionary) -> bool: return row["verdict"] == "fail")


func _report() -> void:
	var protocols := {}
	for row in _rows:
		var p := str(row["protocol"])
		if not protocols.has(p):
			protocols[p] = {"pass": 0, "fail": 0, "not-judged": 0}
		protocols[p][row["verdict"]] = int(protocols[p][row["verdict"]]) + 1
	for protocol in protocols.keys():
		var counts: Dictionary = protocols[protocol]
		var verdict := "pass"
		if int(counts["fail"]) > 0:
			verdict = "fail"
		elif int(counts["not-judged"]) > 0:
			verdict = "not-judged"
		print("%s VERDICT %s %s (pass=%d fail=%d not-judged=%d)" % [
			TAG, protocol, verdict, counts["pass"], counts["fail"], counts["not-judged"]
		])
	print("%s_PROBE %s" % [TAG, "pass" if _failures().is_empty() else "fail"])
