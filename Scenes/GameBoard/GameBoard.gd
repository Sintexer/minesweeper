class_name GameBoard extends Node

var rows: int = 0
var cols: int = 0
var mines_percent: float = 0.15
var cells: Array[Array] = []
var mines_number: int = 0
var hidden_tiles: int = 0

var flags: int = 0

var temp_revealed: Array[Cell] = []
var revealed_wave: Array[Cell] = []

signal game_over(is_win: bool)
signal cell_updated(cell: Cell)
signal reveal_wave(cells: Array[Cell], wave_index: int)

func set_up(difficulty: Difficulty) -> void:
	flags = 0
	rows = difficulty.rows
	cols = difficulty.cols
	mines_percent = difficulty.mines_percent
	generate_cells()
	set_up_cel_numbers_and_mines()
	hidden_tiles = rows * cols - mines_number
	print_grid()
	
func generate_cells() -> void:
	cells.clear()
	cells.resize(rows)
	
	for i in range(rows):
		var row: Array[Cell] = []
		row.resize(cols)
		cells[i] = row
		for j in range(cols):
			var cell: Cell = Cell.new()
			cell.set_up(i, j, i * cols + j)
			row[j] = cell


func set_up_cel_numbers_and_mines() -> void:
	var mines = generate_mines_indices()
	
	for i in mines:
		@warning_ignore("integer_division")
		var row: int = i / cols
		var col: int = i % cols
		var cell: Cell = cells[row][col]
		cell.is_mine = true
		add_one_to_nearest_cells(row, col)

func generate_mines_indices() -> Array[int]:
	var size: int = rows * cols
	mines_number = ceil(size * mines_percent)
	var mines: Array[int] = []
	while mines.size() < mines_number:
		var index = randi_range(0, size - 1)
		if !mines.has(index):
			mines.append(index)
	mines.sort()
	print(mines)
	return mines
		
func add_one_to_nearest_cells(i: int, j: int) -> void:
	if i - 1 >= 0:
		if j - 1 >= 0:
			cells[i - 1][j - 1].number += 1
		cells[i - 1][j].number += 1
		if j + 1 < cols:
			cells[i - 1][j + 1].number +=1
	if j - 1 >= 0:
		cells[i][j - 1].number += 1
	if j + 1 < cols:
		cells[i][j + 1].number += 1
	if i + 1 < rows:
		if j - 1 >= 0:
			cells[i + 1][j - 1].number += 1
		cells[i + 1][j].number += 1
		if j + 1 < cols:
			cells[i + 1][j + 1].number += 1

func get_cell_by_index(i: int) -> Cell:
	@warning_ignore("integer_division")
	var row: int = i / cols
	var col: int = i % cols
	return get_cell(row, col)

func get_cell(i: int, j: int) -> Cell:
	return cells[i][j]
	
func try_reveal_cell(cell: Cell) -> void:
	if cell.is_flagged: return
	
	reveal_cell(cell)
	cell_updated.emit(cell)
	
	if cell.is_mine:
		process_game_over()
	else:
		reveal_nearest_by_waves(cell)

	check_win_condition()
	
func reveal_nearest_by_waves(cell: Cell) -> void:
	var wave: int = 1
	var nearest = temp_revealed
	revealed_wave.clear()
	revealed_wave.append(cell)
	while revealed_wave.size() > 0:
		nearest.clear()
		for c in revealed_wave:
			if c.number == 0:
				add_nearest_reveal(nearest, c)
				
		reveal_wave.emit(nearest, wave)
		revealed_wave.clear()
		revealed_wave.append_array(nearest)
		
		wave += 1
	
func add_nearest_reveal(reveal: Array[Cell], cell: Cell) -> void:
	var i = cell.i
	var j = cell.j
	if i - 1 >= 0:
		if j - 1 >= 0:
			add_if_empty(reveal, cells[i - 1][j - 1])
		add_if_empty(reveal, cells[i - 1][j])
		if j + 1 < cols:
			add_if_empty(reveal, cells[i - 1][j + 1])
	if j - 1 >= 0:
		add_if_empty(reveal, cells[i][j - 1])
	if j + 1 < cols:
		add_if_empty(reveal, cells[i][j + 1])
	if i + 1 < rows:
		if j - 1 >= 0:
			add_if_empty(reveal, cells[i + 1][j - 1])
		add_if_empty(reveal, cells[i + 1][j])
		if j + 1 < cols:
			add_if_empty(reveal, cells[i + 1][j + 1])
			
func add_if_empty(reveal: Array[Cell], cell: Cell) -> void:
	if !cell.is_mine && !cell.is_flagged && !cell.is_revealed:
		if !reveal.has(cell):
			reveal_cell(cell)
			reveal.append(cell)			

func reveal_cell(cell: Cell) -> void:
	cell.is_revealed = true
	hidden_tiles -= 1

func toggle_flag(cell: Cell) -> bool:
	"""Reruns true if flag toggled"""
	if cell.is_revealed: return false
	if !cell.is_flagged && flags >= mines_number: return false
	
	cell.is_flagged = !cell.is_flagged
	flags += 1 if cell.is_flagged else -1
	cell_updated.emit(cell)
	check_win_condition()
	return true
	
func check_win_condition() -> void:
	if hidden_tiles == 0:
		process_win()
		
func process_win() -> void:
	game_over.emit(true)

func process_game_over() -> void:
	game_over.emit(false)
	
func print_grid() -> void:
	print("-".repeat(15))
	for i in range(cells.size()):
		var row: Array[Cell] = cells[i]
		var row_text: String = ""
		for j in range(row.size()):
			var cell: Cell = row[j]
			row_text += str(cell.number) if !cell.is_mine else "_"
			row_text += " "
		print(row_text)
			
