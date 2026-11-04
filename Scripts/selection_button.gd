@tool
extends TextureButton

@onready var camera = $"../../../../../../Player/Camera2D"
@onready var item_display = %ItemDisplay

@export var type:blockStats:
	set(new_val):
		type = new_val
		if type:
			texture_normal = type.icon
#@export var base_texture:Texture2D:
	#set(new_val):
		#base_texture = new_val
		#if base_texture:
			#texture_normal = base_texture
		#else:
			#texture_normal = null
	#get:
		#return base_texture
#@export var sub_texture:Texture2D:
	#set(new_val):
		#sub_texture = new_val
		#if sub_texture:
			#if not subtexture_rect: return
			#subtexture_rect.texture = sub_texture
		#else:
			#if not subtexture_rect: return
			#subtexture_rect.texture = null
	#get:
		#return sub_texture

var hovering := false

func _ready() -> void:
	#if base_texture:
		#texture_normal = base_texture
	#if sub_texture:
		#subtexture_rect.texture = sub_texture
	if type:
		texture_normal = type.icon

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and hovering:
		item_display.position = global_position+(size/2)

func _on_pressed() -> void:
	if not type: return
	camera.building_object = type.scene

func _on_mouse_entered() -> void:
	if not Engine.is_editor_hint():
		item_display.visible = true
		hovering = true
		
		item_display.get_node("Name").text = str(type.name)
		item_display.get_node("Description").text = str(type.description)

func _on_mouse_exited() -> void:
	if not Engine.is_editor_hint():
		item_display.visible = false
		hovering = false
