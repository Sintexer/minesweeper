extends Node

# overlay
const BOMB = preload("uid://br4n64uv0dab5")
const BOMB_DEFUSED = preload("uid://cu3h252jv2rlh")
const FLAG = preload("uid://ljoa4et2t03h")

# revealed tiles
const TILE_1 = preload("uid://dqaatpj1lndqq")
const TILE_2 = preload("uid://dx55o8ouqqqqg")
const TILE_3 = preload("uid://dgkxhtjctgeic")
const TILE_4 = preload("uid://c1okmsu227jkd")
const TILE_5 = preload("uid://c5mpbm53gpovf")
const TILE_6 = preload("uid://ccp26ch16weiw")
const TILE_7 = preload("uid://dogrb7vk66gao")
const TILE_8 = preload("uid://bbbjyo046sr8s")
const TILE_EMPTY = preload("uid://ogitlljxs8h2")
const TILE_EXPLODED = preload("uid://bkoklxq8owvlv")

var sprite_map: Dictionary[String, Texture2D] = {}

func get_flag_texture() -> Texture2D:
	return FLAG

func get_cell_game_over_overlay_texture(c: Cell) -> Texture2D:	
	if c.is_mine: 
		if c.is_flagged:
			return BOMB_DEFUSED
		else:
			return BOMB
	else:
		return null
	

func get_cell_texture(c: Cell) -> Texture2D:	
	if c.number == 0 || c.is_mine:
		return null
	elif c.number == 1:
		return TILE_1
	elif c.number == 2:
		return TILE_2
	elif c.number == 3:
		return TILE_3
	elif c.number == 4:
		return TILE_4
	elif c.number == 5:
		return TILE_5
	elif c.number == 6:
		return TILE_6
	elif c.number == 7:
		return TILE_7
	else:
		return TILE_8
