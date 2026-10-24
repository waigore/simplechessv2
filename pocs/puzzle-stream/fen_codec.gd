class_name DemoFenCodec
extends RefCounted
## FEN-to-position for demo #335. Spec source: F-puzzle-catalog R3 (a record's
## FEN is the position before the opponent moves), SCH-puzzle-catalog F3.
##
## The fixture slice records standard FEN strings; the demo's rules engine works
## on the demo position dictionary (see chess_rules.gd). This is the one place
## that converts between them. The demo needs the board, the side to move, and
## the castling field; castling is never played in a recorded puzzle line, so a
## FEN whose castling field is `-` offers none.

const WHITE := "w"
const BLACK := "b"

## FEN rank rows are listed rank 8 first; the demo board indexes a1 = 0, h8 = 63
## (chess_rules.gd), so the first row is written one rank up from the last.

## Parse one FEN into the demo position dictionary, or {} when it is not a FEN.
static func to_position(fen: String) -> Dictionary:
	# R3: the record's FEN becomes the board the first recorded move is applied to.
	var fields := fen.strip_edges().split(" ", false)
	if fields.size() < 2:
		return {}
	var board := to_board(fields[0])
	if board.is_empty():
		return {}
	var side := BLACK
	if fields[1] == "w":
		side = WHITE
	var castling := ""
	if fields.size() >= 3 and fields[2] != "-":
		castling = fields[2]
	return {
		"board": board,
		"moved": PackedByteArray(),
		"ep_target": -1,
		"castling": castling,
		"side": side,
		"king": {},
	}


## The FEN rank field as 64 square codes ("" for an empty square), indexed
## a1 = 0 .. h8 = 63. The field is read from its last row (rank 1) to its first
## (rank 8): a digit is a run of empty squares and a letter is a piece (upper
## case White). Empty when the field does not hold 8 files on every row, 8 rows,
## or exactly one king a side.
static func to_board(rank_field: String) -> PackedStringArray:
	var rows := str(rank_field).split("/", true)
	if rows.size() != 8:
		return PackedStringArray()
	var board := PackedStringArray()
	board.resize(64)
	for row_index in range(8):
		# FEN lists rank 8 first (row_index 0); the board starts at rank 1.
		var base := (7 - row_index) * 8
		var file := 0
		for ch in str(rows[row_index]):
			var text := str(ch)
			if text.is_valid_int():
				file += text.to_int()
				continue
			if file > 7:
				return PackedStringArray()
			var color := BLACK
			if text == text.to_upper():
				color = WHITE
			board[base + file] = color + text.to_upper()
			file += 1
		if file != 8:
			return PackedStringArray()
	if board.count("wK") != 1 or board.count("bK") != 1:
		return PackedStringArray()
	return board
