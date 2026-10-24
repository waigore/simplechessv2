extends SceneTree
## Acceptance probe for #334 — `PTU-localization` (headless half) on the build
## carrying PR #584, plus the non-vacuity proof the issue body names.
##
## Every judgement prints `A334 JUDGE <protocol> <id> pass|fail — <label>` so the
## manifest can copy it. `PTU-localization` is the only protocol in this leaf's
## scope (see notes.md); S3 is Graphical-only and is recorded `not-judged` here.
## Exit 0 only when every row passed. The probe never fixes a finding.

const PROBE_TAG := "A334"
const PIECE_NAMES := ["queen", "rook", "bishop", "knight"]

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams
var _rows: Array = []
var _screen: Control


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_seams = _presentation.get_node("PlaytestSeams") as PlaytestSeams
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	_router.locale = "en"
	_router.last_mode = "none"
	_presentation.set_deferred("size", Vector2(720, 1280))
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	await _settle(2)
	print("%s playtest_build=%s session=%s godot=%s" % [
		PROBE_TAG, _seams.playtest_build, _seams.session_id,
		Engine.get_version_info().get("string", ""),
	])
	_record("ENV", "ENV.1", DisplayServer.get_name() == "headless", "headless display (%s)" % DisplayServer.get_name())
	_record("ENV", "TEL.3", _seams.session_id != null, "session id: %s" % _seams.session_id)
	_record("ENV", "seams", not str(_seams.playtest_build).is_empty(), "playtest seams are live on this build")

	_judge_ac1_owner()
	_judge_ac3()
	_judge_ac5()
	_judge_negative_cases()
	_judge_puzzle_owner_rows()
	await _observe_puzzle_screen()
	_judge_ac2_panel()
	await _observe_puzzle_screen()
	_record("PTU-localization", "AC2 raw keys", _no_raw_key_visible(_live_screen()),
		"no raw key rendered on the live screen: %s" % _visible_text(_live_screen()))

	_report()
	quit(0 if _failures().is_empty() else 1)


## ---------------------------------------------------------------------------
## AC1 — every Copy-table key resolves in en / zh-Hant / ja, non-empty, not key-equal.
## ---------------------------------------------------------------------------


func _judge_ac1_owner() -> void:
	var keys := StringTable.puzzle_play_keys()
	var problems: Array[String] = []
	for locale in StringTable.LOCALES:
		for key in keys:
			var text := StringTable.puzzle_play(key, locale)
			if text.is_empty() or text == key:
				problems.append("%s in %s" % [key, locale])
	var puzzle_label := StringTable.mode_pick("puzzle", "en")
	var label_ok := not puzzle_label.is_empty() and puzzle_label != "puzzle"
	for locale in StringTable.LOCALES:
		var t := StringTable.mode_pick("puzzle", locale)
		if t.is_empty() or t == "puzzle":
			label_ok = false
			problems.append("mode-pick.puzzle in %s" % locale)
	_record("PTU-localization", "AC1 keys", keys.size() == 21, "puzzle-play owner has %d keys" % keys.size())
	_record("PTU-localization", "AC1 values", problems.is_empty(), "all 21 keys + mode-pick.puzzle resolve in 3 locales (%s)" % [problems])
	for key in keys:
		print("%s ac1 key=%s en=%s zh-Hant=%s ja=%s" % [
			PROBE_TAG, key, StringTable.puzzle_play(key, "en"),
			StringTable.puzzle_play(key, "zh-Hant"), StringTable.puzzle_play(key, "ja"),
		])
	print("%s ac1 mode-pick.puzzle en=%s zh-Hant=%s ja=%s" % [
		PROBE_TAG, StringTable.mode_pick("puzzle", "en"),
		StringTable.mode_pick("puzzle", "zh-Hant"), StringTable.mode_pick("puzzle", "ja"),
	])


## ---------------------------------------------------------------------------
## AC3 — 17 varying keys are not en copies; the 4 L3 piece rows stay en-equal.
## ---------------------------------------------------------------------------


func _judge_ac3() -> void:
	var varying := 0
	var copied: Array[String] = []
	var marked_wrong: Array[String] = []
	for key in StringTable.puzzle_play_keys():
		var marked := StringTable.every_locale_row("puzzle-play", key)
		for locale in ["zh-Hant", "ja"]:
			var text := StringTable.puzzle_play(key, locale)
			var en := StringTable.puzzle_play(key, "en")
			if marked:
				if text != en:
					marked_wrong.append("%s/%s" % [key, locale])
			else:
				if text == en:
					copied.append("%s/%s" % [key, locale])
		if not marked:
			varying += 1
	_record("PTU-localization", "AC3 varying", varying == 17 and copied.is_empty(), "%d varying keys, en copies: %s" % [varying, copied])
	_record("PTU-localization", "AC3 marked", marked_wrong.is_empty(), "four L3 piece rows stay en-equal in zh-Hant and ja (%s)" % [marked_wrong])
	for name in PIECE_NAMES:
		print("%s ac3 marked=%s en=%s zh-Hant=%s ja=%s every_locale_row=%s" % [
			PROBE_TAG, name, StringTable.puzzle_play(name, "en"),
			StringTable.puzzle_play(name, "zh-Hant"), StringTable.puzzle_play(name, "ja"),
			StringTable.every_locale_row("puzzle-play", name),
		])


## ---------------------------------------------------------------------------
## AC2 — UI-mode-pick C4: the live mode-pick screen re-resolves copy per locale.
## ---------------------------------------------------------------------------


func _judge_ac2_panel() -> void:
	await _settle(1)
	if _router.stage != "mode-pick":
		_router._go_mode_pick("S1")
		await _settle(2)
	_record("PTU-localization", "AC2 stage", _router.stage == "mode-pick", "mode-pick is the live screen (stage=%s)" % _router.stage)
	var seen: Array = []
	var screens: Array = []
	## C4 cycles en → zh-Hant → ja → en on the live panel. Copy is judged on the
	## screen that is actually rendered after each activation.
	for step in 3:
		_router.handle_control("mode-pick", "C4")
		await _settle(2)
		var after := _visible_text(_live_screen())
		seen.append(_router.locale)
		screens.append(after)
		print("%s ac2 C4 step=%d locale=%s stage=%s" % [
			PROBE_TAG, step + 1, _router.locale, _router.stage,
		])
		print("%s ac2 visible=%s" % [PROBE_TAG, after])
		if _live_screen() != null and _router.stage == "mode-pick":
			_router._go_mode_pick("S1")
			await _settle(1)
	var jump_works := _router.stage == "mode-pick" and not _visible_text(_mode_pick_screen()).is_empty()
	_record("PTU-localization", "AC2 jump", jump_works,
		"DBG.3 jump to mode-pick shows its copy (stage=%s): %s" % [_router.stage, _visible_text(_mode_pick_screen())])
	var distinct: bool = (
		screens.size() == 3
		and not str(screens[0]).is_empty() and not str(screens[1]).is_empty() and not str(screens[2]).is_empty()
		and screens[0] != screens[1] and screens[1] != screens[2] and screens[0] != screens[2]
	)
	_record("PTU-localization", "AC2 C4", distinct and seen == ["zh-Hant", "ja", "en"],
		"C4 cycles %s and the rendered copy differs at each step" % [seen])
	var per_locale := {"en": screens[2], "zh-Hant": screens[0], "ja": screens[1]}
	var shown := 0
	for locale in StringTable.LOCALES:
		var label := str(StringTable.mode_pick("puzzle", locale))
		var seen_here := str(per_locale[locale]).find(label) != -1
		if seen_here:
			shown += 1
		print("%s ac2 puzzle label %s present=%s" % [PROBE_TAG, locale, seen_here])
	_record("PTU-localization", "AC2 puzzle label",
		str(per_locale["zh-Hant"]).find(StringTable.mode_pick("puzzle", "zh-Hant")) != -1
		and str(per_locale["ja"]).find(StringTable.mode_pick("puzzle", "ja")) != -1,
		"puzzle entry copy on the rendered mode-pick: zh-Hant=%s ja=%s" % [
			str(per_locale["zh-Hant"]).find(StringTable.mode_pick("puzzle", "zh-Hant")) != -1,
			str(per_locale["ja"]).find(StringTable.mode_pick("puzzle", "ja")) != -1,
		])
	_router.locale = "en"
	_router._go_mode_pick("S1")
	await _settle(1)


func _judge_ac5() -> void:
	var own_names := {}
	for locale in StringTable.LOCALES:
		own_names[locale] = StringTable.mode_pick("locale", locale)
	var own_ok := true
	for locale in StringTable.LOCALES:
		if str(own_names[locale]).is_empty() or str(own_names[locale]) == "locale":
			own_ok = false
		print("%s ac5 locale row %s=%s" % [PROBE_TAG, locale, own_names[locale]])
	var marked_rows := {}
	for owner in ["mode-pick", "shared-play", "puzzle-play"]:
		var rows: Array = []
		for key in _keys_for(owner):
			if StringTable.every_locale_row(owner, key):
				rows.append(key)
		marked_rows[owner] = rows
	print("%s ac5 marked rows per owner=%s" % [PROBE_TAG, marked_rows])
	_record("PTU-localization", "AC5 locale row", own_ok, "locale row reads its own name in every locale")
	_record("PTU-localization", "AC5 marked set", marked_rows.get("puzzle-play", []) == PIECE_NAMES,
		"puzzle-play marked set is exactly %s (no fifth exception)" % [PIECE_NAMES])


## ---------------------------------------------------------------------------
## AC4 — the non-vacuity proof: mutations must be reported, marked rows must not.
## ---------------------------------------------------------------------------


func _judge_negative_cases() -> void:
	var suite := _puzzle_play_suite()
	var owner := str(suite[0])
	var clean := _owner_missing(suite)
	var dropped: Array = [owner, suite[1], _with_row(suite[2], "cue_failed", "zh-Hant", "")]
	var want_missing := "%s.cue_failed missing in zh-Hant" % owner
	var copied: Array = [owner, suite[1], _with_row(suite[2], "reveal", "ja", "Reveal")]
	var want_english := "%s.reveal still English in ja" % owner
	var marked: Array = [owner, suite[1], _with_row(suite[2], "queen", "ja", "Queen")]
	var got_missing := _owner_missing(dropped)
	var got_english := _owner_missing(copied)
	var got_marked := _owner_missing(marked)
	print("%s ac4 clean=%s dropped=%s copied=%s marked=%s" % [
		PROBE_TAG, clean, got_missing, got_english, got_marked,
	])
	_record("PTU-localization", "AC4 unmutated", clean.is_empty(), "shipped owner passes (%s)" % clean)
	_record("PTU-localization", "AC4 dropped key", got_missing == want_missing, "expects `%s`, got `%s`" % [want_missing, got_missing])
	_record("PTU-localization", "AC4 en copy", got_english == want_english, "expects `%s`, got `%s`" % [want_english, got_english])
	_record("PTU-localization", "AC4 marked row", got_marked.is_empty(), "an en-copied marked piece row passes (%s)" % got_marked)


## ---------------------------------------------------------------------------
## AC4b — the owner is its own namespace: no cross-owner resolution.
## ---------------------------------------------------------------------------


func _judge_puzzle_owner_rows() -> void:
	var shared_names := ["queen", "rook", "bishop", "knight", "choose_promotion", "refused_place", "confirm", "cancel", "dismiss", "save_failed"]
	var problems: Array[String] = []
	for key in shared_names:
		if not key in StringTable.puzzle_play_keys():
			problems.append("missing own row %s" % key)
	_record("PTU-localization", "AC4b own rows", problems.is_empty(),
		"puzzle-play owns %d shared bare names (%s)" % [shared_names.size(), problems])


## ---------------------------------------------------------------------------
## Precondition check — the puzzle-play screen is #333's, not an AC of this leaf.
## Observed and printed; it never fails this run.
## ---------------------------------------------------------------------------


func _observe_puzzle_screen() -> void:
	var panel := _presentation.get_node_or_null("ScreenHost/PuzzlePlay")
	print("%s precondition puzzle-panel=%s" % [PROBE_TAG, panel != null])
	if panel == null:
		return
	for locale in StringTable.LOCALES:
		_router.locale = locale
		_router._go_mode_pick("S1")
		await _settle(1)
		_router.handle_control("mode-pick", "C2")
		await _settle(2)
		var text := _visible_text(_puzzle_panel())
		print("%s precondition puzzle-play %s stage=%s visible=%s" % [
			PROBE_TAG, locale, _router.stage, text,
		])
	_router.locale = "en"


func _puzzle_panel() -> Control:
	return _presentation.get_node_or_null("ScreenHost/PuzzlePlay") as Control


## ---------------------------------------------------------------------------
## Helpers
## ---------------------------------------------------------------------------


func _record(protocol: String, id: String, ok: bool, label: String) -> void:
	_rows.append({"protocol": protocol, "id": id, "ok": ok, "label": label})
	print("%s JUDGE %s %s %s — %s" % [PROBE_TAG, protocol, id, "pass" if ok else "fail", label])


func _failures() -> Array:
	var out: Array = []
	for row in _rows:
		if not row["ok"]:
			out.append("%s %s" % [row["id"], row["label"]])
	return out


func _report() -> void:
	var failures := _failures()
	print("%s RESULT rows=%d failures=%d" % [PROBE_TAG, _rows.size(), failures.size()])
	for failure in failures:
		print("%s FAIL row: %s" % [PROBE_TAG, failure])


func _settle(frames: int) -> void:
	for i in frames:
		await process_frame


func _mode_pick_screen() -> Control:
	return _presentation.get_node("ScreenHost/ModePick") as Control


## The panel of whichever stage is live right now.
func _live_screen() -> Control:
	match _router.stage:
		"mode-pick":
			return _presentation.get_node_or_null("ScreenHost/ModePick") as Control
		"puzzle-play":
			return _presentation.get_node_or_null("ScreenHost/PuzzlePlay") as Control
	return null


## Every player-facing string on the panel, read from the rendered Label / Button
## text — not from StringTable, so the screen's own resolution is what is judged.
func _visible_text(panel: Control) -> String:
	if panel == null:
		return ""
	var parts: Array[String] = []
	_collect_text(panel, parts)
	return " | ".join(parts)


func _collect_text(node: Node, out: Array[String]) -> void:
	if node is CanvasItem and not (node as CanvasItem).visible:
		return
	if node is Label:
		var label := node as Label
		if label.modulate.a >= 0.05 and not label.text.is_empty():
			out.append(label.text)
		return
	if node is Button:
		var button := node as Button
		if button.modulate.a >= 0.05 and not button.text.is_empty():
			out.append(button.text)
		return
	for child in node.get_children():
		_collect_text(child, out)


## A Copy value, not a raw key: no rendered string equals a Copy-table key id.
func _no_raw_key_visible(panel: Control) -> bool:
	var text := _visible_text(panel)
	if text.is_empty():
		return false
	var keys: Array = []
	keys.append_array(Array(StringTable.mode_pick_keys()))
	keys.append_array(Array(StringTable.puzzle_play_keys()))
	for part in text.split(" | "):
		## The `· <last mode>` suffix is its own copy row; judge the leading label only.
		var head := str(part).split(" · ")[0]
		if head in keys:
			print("%s raw key rendered: %s" % [PROBE_TAG, head])
			return false
	return true


func _has_label(text: String, label: String) -> bool:
	return label.is_empty() or str(text).find(label) != -1


func _keys_for(owner: String) -> PackedStringArray:
	match owner:
		"mode-pick":
			return StringTable.mode_pick_keys()
		"shared-play":
			return StringTable.shared_play_keys()
		"puzzle-play":
			return StringTable.puzzle_play_keys()
	return PackedStringArray()


func _puzzle_play_suite() -> Array:
	return ["puzzle-play", StringTable.puzzle_play_keys(), Callable(StringTable, "puzzle_play")]


## The shipped gate's completeness rule, reproduced here so acceptance reads the
## owner with its own code rather than importing the test under review.
func _owner_missing(suite: Array) -> String:
	var label := str(suite[0])
	var keys: PackedStringArray = suite[1]
	var getter: Callable = suite[2]
	if keys.is_empty():
		return "%s has no keys" % label
	for locale in StringTable.LOCALES:
		for key in keys:
			var text := str(getter.call(key, locale))
			if text.is_empty() or text == key:
				return "%s.%s missing in %s" % [label, key, locale]
			var marked := StringTable.every_locale_row(label, key)
			if locale == "en":
				continue
			var en := str(getter.call(key, "en"))
			if marked and text != en:
				return "%s.%s not en-equal in %s" % [label, key, locale]
			if not marked and text == en:
				return "%s.%s still English in %s" % [label, key, locale]
	return ""


func _with_row(base: Callable, key: String, locale: String, value: String) -> Callable:
	return func(read_key: String, read_locale: String) -> String:
		if read_key == key and read_locale == locale:
			return value
		return str(base.call(read_key, read_locale))
