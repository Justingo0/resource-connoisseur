extends Area2D

@export var inventory = {"ore":0}
@export var inventory_size:int

@export var max_destroy_time:float
@export var destroy_time:float = 0.0

@export var held:bool

func _mouse_enter() -> void:
	pass
	#print(inventory)
