extends Area2D
var health = 2000

signal inventory_changed(value:int)

@export var inventory = {}:
	set(new_val):
		inventory = new_val
		GameManager.core_inventory = inventory
@export var inventory_size:int

@export var max_destroy_time:float
@export var destroy_time:float = 0.0

@export var held:bool

func get_disabled() -> bool:
	if destroy_time == max_destroy_time and held == false:
		return false
	return true

func take_damage(damage: int) -> void:
	health -= damage
	if health < 1:
		queue_free()
