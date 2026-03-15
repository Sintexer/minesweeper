extends Control

@onready var minefield: Minefield = %Minefield
@onready var game_over: PanelContainer = %GameOver
@onready var game_over_label: Label = %GameOverLabel
@onready var game_over_sound: AudioStreamPlayer = %GameOverSound
@onready var sound_player: AudioStreamPlayer = %MineClickedSound
@onready var difficulty_button: OptionButton = %DifficultyButton

@onready var timer_label: Label = %TimerLabel
@onready var flags_label: Label = %FlagsLabel
@onready var game_timer: Timer = %GameTimer

#const MINE_SWITCH_SOUND = preload("uid://c2upc21hbrvpf")
const MINE_SWITCH_SOUND = preload("uid://5jl2xqt5wau5")
const FLAG_SOUND = preload("uid://c24sj0f5wj8aw")
const REVEAL_SOUND = preload("uid://c0tqp63tlgv1j")

var difficulties: Array[Difficulty] = [
	Difficulty.create(7, 7, 0.15),
	Difficulty.create(10, 10, 0.15),
	Difficulty.create(14, 20, 0.2),
	Difficulty.create(14, 20, 0.3),
]

var game_board: GameBoard
var time: int = 0
var rows: int = 10
var cols: int = 10

func _ready() -> void:
	game_board = GameBoard.new()
	game_board.game_over.connect(on_game_over)
	minefield.flags_updated.connect(update_flags_label)
	game_timer.timeout.connect(update_timer_label)
	
	game_board.cell_updated.connect(minefield.on_cell_update)
	game_board.reveal_wave.connect(minefield.on_reveal_wave)

	
	var difficulty = difficulties[difficulty_button.selected]
	set_up(difficulty)
	
func set_up(difficulty: Difficulty) -> void:
	time = 0
	game_over.hide()
	game_board.set_up(difficulty)
	minefield.set_up(difficulty, game_board)
	update_flags_label(minefield.get_flags_left())
	update_timer_label()
	game_timer.start()
	
func on_game_over(is_win: bool) -> void:
	minefield.block_interaction()
	game_timer.stop()
	if !is_win:
		play_sound(sound_player, REVEAL_SOUND)
		await get_tree().create_timer(0.15).timeout
		play_sound(sound_player, MINE_SWITCH_SOUND)
		await get_tree().create_timer(0.2).timeout
		game_over_sound.play()
	
	var text = "Congratulations" if is_win else "Game Over"
	minefield.on_game_over()
	game_over_label.text = text
	game_over.show()


func update_flags_label(flags_left: int) -> void:
	flags_label.text = "%03d" % flags_left
	
func update_timer_label() -> void:
	timer_label.text = "%03d" % clampi(time, 0, 999)
	time += 1

func _on_restart_button_pressed() -> void:
	play_sound(sound_player, FLAG_SOUND)
	var difficulty = difficulties[difficulty_button.selected]
	set_up(difficulty)

func play_sound(player: AudioStreamPlayer, audio: AudioStream) -> void:
	player.stop()
	player.stream = audio
	player.play()


func _on_difficulty_button_item_selected(index: int) -> void:
	var difficulty = difficulties[index]
	set_up(difficulty)
