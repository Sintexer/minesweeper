class_name Difficulty

var rows: int = 10
var cols: int = 20
var mines_percent: float = 0.13

static func create(r: int, c: int, mp: float) -> Difficulty:
	var instance: Difficulty = Difficulty.new()
	instance.rows = r
	instance.cols = c
	instance.mines_percent = mp
	return instance
