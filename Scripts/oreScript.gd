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
