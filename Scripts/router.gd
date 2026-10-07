extends Area2D

signal inventory_changed(value:int)

@onready var ore_item = preload("res://Scenes/ore_item.tscn")

@onready var output_timer = $OutputTimer

@export var inventory = {"ore":0}:
	set(new_val):
		inventory = new_val
		inventory_changed.emit(inventory["ore"])
	get:
		return inventory
@export var inventory_size:int

@export var max_destroy_time:float
@export var destroy_time:float = 0.0

@export var held:bool

var last_output_item = null
var output_conveyor = null

var conveyors = []:
	set(newValue):
		conveyors = newValue
		#print(conveyors)
	get:
		return conveyors
var conveyor_interval = 0

func _on_conveyor_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Conveyor"):
		if area.held == true: return
		var conveyor_ray = area.get_node("RayCast")
		#print(conveyor_ray.get_collider())
		if conveyor_ray.is_colliding() and conveyor_ray.get_collider() == self:
			return
		
		conveyors.append(area)
		conveyors = conveyors

func _on_conveyor_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Conveyor") and area in conveyors:
		conveyors.erase(area)
		conveyors = conveyors

func _physics_process(delta: float) -> void:
	if last_output_item:
		last_output_item.global_position = last_output_item.global_position.move_toward(output_conveyor.global_position, 400*delta*GameManager.time_scale)
		if output_conveyor.global_position == output_conveyor.global_position:
			output_conveyor.item = last_output_item
			output_conveyor.item_incoming = null
			last_output_item = null
			output_conveyor = null

func deposit():
	if conveyors.is_empty() or inventory["ore"] <= 0: return
	
	conveyor_interval += 1
	#print(conveyor_interval%conveyors.size())
	output_conveyor = conveyors[conveyor_interval%conveyors.size()]
	if not output_conveyor: return
	
	var conveyor_ray = output_conveyor.get_node("RayCast")
	if conveyor_ray.is_colliding() and conveyor_ray.get_collider() == self:
		conveyors.erase(output_conveyor)
		if conveyors.is_empty(): return
		output_conveyor = conveyors[conveyor_interval%conveyors.size()]
	
	if output_conveyor and output_conveyor.item == null and output_conveyor.held == false and !held:
		inventory["ore"] -= 1
		inventory = inventory
		last_output_item = ore_item.instantiate()
		get_tree().current_scene.call_deferred('add_child', last_output_item)
		
		var starting_pos = global_position
		if (output_conveyor.global_position.y - global_position.y) == 64.0 or (output_conveyor.global_position.y - global_position.y) == -128:
			starting_pos.x = output_conveyor.global_position.x
		else:
			starting_pos.y = output_conveyor.global_position.y
		
		last_output_item.global_position = starting_pos
		output_conveyor.item_incoming = last_output_item

func _on_inventory_changed(value: int) -> void:
	if value > 0:
		if output_timer.is_stopped():
			deposit()
			output_timer.start()
	else:
		output_timer.stop()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if last_output_item:
			last_output_item.queue_free()
			output_conveyor.item_incoming = null

func _on_output_timer_timeout() -> void:
	deposit()
