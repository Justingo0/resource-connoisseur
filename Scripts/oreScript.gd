@tool
extends Area2D

@export var type: OreStats:
	set(value):
		type = value
		if Engine.is_editor_hint():
			restartProperties()

@onready var sprite = $Sprite2D

func _ready() -> void:
	if sprite:
		sprite.texture = type.icon

func restartProperties() -> void:
	if sprite:
		sprite.texture = type.icon

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
