extends Area2D

@export var inventory = {"ore":0}
@export var inventory_size:int

func _mouse_enter() -> void:
	print(inventory)
