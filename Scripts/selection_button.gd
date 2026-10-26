@tool
extends TextureButton

@onready var subtexture_rect = $SubTexture

@onready var camera = $"../../../../../../Player/Camera2D"

@export var object_scene:PackedScene
@export var base_texture:Texture2D:
	set(new_val):
		base_texture = new_val
		if base_texture:
			texture_normal = base_texture
		else:
			texture_normal = null
	get:
		return base_texture
@export var sub_texture:Texture2D:
	set(new_val):
		sub_texture = new_val
		if sub_texture:
			if not subtexture_rect: return
			subtexture_rect.texture = sub_texture
		else:
			if not subtexture_rect: return
			subtexture_rect.texture = null
	get:
		return sub_texture

func _ready() -> void:
	if base_texture:
		texture_normal = base_texture
	if sub_texture:
		subtexture_rect.texture = sub_texture

func _on_pressed() -> void:
	if not object_scene: return
	camera.building_object = object_scene
