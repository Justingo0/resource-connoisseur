extends Area2D

@onready var ore_item = preload("res://Scenes/ore_item.tscn")

@onready var output_timer = $OutputTimer

@export var inventory = {"ore":0}
@export var inventory_size:int

@export var max_destroy_time:float
@export var destroy_time:float = 0.0

@export var held:bool

var conveyors = []:
	set(newValue):
		conveyors = newValue
		print(conveyors)
	get:
		return conveyors
var conveyor_interval = 0

func _on_conveyor_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Conveyor"):
		if area.held == true: return
		var conveyor_ray = area.get_node("RayCast")
		print(conveyor_ray.get_collider())
		if conveyor_ray.is_colliding() and conveyor_ray.get_collider() == self:
			return
		
		conveyors.append(area)
		conveyors = conveyors

func _on_conveyor_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Conveyor") and area in conveyors:
		conveyors.erase(area)
		conveyors = conveyors

func _on_output_timer_timeout() -> void:
	if conveyors.is_empty() or inventory["ore"] <= 0: return
	
	var output = conveyors[conveyor_interval%conveyors.size()]
	conveyor_interval += 1
	
	var conveyor_ray = output.get_node("RayCast")
	if conveyor_ray.is_colliding() and conveyor_ray.get_collider() == self:
		conveyors.erase(output)
		conveyor_interval += 1
		if conveyors.is_empty() or inventory["ore"] <= 0: return
		output = conveyors[conveyor_interval%conveyors.size()]
	
	if output and output.item == null and output.held == false and !held:
		var newItem = ore_item.instantiate()
		get_tree().current_scene.add_child(newItem)
		inventory["ore"] -= 1
		newItem.global_position = output.global_position
		output.item = newItem
