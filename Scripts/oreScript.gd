@tool
extends Area2D

@export var type: OreStats:
	set(value):
		type = value
		if Engine.is_editor_hint():
			restartProperties()

@onready var sprite = $Sprite2D

func _ready() -> void:
	sprite.texture = type.icon

func restartProperties() -> void:
	sprite.texture = type.icon
