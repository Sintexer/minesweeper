class_name Cell extends Node

var is_mine: bool = false
var is_flagged: bool = false
var is_revealed: bool = false
var reveal_wave_index: int = 0
var number: int = 0

var i: int = 0
var j: int = 0
var index: int = 0

func set_up(row: int, col: int, ind: int) -> void:
	self.i = row
	self.j = col
	self.index = ind
	
