class_name Minefield extends Control

const GRID_BUTTON = preload("uid://dorufvfhi1g8a")
const NEXT_TILE_REVEAL_TIMEOUT: float = 0.05
const INTIAL_ROW_ANIMATION_DELAY: float = 0.1
const NEXT_ROW_ANIMATION_DELAY: float = 0.03

const FLAG_SOUND: AudioStream = preload("uid://c24sj0f5wj8aw")
const UNFLAG_SOUND: AudioStream = preload("uid://0dadcsopcynp")
const FLAG_CANT_SOUND: AudioStream = preload("uid://85t1nch3gn8")
const TILE_SPAWN_SOUND = preload("uid://budo0po32rsgw")


const PITCH_VARIATION: Vector2 = Vector2(0.85, 1.15)

@onready var grid_wrapper: AspectRatioContainer = %GridWrapper
@onready var tiles: GridContainer = %Tiles
var game_board: GameBoard
@onready var interaction_block: Panel = %InteractionBlock
@onready var wave_sound: AudioStreamPlayer = $WaveSound
@onready var flag_sound: AudioStreamPlayer = $FlagSound

signal flags_updated(flags_left: int)

func _ready() -> void:
	EventBus.toggle_flag.connect(on_flag_toggle)
	EventBus.reveal_cell.connect(on_reveal_cell)
	
func set_up(difficulty: Difficulty, gb: GameBoard) -> void:
	interaction_block.hide()
	game_board = gb
	for tile: GridButton in tiles.get_children():
		tiles.remove_child(tile)
		tile.queue_free()
	generate_grid(difficulty.rows, difficulty.cols)
	play_grid_init_animation()
	
func generate_grid(rows: int, cols: int) -> void:
	update_grid_ratio(rows, cols)
	var grid_size: int = rows * cols
	tiles.columns = cols
	for i in range(grid_size): 
		var tile: GridButton = GRID_BUTTON.instantiate()
		tiles.add_child(tile)
		tile.set_up(game_board.get_cell_by_index(i))

func play_grid_init_animation() -> void:
	var sequence_tween = create_tween()
	var center_col = (game_board.cols - 1) / 2.0
	var scheduled_sounds: Dictionary = {}
	for i in range(game_board.rows):
		for j in range(game_board.cols):
			var tile_index = i * game_board.cols + j
			var tile: GridButton = tiles.get_children()[tile_index]
			var h_distance: int = int(abs(j - center_col))
			var wave_step = i + h_distance
			var delay = sqrt(wave_step * NEXT_ROW_ANIMATION_DELAY)
			sequence_tween.parallel().tween_callback(tile.play_start_animation).set_delay(delay)
			if !scheduled_sounds.has(wave_step):
				scheduled_sounds[wave_step] = true
				sequence_tween.parallel().tween_callback(_play_wave_spawn_sound).set_delay(delay)

func animate_row(row_index: int) -> void:
	for i in range(game_board.cols):
		var tile_index = row_index * game_board.cols + i
		var tile: GridButton = tiles.get_children()[tile_index]
		tile.play_start_animation()

func on_flag_toggle(cell: Cell) -> void:
	var toggled = game_board.toggle_flag(cell)
	if toggled:
		play_sound(flag_sound, UNFLAG_SOUND if cell.is_flagged else FLAG_SOUND)
	else:
		play_sound(flag_sound, FLAG_CANT_SOUND)
	
	flags_updated.emit(get_flags_left())

func get_flags_left() -> int:
	return game_board.mines_number - game_board.flags

func on_cell_update(cell: Cell) -> void:
	get_grid_button(cell).on_update()
	
func on_reveal_cell(cell: Cell) -> void:
	game_board.try_reveal_cell(cell)
	
func on_game_over() -> void:
	interaction_block.show()
	for grid_button: GridButton in tiles.get_children():
		grid_button.on_game_over()

func block_interaction() -> void:
	interaction_block.show()

func get_grid_button(cell: Cell) -> GridButton:
	return tiles.get_children()[cell.index]
	
func on_reveal_wave(cells: Array[Cell], wave_index: int):
	var saved_cells: Array[Cell] = []
	saved_cells.append_array(cells)
	if wave_index == 0:
		execute_reveal_wave(saved_cells)
	
	var tween: Tween = create_tween()
	var timeout: float = NEXT_TILE_REVEAL_TIMEOUT * wave_index
	tween.tween_interval(timeout)
	tween.tween_callback(execute_reveal_wave.bind(saved_cells))

func execute_reveal_wave(cells: Array[Cell]) -> void:
	wave_sound.stop()
	variate_pitch(wave_sound)
	wave_sound.play()
	for cell in cells:
		on_cell_update(cell)

func _play_wave_spawn_sound() -> void:
	play_sound(wave_sound, TILE_SPAWN_SOUND)

func play_sound(player: AudioStreamPlayer, audio: AudioStream) -> void:
	player.stop()
	variate_pitch(player)
	player.stream = audio
	player.play()
	
func variate_pitch(player: AudioStreamPlayer) -> void:
	player.pitch_scale = randf_range(PITCH_VARIATION.x, PITCH_VARIATION.y)
	
func update_grid_ratio(rows: int, cols: int) -> void:
	grid_wrapper.ratio = float(cols) / float(rows)
