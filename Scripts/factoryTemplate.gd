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

func _on_conveyor_detector_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Conveyor") or area.is_in_group("Container")) and area.held == false and area != self:
		if not held:
			pass
			#print(area, " from ", self)
		conveyors.append(area)
		conveyors = conveyors
		output()

func _on_conveyor_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Conveyor") or area.is_in_group("Container") and area in conveyors:
		conveyors.erase(area)
		conveyors = conveyors

