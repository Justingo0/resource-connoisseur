extends Area2D
signal inventory_changed(value:int)

@export var inventory_size = 10
@export var inventory = {"ore": 0}
@export var productionNeeds:Array

@export var max_destroy_time:float
@export var destroy_time:float

@export var held:bool

@export var health = 200

#func _physics_process(delta: float) -> void:
	#if productionNeeds.size() >= 1:
		#if inventory[0] >= productionNeeds[0]:
			#print("resource 1 locked and loaded")
	#if productionNeeds.size() >= 2:
		#if inventory[1] >= productionNeeds[0]:
			#print("resource 2 locked and loaded")

func take_damage(damage: int) -> void:
	health -= damage
	if health < 1:
		queue_free()
