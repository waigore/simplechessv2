class_name PieceAccessibleNameTest
extends SceneTree
## CMP-presentation.R7 / `specs/ux/localization.md` L7–L9: every piece node names
## itself, in every shipped locale, from the Copy row its kind maps to (#643).

const PLAY_SCREENS := ["shared-play", "puzzle-play"]
const COLORS := ["white", "black"]


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var problem := _piece_ids_cover_every_kind()
	if problem.is_empty():
		problem = _l9_maps_every_kind()
	if problem.is_empty():
		problem = _every_piece_entry_named()
	if problem.is_empty():
		problem = _names_are_not_raw_keys()
	if problem.is_empty():
		problem = _marked_names_stay_en()
	if problem.is_empty():
		problem = _no_side_fragment()
	if problem.is_empty():
		problem = _unnamed_kind_reads_empty()
	_finish(problem)


func _finish(problem: String) -> void:
	if problem.is_empty():
		quit(0)
		return
	push_error(problem)
	quit(1)


## The observed surface: `PIECE_IDS` is twelve entries, six kinds × two colours.
func _piece_ids_cover_every_kind() -> String:
	var want := COLORS.size() * StringTable.piece_name_keys().size()
	if BoardPresentation.PIECE_IDS.size() != want:
		return "PIECE_IDS has %d entries, want %d" % [BoardPresentation.PIECE_IDS.size(), want]
	for color in COLORS:
		for kind in StringTable.piece_name_keys():
			if not BoardPresentation.PIECE_IDS.has("%s|%s" % [color, kind]):
				return "PIECE_IDS has no %s %s" % [color, kind]
	return ""


## L9 names one Copy key per kind, for all six kinds, and L7 marks both owners.
func _l9_maps_every_kind() -> String:
	var kinds: Array = []
	for entry in BoardPresentation.PIECE_IDS.keys():
		var kind := str(entry).get_slice("|", 1)
		if not kinds.has(kind):
			kinds.append(kind)
	if kinds.size() != 6:
		return "PIECE_IDS carries %d kinds, want 6" % kinds.size()
	for kind in kinds:
		var key := StringTable.piece_name_key(str(kind))
		if key.is_empty():
			return "L9 maps no Copy key for %s" % kind
		for owner in PLAY_SCREENS:
			if not StringTable.every_locale_row(owner, key):
				return "L7 does not mark %s.%s" % [owner, key]
	return ""


## One non-empty name per play screen, per `PIECE_IDS` entry, per locale, equal to
## the `StringTable` value of the L9 key for that kind and locale.
func _every_piece_entry_named() -> String:
	for screen in PLAY_SCREENS:
		for entry in BoardPresentation.PIECE_IDS.keys():
			var kind := str(entry).get_slice("|", 1)
			var key := StringTable.piece_name_key(kind)
			for locale in StringTable.LOCALES:
				var name := BoardPresentation.accessible_name(kind, str(screen), locale)
				if name.is_empty():
					return "%s %s has no accessible name in %s" % [screen, entry, locale]
				var want := _copy(str(screen), key, locale)
				if name != want:
					return "%s %s reads %s in %s, want %s" % [screen, entry, name, locale, want]
	return ""


## A resolved name is never the key itself (`CTR-localization` G4).
func _names_are_not_raw_keys() -> String:
	for screen in PLAY_SCREENS:
		for kind in StringTable.piece_name_keys():
			for locale in StringTable.LOCALES:
				if BoardPresentation.accessible_name(kind, str(screen), locale) == kind:
					return "%s %s is a raw key in %s" % [screen, kind, locale]
	return ""


## L7: all six type names read the `en` value in `zh-Hant` and `ja`, so a piece is
## called the same at every locale and by every reader.
func _marked_names_stay_en() -> String:
	for screen in PLAY_SCREENS:
		for kind in StringTable.piece_name_keys():
			var en := BoardPresentation.accessible_name(kind, str(screen), "en")
			for locale in StringTable.LOCALES:
				if locale == "en":
					continue
				if BoardPresentation.accessible_name(kind, str(screen), locale) != en:
					return "%s %s is translated in %s" % [screen, kind, locale]
	return ""


## L8: the name is the type — no side fragment and no colour.
func _no_side_fragment() -> String:
	var side_rows := ["white_to_move", "black_to_move"]
	for screen in PLAY_SCREENS:
		for kind in StringTable.piece_name_keys():
			var name := BoardPresentation.accessible_name(kind, str(screen), "en")
			for row in side_rows:
				if name.contains(StringTable.shared_play(row, "en")) or name.contains(row):
					return "%s %s carries the side fragment %s" % [screen, kind, row]
			for color in COLORS:
				if name.findn(color) >= 0:
					return "%s %s carries the colour %s" % [screen, kind, color]
	return ""


## A kind L9 does not map, and an owner that draws no pieces, expose no name rather
## than a hard-coded English one.
func _unnamed_kind_reads_empty() -> String:
	if not BoardPresentation.accessible_name("dragon", "shared-play", "en").is_empty():
		return "an unmapped kind was given a name"
	if not BoardPresentation.accessible_name("queen", "mode-pick", "en").is_empty():
		return "mode-pick was given a piece name"
	return ""


func _copy(screen: String, key: String, locale: String) -> String:
	if screen == "puzzle-play":
		return StringTable.puzzle_play(key, locale)
	return StringTable.shared_play(key, locale)
