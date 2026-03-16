class_name GridButton extends Control


@onready var number_icon: TextureRect = %NumberIcon
@onready var overlay_icon: TextureRectWithShadow = %OverlayIcon
@onready var overlay_flag: TextureRectWithShadow = %FlagIcon

@onready var button: TextureButton = %Button
@onready var visual_wrapper: Control = %VisualWrapper


var cell: Cell

#func _ready() -> void:
	#play_start_animation()

#func _ready() -> void:
	#EventBus.game_over.connect(on_game_over)
	#button.custom_minimum_size = Vector2(TILE_SIZE, TILE_SIZE)
	#size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#size_flags_vertical = Control.SIZE_EXPAND_FILL
	

func set_up(c: Cell) -> void:
	cell = c
	overlay_flag.hide()
	overlay_icon.hide()
	var number = SpriteManager.get_cell_texture(c)
	number_icon.texture = number
	overlay_icon.texture = null
	
	# prepare for the init animation
	#visual_wrapper.scale = Vector2.ONE * 1.3
	visual_wrapper.position.y = -50.0
	visual_wrapper.modulate.a = 0.0
	
func on_update() -> void:
	if cell.is_revealed:
		if !cell.is_mine:
			hide_button()
		return
	
	if cell.is_flagged:
		button.disabled = true
		overlay_flag.show()
	else:
		overlay_flag.hide()
		button.disabled = false

func on_game_over() -> void:
	if cell.is_mine:
		if cell.is_flagged:
			overlay_flag.hide()
			overlay_icon.texture = SpriteManager.BOMB_DEFUSED
		elif cell.is_revealed:
			overlay_icon.texture = SpriteManager.TILE_EXPLODED
		else:
			overlay_icon.texture = SpriteManager.BOMB
	overlay_icon.show()

func hide_button() -> void:	
	button.modulate = Color(Color.WHITE, 0.5)
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.4, 1.4), 0.1)
	tween.parallel().tween_property(button, "modulate:a", 0.0, 0.1)
	await tween.finished
	number_icon.show()
	button.hide()

func play_start_animation() -> void:
	pass
	var tween = create_tween()
	var tween_duration: float = 0.1
	visual_wrapper.modulate.a = 1.0
	#tween.tween_property(visual_wrapper, "scale", Vector2.ONE, tween_duration)
	tween.parallel().tween_property(visual_wrapper, "position:y",0.0, tween_duration)
	tween.parallel().tween_property(visual_wrapper, "modulate:a", 1.0, tween_duration)
	await tween.finished

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if button.visible && event.button_index == MOUSE_BUTTON_RIGHT:
			get_tree().root.set_input_as_handled()
			EventBus.emit_toggle_flag(cell)
		
func _on_button_pressed() -> void:
	EventBus.emit_reveal_cell(cell)
