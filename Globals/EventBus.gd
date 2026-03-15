extends Node

#signal game_over(is_win: bool)
#signal cell_updated(cell: Cell)
signal toggle_flag(cell: Cell)
signal reveal_cell(cell: Cell)
#signal reveal_wave(cells: Array[Cell], wave_index: int)

#func emit_game_over(is_win: bool):
	#game_over.emit(is_win)
#
#func emit_cell_updated(cell: Cell):
	#cell_updated.emit(cell)

func emit_toggle_flag(cell: Cell):
	toggle_flag.emit(cell)

func emit_reveal_cell(cell: Cell):
	reveal_cell.emit(cell)
	


#func emit_reveal_wave(cells: Array[Cell], wave_index: int):
	#reveal_wave.emit(cells, wave_index)
