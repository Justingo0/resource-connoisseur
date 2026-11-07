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

func _on_production_timer_timeout() -> void:
	if inventory.keys().size() > 0 and resources != inventory_size:
		if inputItem.size() == 2 and inventory[inventory.keys()[0]] >= inputItem.keys()[0] and inventory[inventory.keys()[1]] >= inputItem.keys()[1]:
			resources = min(resources + 1, 10)
		elif inventory[inventory.keys()[0]] >= inputItem.values()[0]:
			inventory[inventory.keys()[0]] -= inputItem.values()[0]
			resources = min(resources + 1, 10)

