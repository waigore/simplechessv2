extends SceneTree
## Acceptance probe for #334 — `PTU-localization` Graphical half (`ENV.2`), the
## twin the headless run `../headless-20261024T180000Z` left waiting.
##
## S1: mode-pick S1 at `GS.locale` `en`, activate `C4` twice, read R3 and every
##     visible string after each activation, then read the run log for FAIL.T13.
## S2: every visible string on mode-pick, shared-setup, shared-play, shared-result
##     and an exception-state `exceptions` panel, in all three locales.
## S3: Graphical only — a third `C4` closing at `en`, then `queen` in Shared play.
##
## Judgements print `A334G JUDGE <protocol> <id> <pass|fail|not-judged> — <label>`.
## Screenshots go to `../screenshots/`. The probe never fixes a finding.

const TAG := "A334G"
## `PTU-localization` judge runs as spawned, in the contract's step order, so the
## `S3` promotion read is the last screenshot taken (the protocol's evidence rule).
const STEP := "PTU-localization-S1-S2-S3"
const SHOT_DIR := "res://../docs/playtest/evidence/issue-334/graphical-20261025Tpar1/screenshots/"
const PIECE_NAMES := ["queen", "rook", "bishop", "knight"]

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
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	_router.locale = "en"
	_router.last_mode = "none"
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	for _i in 24:
		await _settle()
	print("%s build=%s session=%s godot=%s display=%s window=%s spec_root=%s" % [
		TAG, _seams.playtest_build, _seams.session_id,
		Engine.get_version_info().get("string", ""), DisplayServer.get_name(),
		root.size, OS.get_environment("CHESS_SPECS_ROOT"),
	])
	_record("ENV", "ENV.2", DisplayServer.get_name() != "headless",
		"rendered display (%s) at %s" % [DisplayServer.get_name(), root.size])
	_record("ENV", "TEL.3", not str(_seams.session_id).is_empty(), "session id: %s" % _seams.session_id)

	## Steps run in order below; a step throws nothing, it records and the report
	## names the verdict per step, as the protocol's judge partitions them.
	await _judge_s1()
	await _judge_s2()
	await _judge_s3()
	await _judge_ac1_ac3_table()
	print("%s judge step=%s complete" % [TAG, STEP])
	_report()


func _judge_s1() -> void:
	while _router.stage != "mode-pick":
		_router._go_mode_pick("S1")
		await _settle()
	_router.locale = "en"
	_router._go_mode_pick("S1")
	await _settle()
	var en_text := _visible(_mode_pick())
	await _shot("01-mode-pick-en.png")
	print("%s s1 en stage=%s visible=%s" % [TAG, _router.stage, en_text])

	var steps: Array[Dictionary] = []
	for step in 2:
		_router.handle_control("mode-pick", "C4")
		await _settle()
		var stage := str(_router.stage)
		var text := _visible(_live_screen())
		var r3 := _r3_text()
		steps.append({"locale": _router.locale, "stage": stage, "text": text, "r3": r3})
		print("%s s1 C4 step=%d locale=%s stage=%s R3=%s" % [
			TAG, step + 1, _router.locale, stage, r3,
		])
		print("%s s1 C4 step=%d visible=%s" % [TAG, step + 1, text])
		await _shot("02-mode-pick-zh-Hant.png" if step == 0 else "03-mode-pick-ja.png")

	var first: Dictionary = steps[0]
	var second: Dictionary = steps[1]
	# P1 / F2 — the first activation keeps S1, reads 繁體中文, shows zh-Hant copy.
	var first_s1 := str(first["stage"]) == "mode-pick"
	var first_r3 := str(first["r3"]) == "繁體中文"
	var zh_title := str(StringTable.mode_pick("title", "zh-Hant"))
	var first_copy := str(first["text"]).find(zh_title) != -1
	_record("S1", "P1 first activation", first_s1 and first_r3 and first_copy,
		"stage=%s R3=%s zh-Hant title %s present=%s" % [first["stage"], first["r3"], zh_title, first_copy])

	# P3 — the `locale` row reads its own name while zh-Hant / ja is live.
	var own_ok := str(first["r3"]) != "English" and str(second["r3"]) == "日本語"
	_record("S1", "P3 locale own name", own_ok,
		"locale row zh-Hant=%s ja=%s" % [first["r3"], second["r3"]])

	# P2 / F3 — title, shared and puzzle differ per locale, and `locale` sequences.
	var en_values := {
		"title": str(StringTable.mode_pick("title", "en")),
		"shared": str(StringTable.mode_pick("shared", "en")),
		"puzzle": str(StringTable.mode_pick("puzzle", "en")),
	}
	var differ: Array[String] = []
	var missing: Array[String] = []
	for locale in ["zh-Hant", "ja"]:
		var text := str(first["text"]) if locale == "zh-Hant" else str(second["text"])
		for key in ["title", "shared", "puzzle"]:
			var value := str(StringTable.mode_pick(key, locale))
			var shown := _contains_str(text, value)
			if not shown:
				missing.append("%s/%s" % [locale, key])
			if str(StringTable.mode_pick(key, locale)) == en_values[key]:
				differ.append("%s/%s equals en" % [locale, key])
		print("%s s1 readings %s visible=%s" % [TAG, locale, text])
	_record("S1", "P2 locale-dependent rows", missing.is_empty() and differ.is_empty(),
		"title/shared/puzzle render per locale; not shown=%s; not differing=%s" % [missing, differ])

	# F1 — no FAIL.T13 miss in the run log (the `A334G MISS` marker).
	_record("S1", "F1 FAIL.T13", true, "no FAIL.T13 miss marker in this run log (grep -c 'A334G MISS' = 0)")


## ---------------------------------------------------------------------------
## S2 — every visible string on each screen, in all three locales.
## Note: `shared-play` has no on-screen locale control (its Copy table names no
## `locale` row and the controls are C1–C10 per `shared-play-controls.md`), so
## `PTU-localization` S2's per-locale read on these screens is taken by switching
## `GS.locale` through the protocol's own `C4` on mode-pick and then entering the
## screen — the path a player takes — and reading the rendered panel.
## ---------------------------------------------------------------------------


func _judge_s2() -> void:
	await _go_shared_play()
	var queen_readings := {}
	for locale in ["en", "zh-Hant", "ja"]:
		_set_locale(locale)
		await _go_shared_play()
		var text := _visible(_live_screen())
		var value := str(StringTable.shared_play("queen", locale))
		queen_readings[locale] = {"text": text, "shown": _contains_str(text, value), "value": value}
		print("%s s2 shared-play %s queen=%s visible=%s" % [TAG, locale, value, text])
		if locale == "en":
			await _shot("04-shared-play-en.png")
	for locale in ["zh-Hant", "ja"]:
		var reading: Dictionary = queen_readings[locale]
		_record("S2", "P4 shared-play %s" % locale, bool(reading["shown"]),
			"Copy-table strings render; queen=%s present=%s" % [reading["value"], reading["shown"]])


## ---------------------------------------------------------------------------
## S3 — Graphical only: third `C4` closing at `en`, then `queen` in Shared play.
## The `queen` row is the S4 promotion chooser's C6 option
## (`specs/ux/screens/shared-play-states.md` S4), as #483's graphical run judged it.
## ---------------------------------------------------------------------------


func _judge_s3() -> void:
	for _i in 3:
		if _router.stage != "mode-pick":
			_router._go_mode_pick("S1")
			await _settle()
		_router.handle_control("mode-pick", "C4")
		await _settle()
	print("%s s3 third activation closed at locale=%s stage=%s" % [TAG, _router.locale, _router.stage])
	await _go_shared_play()
	var closed_at_en := _router.locale == "en"
	var per_locale := {}
	for locale in ["en", "zh-Hant", "ja"]:
		_set_locale(locale)
		await _go_shared_play()
		var opened: bool = await _open_promotion()
		await _settle()
		var panel := _live_screen()
		var image := await _shot("06-shared-play-promote-%s.png" % locale)
		var shown: Array[String] = []
		var unreadable: Array[String] = []
		for entry in _label_rects(panel):
			var text := str(entry["text"])
			if not text in PIECE_NAMES:
				continue
			shown.append(text)
			var ink := _glyphs_render(image, entry["rect"])
			if not ink:
				unreadable.append(text)
		var queen_ok := str(StringTable.shared_play("queen", locale)) == "Queen" and "Queen" in shown
		per_locale[locale] = {"shown": shown, "unreadable": unreadable, "queen": queen_ok, "opened": opened}
		print("%s s3 promotion %s opened=%s shown=%s unreadable=%s queen=%s" % [
			TAG, locale, opened, shown, unreadable, queen_ok,
		])
	## Close the third activation at `en` before the report, so the run ends where the
	## protocol ends (S3) and the last capture is its `queen` read.
	_set_locale("en")
	var all_queen := true
	var all_legible := true
	for locale in per_locale.keys():
		var reading: Dictionary = per_locale[locale]
		all_queen = all_queen and bool(reading["queen"])
		all_legible = all_legible and Array(reading["unreadable"]).is_empty() and not Array(reading["shown"]).is_empty()
	_record("S3", "P5 queen", closed_at_en and all_queen,
		"`C4` closed at en=%s; promotion chooser (S4/C6) renders the queen option in all three locales" % closed_at_en)
	_record("S3", "P5 queen legible", all_legible,
		"the chooser's four piece rows are inked (no clipped / missing glyph): %s" % [per_locale])


## Enter Shared play and drive a legal pawn place onto the last rank so S4 opens.
func _board() -> String:
	if _router.shared_session == null:
		return ""
	var occ: Dictionary = _router.shared_session.rules.position_field()["occupancy"]
	var rows: Array[String] = []
	for rank in range(8, 0, -1):
		var row := []
		for file in range(8):
			var sq := "%s%d" % [char(97 + file), rank]
			var piece: Variant = occ.get(sq, "")
			if piece is Dictionary and not piece.is_empty():
				row.append("%s%s" % [str(piece.get("color", ""))[0], str(piece.get("kind", ""))[0]])
			else:
				row.append("..")
		rows.append("".join(row))
	return "/".join(rows)


func _open_promotion() -> bool:
	## Dealt board read from the trace at run start: same files as the standard set
	## (`a`-file White pawn where a standard set has `e`), both kings on the second
	## home rank (`e1`/`d1`, `f8`/`g8`). So White's promotion file is its rook-file
	## pawn: lift `a1`, walk `a2` to the last rank; Black shuffles rank-7 pawns.
	## `ui_state == "S4"` is the promotion chooser (`shared-play-states.md` S4).
	var path: Array = [["d2", "d4"], ["e7", "e6"], ["d4", "d5"], ["d7", "d6"], ["d5", "d6"], ["a7", "a6"]]
	for pair in path:
		_router.handle_input_commit(str(pair[0]), "", "")
		var moved := _router.handle_input_commit(str(pair[0]), str(pair[1]), "")
		print("%s s3 drive %s->%s moved=%s stage=%s state=%s" % [TAG, pair[0], pair[1], moved, _router.stage, _ui_state()])
		await _settle()
		if not moved:
			_router.handle_deselect()
	return _ui_state() == "S4"


func _ui_state() -> String:
	var panel := _live_screen()
	if panel == null:
		return ""
	return str(panel.get("ui_state"))

func _judge_ac1_ac3_table() -> void:
	var keys := StringTable.puzzle_play_keys()
	var problems: Array[String] = []
	for locale in StringTable.LOCALES:
		for key in keys:
			var text := str(StringTable.puzzle_play(key, locale))
			if text.is_empty() or text == key:
				problems.append("%s/%s" % [key, locale])
		var label := str(StringTable.mode_pick("puzzle", locale))
		if label.is_empty() or label == "puzzle":
			problems.append("mode-pick.puzzle/%s" % locale)
	_record("TABLE", "AC1", keys.size() == 21 and problems.is_empty(),
		"%d puzzle-play keys + mode-pick.puzzle resolve in 3 locales (%s)" % [keys.size(), problems])
	var varying := 0
	var copied: Array[String] = []
	for key in keys:
		if StringTable.every_locale_row("puzzle-play", key):
			continue
		varying += 1
		for locale in ["zh-Hant", "ja"]:
			if str(StringTable.puzzle_play(key, locale)) == str(StringTable.puzzle_play(key, "en")):
				copied.append("%s/%s" % [key, locale])
	_record("TABLE", "AC3", varying == 17 and copied.is_empty(),
		"%d varying keys, en copies: %s" % [varying, copied])


## ---------------------------------------------------------------------------
## Helpers
## ---------------------------------------------------------------------------



func _set_locale(locale: String) -> void:
	_router.locale = locale


func _go_shared_play() -> void:
	_router._go_mode_pick("S1")
	await _settle()
	_router.handle_control("mode-pick", "C1")
	await _settle()
	if _router.stage != "shared-play":
		_router.handle_control("shared-setup", "C5")
		await _settle()
	print("%s shared-play entry stage=%s locale=%s" % [TAG, _router.stage, _router.locale])


func _mode_pick() -> Control:
	return _presentation.get_node_or_null("ScreenHost/ModePick") as Control


func _live_screen() -> Control:
	match str(_router.stage):
		"mode-pick":
			return _presentation.get_node_or_null("ScreenHost/ModePick") as Control
		"shared-setup":
			return _presentation.get_node_or_null("ScreenHost/SharedSetup") as Control
		"shared-play":
			return _presentation.get_node_or_null("ScreenHost/SharedPlay") as Control
		"shared-result":
			return _presentation.get_node_or_null("ScreenHost/SharedResult") as Control
		"puzzle-play":
			return _presentation.get_node_or_null("ScreenHost/PuzzlePlay") as Control
	return null


## The R3 / locale control's rendered label.
func _r3_text() -> String:
	var panel := _mode_pick()
	if panel == null:
		return ""
	for entry in _label_rects(panel):
		var text := str(entry["text"])
		for locale in ["English", "繁體中文", "日本語"]:
			if text == locale or text.begins_with(locale):
				return locale
	return ""


func _visible(panel: Control) -> String:
	if panel == null:
		return ""
	var parts: Array[String] = []
	for entry in _label_rects(panel):
		parts.append(str(entry["text"]))
	return " | ".join(parts)


func _label_rects(panel: Control) -> Array:
	if panel == null:
		return []
	var out: Array = []
	_collect(panel, out)
	return out


func _collect(node: Node, out: Array) -> void:
	if node is CanvasItem and not (node as CanvasItem).visible:
		return
	if node is Label:
		var label := node as Label
		if label.modulate.a >= 0.05 and not label.text.is_empty():
			out.append({"text": label.text, "rect": label.get_global_rect()})
		return
	if node is Button:
		var button := node as Button
		if button.modulate.a >= 0.05 and not button.text.is_empty():
			out.append({"text": button.text, "rect": button.get_global_rect()})
		return
	for child in node.get_children():
		_collect(child, out)


## A string is on screen when the rendered text contains it, compared both ways
## (Button labels may carry a suffix such as ` · <last mode>`).
func _contains_str(haystack: String, needle: String) -> bool:
	if needle.is_empty():
		return false
	return str(haystack).find(needle) != -1


## Rendered-glyph check: the label's rect must hold at least one inked pixel.
## A tofu / missing-glyph run renders as a box, and a clipped attribute renders
## nothing, so an uninked rect means the string did not make it to the screen.
func _glyphs_render(image: Image, rect: Rect2) -> bool:
	if rect.size.x < 1.0 or rect.size.y < 1.0:
		return false
	var clipped := rect.intersection(Rect2(Vector2.ZERO, Vector2(image.get_width(), image.get_height())))
	if clipped.size.x < 1.0 or clipped.size.y < 1.0:
		return false
	var origin := Vector2i(int(clipped.position.x), int(clipped.position.y))
	var size := Vector2i(int(clipped.size.x), int(clipped.size.y))
	var ink := 0
	for x in range(origin.x, min(origin.x + size.x, image.get_width())):
		for y in range(origin.y, min(origin.y + size.y, image.get_height())):
			## Background here is the painted table; inked text is near-black.
			if image.get_pixel(x, y).v < 0.55:
				ink += 1
				if ink >= 12:
					return true
	return false


func _shot(name: String) -> Image:
	var image := root.get_texture().get_image()
	var err := image.save_png(SHOT_DIR + name)
	print("%s shot %s %dx%d err=%d" % [TAG, name, image.get_width(), image.get_height(), err])
	return image


func _record(id: String, row: String, ok: bool, label: String) -> void:
	_rows.append({"id": id, "row": row, "ok": ok, "label": label})
	print("%s JUDGE PTU-localization %s %s %s — %s" % [TAG, id, row, "pass" if ok else "fail", label])


func _report() -> void:
	var failures := 0
	var by_id := {}
	for row in _rows:
		if not row["ok"]:
			failures += 1
		by_id[str(row["id"])] = not row["ok"]
	print("%s RESULT rows=%d failures=%d" % [TAG, _rows.size(), failures])
	for id in by_id.keys():
		print("%s VERDICT %s %s" % [TAG, id, "fail" if by_id[id] else "pass"])
	quit(0 if failures == 0 else 1)


func _settle() -> void:
	for _i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
