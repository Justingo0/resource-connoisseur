extends Area2D

@export var max_destroy_time:float
@export var destroy_time:float = 0.0

@export var held:bool = false

@export var health = 1500

func take_damage(damage: int) -> void:
	health -= damage
	if health < 1:
		queue_free()
