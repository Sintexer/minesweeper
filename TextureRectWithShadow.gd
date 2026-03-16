class_name TextureRectWithShadow extends Control

@export var texture: Texture2D:
	set(new_texture): 
		texture = new_texture
		update_texture(new_texture)
		
@export var shadow_offset: Vector2 = Vector2(4, 4)

@onready var shadow: TextureRect = $Shadow
@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	if texture != null && shadow != null:
		update_texture(texture)

func update_texture(new_texture: Texture2D):
	if shadow == null || new_texture == null: return
	shadow.position = shadow_offset
	shadow.texture = new_texture	
	texture_rect.texture = new_texture
