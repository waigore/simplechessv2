class_name StringTableTest
extends SceneTree
## Localization contract (`specs/ux/localization.md` L2–L4): Copy keys, CJK glyphs, and
## the 40% growth layout (#62).

const VIEW_SIZE := Vector2(720, 1280)
const GROWTH := 0.4

## The owners L3 marks; their rows live in `StringTable.EVERY_LOCALE_ROWS`.
const MARKED_OWNERS := ["mode-pick", "shared-play", "puzzle-play"]

var _owner_getters: Dictionary = {}

var _presentation: Presentation
var _router: SessionRouter
var _ui_font: Font


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_router.locale = "en"
	_router.last_mode = "none"
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	_presentation.set_deferred("size", VIEW_SIZE)
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	var problem := _spec_copy_key_sets()
	if problem.is_empty():
		problem = _all_locales_populated()
	if problem.is_empty():
		problem = _marked_rows_match_l3()
	if problem.is_empty():
		problem = _marked_rows_en_equal()
	if problem.is_empty():
		problem = _no_english_leak_in_puzzle_play()
	if problem.is_empty():
		problem = _copy_gate_negative_cases()
	if problem.is_empty():
		problem = _locale_helpers()
	if problem.is_empty():
		problem = _font_chain_and_glyphs()
	if problem.is_empty():
		problem = await _screen_layouts_at_growth()
	if problem.is_empty():
		quit(0)
		return
	push_error(problem)
	quit(1)


## Every shipped copy owner with its key list and read function, in table order.
func _all_locales_suites() -> Array:
	if _owner_getters.is_empty():
		_owner_getters = {
			"mode-pick": Callable(StringTable, "mode_pick"),
			"shared-setup": Callable(StringTable, "shared_setup"),
			"shared-play": Callable(StringTable, "shared_play"),
			"shared-result": Callable(StringTable, "shared_result"),
			"exceptions": Callable(StringTable, "exception_text"),
			"puzzle-play": Callable(StringTable, "puzzle_play"),
		}
	return [
		["mode-pick", StringTable.mode_pick_keys(), _owner_getters["mode-pick"]],
		["shared-setup", StringTable.shared_setup_keys(), _owner_getters["shared-setup"]],
		["shared-play", StringTable.shared_play_keys(), _owner_getters["shared-play"]],
		["shared-result", StringTable.shared_result_keys(), _owner_getters["shared-result"]],
		["exceptions", StringTable.exception_keys(), _owner_getters["exceptions"]],
		["puzzle-play", StringTable.puzzle_play_keys(), _owner_getters["puzzle-play"]],
	]


func _all_locales_populated() -> String:
	for suite in _all_locales_suites():
		var trouble := _owner_missing(suite)
		if not trouble.is_empty():
			return trouble
	return ""


## SCH-string-table I1/I2/I4/I5 for one `[owner, keys, getter]` suite (#483 gate):
## a key missing from any shipped locale names `owner.key`; a marked row must stay
## `en`-equal and a varying row must not read its `en` value. Shared by the shipped
## check above and `_copy_gate_negative_cases`, so there is one mechanism, not two.
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


## The shipped `puzzle-play` suite, or an empty-key suite when the owner is not shipped.
func _puzzle_play_suite() -> Array:
	var suite := _all_locales_suite("puzzle-play")
	if not suite.is_empty():
		return suite
	return ["puzzle-play", PackedStringArray(), Callable(StringTable, "puzzle_play")]


## #334 non-vacuity proof: the shipped `puzzle-play` suite passes the gate above,
## and each mutation the leaf names is reported with its `owner.key` message. A
## dropped `zh-Hant` key and an `en`-copied varying key must fail; the same copy on
## a marked `L3` piece row must pass. A green run therefore cannot mean the owner
## stopped being checked — the checks are exercised, not just satisfied.
func _copy_gate_negative_cases() -> String:
	var suite := _puzzle_play_suite()
	var owner := str(suite[0])
	var clean := _owner_missing(suite)
	if not clean.is_empty():
		return "shipped %s fails its own gate: %s" % [owner, clean]
	var dropped: Array = [owner, suite[1], _with_row(suite[2], "cue_failed", "zh-Hant", "")]
	var want_missing := "%s.cue_failed missing in zh-Hant" % owner
	if _owner_missing(dropped) != want_missing:
		return "a dropped zh-Hant key passed the gate"
	var copied: Array = [owner, suite[1], _with_row(suite[2], "reveal", "ja", "Reveal")]
	var want_english := "%s.reveal still English in ja" % owner
	if _owner_missing(copied) != want_english:
		return "an en-copied varying key passed the gate"
	var marked := _with_row(suite[2], "queen", "ja", "Queen")
	var marked_trouble := _owner_missing([owner, suite[1], marked])
	if not marked_trouble.is_empty():
		return "an en-copied marked piece row failed the gate: %s" % marked_trouble
	return ""


## `base` with `key` in `locale` replaced by `value`, all other reads unchanged.
func _with_row(base: Callable, key: String, locale: String, value: String) -> Callable:
	return func(read_key: String, read_locale: String) -> String:
		if read_key == key and read_locale == locale:
			return value
		return str(base.call(read_key, read_locale))


## SCH-string-table I5 / L3: the `mode-pick` own name is not a stored key
## (`game/string_table.gd` synthesizes it from LOCALE_OWN_NAME), so it asserts
## own-name identity per locale through the same read `_locale_helpers` uses.
func _marked_rows_en_equal() -> String:
	return _locale_own_names()


## The `[owner, keys, getter]` suite for one owner, or an empty array.
func _all_locales_suite(owner: String) -> Array:
	for suite in _all_locales_suites():
		if str(suite[0]) == owner:
			return suite
	return []


func _all_owner_getter(owner: String) -> Callable:
	for suite in _all_locales_suites():
		if str(suite[0]) == owner:
			return suite[2]
	return Callable()


func _locale_own_names() -> String:
	for locale in StringTable.LOCALES:
		var want := str(StringTable.LOCALE_OWN_NAME[locale])
		if StringTable.mode_pick("locale", locale) != want:
			return "mode-pick.locale own name wrong in %s" % locale
	return ""


## L3 drift guard: the marked set is exactly L3's named rows, every marked row is a
## shipped copy key, and a marked row's `en` value stays its canonical piece name.
func _marked_rows_match_l3() -> String:
	var shipped := {}
	for suite in _all_locales_suites():
		shipped[str(suite[0])] = suite[2]
	for owner in MARKED_OWNERS:
		if not shipped.has(owner):
			return "marked owner %s has no copy keys" % owner
		var getter: Callable = shipped[owner]
		var marked: Array = StringTable.EVERY_LOCALE_ROWS[owner]
		for key in marked:
			if not StringTable.piece_name_keys().has(key):
				continue
			var en := str(getter.call(key, "en"))
			var want := StringTable.piece_name(key)
			if en != want:
				return "%s.%s en value is not the canonical name" % [owner, key]
	var marked := _marked_pairs()
	marked.sort()
	var named := _l3_named_pairs()
	named.sort()
	if marked != named:
		return "marked rows %s disagree with L3's %s" % [marked, named]
	return ""


## A screen table that only cites another owner (`*_controls`) resolves through
## the owner it cites.
func _citation_owner(owner: String) -> String:
	if owner.ends_with("-controls"):
		return owner.trim_suffix("-controls")
	return ""


## `owner.key` for every row in `StringTable.EVERY_LOCALE_ROWS`, in table order.
func _marked_pairs() -> Array:
	var pairs: Array = []
	for owner in StringTable.EVERY_LOCALE_ROWS:
		var rows: Array = StringTable.EVERY_LOCALE_ROWS[owner]
		for key in rows:
			pairs.append("%s.%s" % [owner, key])
	return pairs


## L3's prose as `owner.key`: the `mode-pick` own name plus the piece names of
## every other marked owner.
func _l3_named_pairs() -> Array:
	var pairs: Array = ["mode-pick.locale"]
	for owner in MARKED_OWNERS:
		if owner == "mode-pick":
			continue
		for name in StringTable.piece_name_keys():
			pairs.append("%s.%s" % [owner, name])
	return pairs


## SCH-string-table I5 for puzzle-play: every key varies by locale except the four
## piece names L3 marks as same in every locale.
func _no_english_leak_in_puzzle_play() -> String:
	for locale in StringTable.LOCALES:
		if locale == "en":
			continue
		for key in StringTable.puzzle_play_keys():
			var text := StringTable.puzzle_play(key, locale)
			if StringTable.every_locale_row("puzzle-play", key):
				continue
			if text == StringTable.puzzle_play(key, "en"):
				return "puzzle-play.%s still English in %s" % [key, locale]
	return ""


## SCH-string-table completeness gate (#483): the shipped tables carry exactly the
## keys every Copy table names, per owner, the shipped owner set is the one the
## Copy tables derive, and the spec source is reachable.
func _spec_copy_key_sets() -> String:
	var specs_root := OS.get_environment("CHESS_SPECS_ROOT")
	if specs_root.is_empty():
		return "CHESS_SPECS_ROOT is unset; the parity gate cannot read specs/"
	if not DirAccess.dir_exists_absolute(specs_root):
		return "CHESS_SPECS_ROOT is missing: %s" % specs_root
	var spec := _spec_copy_keys(specs_root)
	var problem := str(spec.problems[0]) if not spec.problems.is_empty() else ""
	if problem.is_empty() and spec.negative.is_empty():
		problem = "a spec key absent from the shipped table passed the gate"
	if problem.is_empty():
		problem = _owners_match_spec(spec.owners)
	if problem.is_empty():
		problem = _owners_match_shipped(spec.owners)
	if problem.is_empty():
		problem = _owner_set_negative_case(spec.owners)
	return problem


## Each owner's shipped key set against the one its Copy table names.
func _owners_match_spec(owners: Dictionary) -> String:
	for owner in owners:
		var keys := _spec_owner_keys(owner, owners[owner])
		if keys.size() == 1 and keys[0].begins_with("@"):
			return str(keys[0]).substr(1)
	return ""


## #483 owner-set cross-check: the owner set the Copy tables derive is the six
## shipped owners, both ways. Per-owner key parity alone passes when a whole owner
## stops being read, so the set is compared too. #495's schema owner input does not
## exist yet (`F2` is still a field, not a list), so the shipped suites are the
## input here; when it lands, read it instead of `_all_locales_suites()`.
func _owners_match_shipped(owners: Dictionary) -> String:
	for owner in owners:
		if not _resolves_to_shipped(owner):
			return "%s has a Copy table but ships no table" % owner
	for suite in _all_locales_suites():
		var owner := str(suite[0])
		if not _named_by_copy_table(owner, owners):
			return "%s ships but no Copy table names it" % owner
	return ""


## An owner ships directly, or through the owner its `*_controls` table cites.
func _resolves_to_shipped(owner: String) -> bool:
	var cited := _citation_owner(owner)
	for suite in _all_locales_suites():
		var shipped := str(suite[0])
		if shipped == owner or (not cited.is_empty() and shipped == cited):
			return true
	return false


func _named_by_copy_table(shipped_owner: String, owners: Dictionary) -> bool:
	for owner in owners:
		if owner == shipped_owner or _citation_owner(owner) == shipped_owner:
			return true
	return false


## A dropped owner must fail by name, so a green run cannot mean the owner-set
## cross-check compared nothing.
func _owner_set_negative_case(owners: Dictionary) -> String:
	var owner := "puzzle-play"
	if not owners.has(owner):
		return "specs/ names no %s Copy table; the owner cross-check cannot be proven" % owner
	var dropped := owners.duplicate()
	dropped.erase(owner)
	var trouble := _owners_match_shipped(dropped)
	if not trouble.begins_with(owner):
		return "a dropped %s owner passed the owner-set cross-check" % owner
	return ""


## The owner's shipped keys, or one `@`-prefixed problem message.
func _spec_owner_keys(owner: String, want_source: PackedStringArray) -> PackedStringArray:
	var suite := _all_locales_suite(owner)
	if suite.is_empty():
		suite = _all_locales_suite(_citation_owner(owner))
	if suite.is_empty():
		return PackedStringArray(["@%s ships no table" % [owner, want_source[0]]])
	var keys: PackedStringArray = suite[1]
	var want := _stored_copy_keys(owner, want_source)
	var trouble := ""
	for key in want:
		if not keys.has(key):
			trouble += "%s.%s in specs/ is absent from the shipped table; " % [owner, key]
	for key in keys:
		if not want.has(key):
			trouble += "%s.%s ships but specs/ names no such key; " % [owner, key]
	if trouble.is_empty():
		return keys
	return PackedStringArray(["@" + trouble.trim_suffix("; ")])


## Every Copy table under `specs/ux/screens/` plus the `exceptions` Key column,
## as owner → keys in table order. An `exceptions` Key-column entry the shipped
## table does not carry belongs to another owner (or is `EX.error`), so
## the column is checked as a subset of the shipped keys rather than absorbed.
func _spec_copy_keys(specs_root: String) -> Dictionary:
	var owners := _screen_copy_keys(specs_root.path_join("ux/screens"))
	var problems: Array = []
	var exceptions_path := specs_root.path_join("ux/exceptions.md")
	if not FileAccess.file_exists(exceptions_path):
		problems.append("specs/ux/exceptions.md is missing")
	else:
		_read_exception_keys(exceptions_path, owners, problems)
	var negative := "" if _synthetic_key_absent_from_shipped().is_empty() else "proven"
	return {"owners": owners, "problems": problems, "negative": negative}


## An `exceptions` Key-column entry the shipped table carries is an `exceptions`
## key; one it does not is another owner's, and the column must name every
## shipped `exceptions` key.
func _read_exception_keys(path: String, owners: Dictionary, problems: Array) -> void:
	var column := _exception_column_key(path)
	if column.is_empty():
		problems.append("the exceptions Key column names no key")
	var shipped: PackedStringArray = StringTable.exception_keys()
	for key in column:
		if shipped.has(key):
			owners["exceptions"] = _appended(owners.get("exceptions", PackedStringArray()), key)
	for key in shipped:
		if not column.has(key):
			problems.append("exceptions.%s ships but the Key column names it nowhere" % key)


## Every screen's `## Copy` table keys, by owner.
func _screen_copy_keys(screens: String) -> Dictionary:
	var owners: Dictionary = {}
	for file_name in DirAccess.get_files_at(screens):
		if not file_name.ends_with(".md") or file_name.begins_with("_"):
			continue
		var owner := file_name.trim_suffix(".md")
		var keys := _copy_table_keys(FileAccess.get_file_as_string(screens.path_join(file_name)))
		if not keys.is_empty():
			owners[owner] = keys
	return owners


## The negative direction, proven on every run: a synthetic spec whose `mode-pick`
## Copy table names `gate_negative_probe` must be seen as a key the shipped table
## lacks, so a green run cannot mean the gate read nothing.
func _synthetic_key_absent_from_shipped() -> String:
	var markdown := "## Copy\n\n| Key | String | Used in |\n"
	markdown += "|-----|--------|---------|\n| gate_negative_probe | Probe | S1 |\n"
	var want := _stored_copy_keys("mode-pick", _copy_table_keys(markdown))
	var shipped: PackedStringArray = StringTable.mode_pick_keys()
	for key in want:
		if not shipped.has(key):
			return key
	return ""


func _appended(keys: PackedStringArray, key: String) -> PackedStringArray:
	var out := PackedStringArray(keys)
	out.append(key)
	return out


## Rows of a screen's `## Copy` table only: a bare Key cell is a key; an
## `owner.key` citation names another owner's key and adds none.
func _copy_table_keys(markdown: String) -> PackedStringArray:
	var keys := PackedStringArray()
	var in_copy := false
	for line in markdown.split("\n"):
		var row := line.strip_edges()
		if row.begins_with("## "):
			in_copy = row == "## Copy"
			continue
		if not in_copy or not row.begins_with("|"):
			continue
		var cell := row.split("|")[1].strip_edges().to_lower()
		if cell.is_empty() or cell == "key" or cell.contains("---") or cell.contains("fill in"):
			continue
		if cell.begins_with("`") or cell.contains("."):
			continue
		keys.append(cell)
	return keys


## `specs/ux/exceptions.md` Key column: bare identifiers are `exceptions` keys;
## `owner.key` cites another owner; `none` and trailing qualifiers add none.
func _exception_column_key(path: String) -> PackedStringArray:
	var keys := PackedStringArray()
	for line in FileAccess.get_file_as_string(path).split("\n"):
		var row := line.strip_edges()
		if not row.begins_with("|") or not row.contains("`EX."):
			continue
		var cells := row.split("|")
		if cells.size() < 3:
			continue
		for entry in cells[2].split(","):
			var word := entry.strip_edges().replace("`", "").split(" ")[0]
			if word.is_empty() or word == "none" or word.contains("."):
				continue
			keys.append(word)
	return keys


## The own-name row (`mode-pick.locale`) is resolved from `LOCALE_OWN_NAME`, not
## stored in the owner table, so it is not a shipped copy key.
func _stored_copy_keys(owner: String, keys: PackedStringArray) -> PackedStringArray:
	var kept := PackedStringArray()
	for key in keys:
		if owner == "mode-pick" and key == "locale":
			continue
		kept.append(key)
	return kept


func _locale_helpers() -> String:
	var err := ""
	if StringTable.next_locale("en") != "zh-Hant":
		err = "next_locale en"
	elif StringTable.next_locale("zh-Hant") != "ja":
		err = "next_locale zh-Hant"
	elif StringTable.next_locale("ja") != "en":
		err = "next_locale ja"
	elif StringTable.locale_from_os("zh_TW") != "zh-Hant":
		err = "os zh"
	elif StringTable.locale_from_os("ja_JP") != "ja":
		err = "os ja"
	elif StringTable.mode_pick("locale", "en") != "English":
		err = "own name en"
	elif StringTable.mode_pick("locale", "zh-Hant") != "繁體中文":
		err = "own name zh"
	elif StringTable.mode_pick("locale", "ja") != "日本語":
		err = "own name ja"
	elif StringTable.shared_setup("start", "zz") != "Start":
		err = "unshipped locale falls back to en"
	return err


func _font_chain_and_glyphs() -> String:
	var resolver := _presentation.get_node_or_null("AssetResolver") as AssetResolver
	if resolver == null:
		return "AssetResolver missing"
	var latin := resolver.resolve(UiChrome.FONT_LATIN) as Font
	var cjk := resolver.resolve(UiChrome.FONT_CJK) as Font
	if latin == null or cjk == null:
		return "UI fonts did not resolve"
	if cjk.fallbacks.is_empty():
		return "CJK catalog asset missing JP fallback face"
	var faces: Array[Font] = [cjk]
	latin.fallbacks = faces
	_ui_font = latin
	var suites: Array = [
		[StringTable.mode_pick_keys(), Callable(StringTable, "mode_pick")],
		[StringTable.shared_setup_keys(), Callable(StringTable, "shared_setup")],
		[StringTable.shared_play_keys(), Callable(StringTable, "shared_play")],
		[StringTable.shared_result_keys(), Callable(StringTable, "shared_result")],
		[StringTable.exception_keys(), Callable(StringTable, "exception_text")],
	]
	for locale in StringTable.LOCALES:
		for suite in suites:
			var keys: PackedStringArray = suite[0]
			var getter: Callable = suite[1]
			for key in keys:
				var text := str(getter.call(key, locale))
				var missing := _missing_glyphs(latin, text)
				if not missing.is_empty():
					return "missing glyphs in %s/%s: %s" % [locale, key, missing]
	var clock_missing := _missing_glyphs(latin, "0:00 / 59:59")
	if not clock_missing.is_empty():
		return "clock glyphs missing: %s" % clock_missing
	return ""


func _missing_glyphs(font: Font, text: String) -> String:
	var missing := ""
	for index in text.length():
		var code := text.unicode_at(index)
		if code <= 0x20:
			continue
		if _chain_has_char(font, code):
			continue
		var ch := String.chr(code)
		if not missing.contains(ch):
			missing += ch
	return missing


func _chain_has_char(font: Font, code: int) -> bool:
	if font == null:
		return false
	if font.has_char(code):
		return true
	for fallback in font.fallbacks:
		if fallback is Font and _chain_has_char(fallback as Font, code):
			return true
	return false


func _screen_layouts_at_growth() -> String:
	_presentation.size = VIEW_SIZE
	await process_frame
	await process_frame
	var err := await _check_mode_pick_layouts()
	if err.is_empty():
		err = await _check_shared_setup_layout()
	if err.is_empty():
		err = await _check_shared_play_layouts()
	if err.is_empty():
		err = await _check_shared_result_layout()
	return err


func _check_mode_pick_layouts() -> String:
	if _router.stage != "mode-pick":
		return "expected mode-pick"
	for locale in StringTable.LOCALES:
		_router.locale = locale
		_router._go_mode_pick("S1")
		await process_frame
		var panel := _mode_pick()
		for state_id in ["S1", "S3", "S4"]:
			panel.set_ui_state(state_id)
			await process_frame
			var err := await _assert_readable(panel, "mode-pick %s %s" % [locale, state_id])
			if not err.is_empty():
				return err
	_router.locale = "en"
	_router._go_mode_pick("S1")
	await process_frame
	return ""


## L4 for `shared-setup` C4: one label joins `advice` with `advice_on` or
## `advice_off`, so each locale drives the pair Off, then On, asserting the router
## flag flipped and the row joined the member that state renders before the +40%
## pass. The entry flag is restored after the sweep, so a future default cannot
## leak this sweep's last toggle into `_check_shared_play_layouts`.
func _check_shared_setup_layout() -> String:
	_router.handle_control("mode-pick", "C1")
	await process_frame
	if _router.stage != "shared-setup":
		return "expected shared-setup"
	var entry_on := _router.advice_on
	for locale in StringTable.LOCALES:
		_router.locale = locale
		var err := await _drive_setup_advice(locale, false, entry_on)
		if err.is_empty():
			err = await _drive_setup_advice(locale, true, entry_on)
		if not err.is_empty():
			return err
	if _router.advice_on != entry_on:
		_router.handle_control("shared-setup", "C4")
	_router.locale = "en"
	_router.screen_requested.emit("shared-setup", _router._shared_setup_state())
	await process_frame
	if _router.advice_on != entry_on:
		return "shared-setup C4 did not restore its entry flag"
	_router.handle_control("shared-setup", "C6")
	await process_frame
	return ""


## One C4 cell: bring the toggle to `want_on`, assert it, then read the row.
func _drive_setup_advice(locale: String, want_on: bool, entry_on: bool) -> String:
	if _router.advice_on != want_on:
		_router.handle_control("shared-setup", "C4")
		await process_frame
	if _router.advice_on != want_on:
		return "shared-setup %s C4 did not toggle to %s" % [locale, "On" if want_on else "Off"]
	var panel := _shared_setup()
	var want := _setup_advice_line(locale, want_on)
	var row := panel.find_child("Advice", true, false) as Button
	if row == null:
		return "shared-setup %s has no C4 row" % locale
	if row.text != want:
		return "shared-setup %s C4 %s reads %s, want %s" % [
			locale, "On" if want_on else "Off", row.text, want
		]
	var tag := "shared-setup %s C4 %s" % [locale, "On" if want_on else "Off"]
	var err := await _assert_readable(panel, tag)
	if not err.is_empty():
		return err
	if entry_on == want_on:
		return ""
	## Return to the entry flag so the next locale starts from the same state.
	_router.handle_control("shared-setup", "C4")
	await process_frame
	if _router.advice_on != entry_on:
		return "shared-setup %s C4 did not toggle back" % locale
	return ""


## The C4 label as `shared_setup.advice · shared_setup.advice_on|advice_off`.
func _setup_advice_line(locale: String, advice_on: bool) -> String:
	var member := "advice_on" if advice_on else "advice_off"
	return (
		"%s · %s"
		% [StringTable.shared_setup("advice", locale), StringTable.shared_setup(member, locale)]
	)


func _check_shared_play_layouts() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	await process_frame
	if _router.stage != "shared-play" or _router.shared_session == null:
		return "expected shared-play"
	var board := _board()
	var err := ""
	for locale in StringTable.LOCALES:
		_router.locale = locale
		err = await _drive_play_locale(locale)
		if not err.is_empty():
			break
		if board.offset_top < _presentation.play_chrome_top_px() - 0.5:
			err = "shared-play %s cropped board under chrome" % locale
			break
	_router.locale = "en"
	_router.shared_session.play_ui_state = SharedGameSession.UI_S1
	_router.shared_session.confirm_kind = ""
	_router.shared_session.draw_offer = ""
	_router.shared_session.advice_error = false
	_router._emit_play_screen()
	await process_frame
	return err


func _drive_play_locale(locale: String) -> String:
	## Fourth element is `advice_error`: `EX.error` / S3 is the only state that
	## renders `shared-play.advice_error` and `dismiss`. Every other entry clears it,
	## so no locale starts the next drive on a stale S3.
	var states: Array = [
		["S1", SharedGameSession.UI_S1, "", false],
		["S2-resign", SharedGameSession.UI_S2, SharedGameSession.CONFIRM_RESIGN, false],
		["S3", SharedGameSession.UI_S3, "", true],
		["S4", SharedGameSession.UI_S4, "", false],
		["S5", SharedGameSession.UI_S5, "", false],
		["S6", SharedGameSession.UI_S6, "", false],
	]
	for entry in states:
		var err := await _drive_play_chrome(
			locale, str(entry[0]), str(entry[1]), str(entry[2]), bool(entry[3])
		)
		if not err.is_empty():
			return err
	return ""


func _drive_play_chrome(
	locale: String, label: String, ui_state: String, confirm: String, advice_error: bool
) -> String:
	var session := _router.shared_session
	session.play_ui_state = ui_state
	session.confirm_kind = confirm
	session.draw_offer = "white" if ui_state == SharedGameSession.UI_S6 else ""
	session.advice_error = advice_error
	_router._emit_play_screen()
	await process_frame
	var panel := _play_panel()
	if advice_error:
		## S3 producer: the box is shown and carries exactly the two S3 rows, so a
		## `pass` cannot come from an absent or untranslated row.
		var err := _s3_producer(panel, locale)
		if not err.is_empty():
			return err
	return await _assert_readable(panel, "shared-play %s %s" % [locale, label])


## S3 `EX.error` producer: the box is shown and carries exactly the two S3 rows,
## so a `pass` cannot come from an absent or untranslated row.
func _s3_producer(panel: SharedPlayPanel, locale: String) -> String:
	var box := panel.get_node_or_null("AdviceError") as Control
	if box == null or not box.visible:
		return "shared-play %s S3 advice error box hidden" % locale
	var msg := box.find_child("AdviceErrorMsg", true, false) as Label
	if msg == null or not msg.visible:
		return "shared-play %s S3 AdviceErrorMsg hidden" % locale
	var want_msg := StringTable.shared_play("advice_error", locale)
	if msg.text != want_msg:
		return "shared-play %s S3 AdviceErrorMsg reads %s, want %s" % [locale, msg.text, want_msg]
	var dismiss := box.find_child("AdviceErrorDismiss", true, false) as Button
	if dismiss == null or not dismiss.visible:
		return "shared-play %s S3 AdviceErrorDismiss hidden" % locale
	var want_dismiss := StringTable.shared_play("dismiss", locale)
	if dismiss.text != want_dismiss:
		return "shared-play %s S3 AdviceErrorDismiss reads %s, want %s" % [
			locale, dismiss.text, want_dismiss
		]
	return ""


func _check_shared_result_layout() -> String:
	if _router.stage == "shared-play":
		_router.handle_control("shared-play", "C4")
		_router.handle_control("shared-play", "confirm")
		await process_frame
	if _router.stage != "shared-result":
		_presentation.show_screen(
			Presentation.SHARED_RESULT, {"locale": "en", "result_key": "result_draw"}
		)
		await process_frame
	for locale in StringTable.LOCALES:
		_shared_result().configure(locale, "result_draw", _ui_font)
		await process_frame
		var err := await _assert_readable(_shared_result(), "shared-result %s" % locale)
		if not err.is_empty():
			return err
	return ""


func _assert_readable(panel: Control, tag: String) -> String:
	if panel == null or not panel.visible:
		return "%s panel hidden" % tag
	## Finish UIS.M1 so asserts see settled chrome, not a mid-fade panel.
	_settle_motion(panel)
	await process_frame
	var err := _assert_visible_copy(panel, tag)
	if not err.is_empty():
		return err
	return await _assert_grown_copy(panel, tag)


func _settle_motion(node: Node) -> void:
	## Only finish UIS.M1 fades; leave intentional a=0 focus sentinels alone.
	if node.has_meta("_uis_m1_tween"):
		var prior: Variant = node.get_meta("_uis_m1_tween")
		if prior is Tween:
			(prior as Tween).kill()
		if node is CanvasItem:
			(node as CanvasItem).modulate.a = 1.0
	for child in node.get_children():
		_settle_motion(child)


func _assert_visible_copy(panel: Control, tag: String) -> String:
	var frame := Rect2(Vector2.ZERO, VIEW_SIZE)
	var saw_text := false
	for node in _player_facing_text(panel):
		saw_text = true
		if node is Button and (node as Button).clip_text:
			return "%s clips text on %s" % [tag, node.name]
		var text := _control_text(node)
		if text.is_empty():
			return "%s empty copy on %s" % [tag, node.name]
		var rect := node.get_global_rect()
		if rect.size.x <= 1.0 or rect.size.y <= 1.0:
			continue
		if not frame.intersects(rect):
			return "%s %s outside frame at %s" % [tag, node.name, str(rect)]
		if node is Button:
			if node.size.y + 0.5 < UiChrome.MIN_TOUCH:
				return "%s touch height on %s" % [tag, node.name]
	if not saw_text:
		return "%s no player-facing text" % tag
	return ""


func _assert_grown_copy(panel: Control, tag: String) -> String:
	## quality.md Localization: tolerate ~40% length growth versus English.
	var originals: Dictionary = {}
	for node in _player_facing_text(panel):
		var current := _control_text(node)
		originals[node] = current
		_set_control_text(node, _grow(current))
	await process_frame
	var err := _assert_visible_copy(panel, "%s +40%%" % tag)
	for node in originals.keys():
		_set_control_text(node as Control, str(originals[node]))
	return err


func _grow(text: String) -> String:
	var extra := int(ceili(float(text.length()) * GROWTH))
	if extra <= 0:
		return text
	return text + text.substr(0, mini(extra, text.length()))


func _player_facing_text(root: Node) -> Array[Control]:
	var out: Array[Control] = []
	_collect_facing(root, out)
	return out


func _collect_facing(node: Node, out: Array[Control]) -> void:
	if node is CanvasItem and not (node as CanvasItem).visible:
		return
	if node is Label or node is Button:
		var control := node as Control
		## Skip focus-only sentinels (promote / select / place ghosts).
		if control.modulate.a >= 0.05 and not _control_text(control).is_empty():
			out.append(control)
		return
	for child in node.get_children():
		_collect_facing(child, out)


func _control_text(node: Control) -> String:
	if node is Label:
		return (node as Label).text
	if node is Button:
		return (node as Button).text
	return ""


func _set_control_text(node: Control, text: String) -> void:
	if node is Label:
		(node as Label).text = text
	elif node is Button:
		(node as Button).text = text


func _mode_pick() -> ModePickPanel:
	return _presentation.get_node("ScreenHost/ModePick") as ModePickPanel


func _shared_setup() -> SharedSetupPanel:
	return _presentation.get_node("ScreenHost/SharedSetup") as SharedSetupPanel


func _play_panel() -> SharedPlayPanel:
	return _presentation.get_node("ScreenHost/SharedPlay") as SharedPlayPanel


func _shared_result() -> SharedResultPanel:
	return _presentation.get_node("ScreenHost/SharedResult") as SharedResultPanel


func _board() -> BoardPresentation:
	return _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation
